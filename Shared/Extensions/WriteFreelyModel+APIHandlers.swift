import Foundation
import WriteFreely

extension WriteFreelyModel {
    func loginHandler(result: Result<WFUser, Error>) {
        DispatchQueue.main.async {
            self.isLoggingIn = false
        }
        do {
            let user = try result.get()
            fetchUserCollections()
            fetchUserPosts()
            do {
                try saveTokenToKeychain(user.token, username: user.username, server: account.server)
                DispatchQueue.main.async {
                    self.account.login(user)
                }
            } catch {
                setCurrentError(to: KeychainError.couldNotStoreAccessToken)
            }
        } catch WFError.notFound {
            setCurrentError(to: AccountError.usernameNotFound)
        } catch WFError.unauthorized {
            setCurrentError(to: AccountError.invalidPassword)
        } catch {
            if (error as NSError).domain == NSURLErrorDomain,
               (error as NSError).code == -1003 {
                setCurrentError(to: AccountError.serverNotFound)
            } else {
                setCurrentError(to: error)
            }
        }
    }

    func logoutHandler(result: Result<Bool, Error>) {
        do {
            _ = try result.get()
            do {
                try purgeTokenFromKeychain(username: account.user?.username, server: account.server)
                client = nil
                DispatchQueue.main.async {
                    self.account.logout()
                    do {
                        try LocalStorageManager.standard.purgeUserCollections()
                    } catch {
                        self.currentError = error
                    }
                    do {
                        try self.posts.purgePublishedPosts()
                    } catch {
                        self.currentError = error
                    }
                }
            } catch {
                setCurrentError(to: KeychainError.couldNotPurgeAccessToken)
            }
        } catch WFError.notFound {
            // The user token is invalid or doesn't exist, so it's been invalidated by the server. Proceed with
            // purging the token from the Keychain, destroying the client object, and setting the AccountModel to its
            // logged-out state.
            do {
                try purgeTokenFromKeychain(username: account.user?.username, server: account.server)
                client = nil
                DispatchQueue.main.async {
                    self.account.logout()
                    do {
                        try LocalStorageManager.standard.purgeUserCollections()
                    } catch {
                        self.currentError = error
                    }
                    do { try self.posts.purgePublishedPosts() } catch { self.currentError = error }
                }
            } catch {
                setCurrentError(to: KeychainError.couldNotPurgeAccessToken)
            }
        } catch {
            // We get a 'cannot parse response' (similar to what we were seeing in the Swift package) NSURLError here,
            // so we're using a hacky workaround — if we get the NSURLError, but the AccountModel still thinks we're
            // logged in, try calling the logout function again and see what we get.
            // Conditional cast from 'Error' to 'NSError' always succeeds but is the only way to check error properties.
            if (error as NSError).domain == NSURLErrorDomain,
               (error as NSError).code == NSURLErrorCannotParseResponse {
                if account.isLoggedIn {
                    self.logout()
                }
            }
        }
    }

    func fetchUserCollectionsHandler(result: Result<[WFCollection], Error>) {
        // We're done with the network request.
        DispatchQueue.main.async {
            self.isProcessingRequest = false
        }
        do {
            let fetchedCollections = try result.get()
            for fetchedCollection in fetchedCollections {
                DispatchQueue.main.async {
                    let localCollection = WFACollection(context: LocalStorageManager.standard.container.viewContext)
                    localCollection.alias = fetchedCollection.alias
                    localCollection.blogDescription = fetchedCollection.description
                    localCollection.email = fetchedCollection.email
                    localCollection.isPublic = fetchedCollection.isPublic ?? false
                    localCollection.styleSheet = fetchedCollection.styleSheet
                    localCollection.title = fetchedCollection.title
                    localCollection.url = fetchedCollection.url
                }
            }
            DispatchQueue.main.async {
                LocalStorageManager.standard.saveContext()
            }
        } catch WFError.unauthorized {
            setCurrentError(to: AccountError.genericAuthError)
            self.logout()
        } catch {
            setCurrentError(to: error)
        }
    }

    func fetchUserPostsHandler(result: Result<[WFPost], Error>) {
        // We're done with the network request.
        DispatchQueue.main.async {
            self.isProcessingRequest = false
        }
        let request = WFAPost.createFetchRequest()
        do {
            let locallyCachedPosts = try LocalStorageManager.standard.container.viewContext.fetch(request)
            do {
                var postsToDelete = locallyCachedPosts.filter { $0.status != PostStatus.local.rawValue }
                let fetchedPosts = try result.get()
                for fetchedPost in fetchedPosts {
                    if let managedPost = locallyCachedPosts.first(where: { $0.postId == fetchedPost.postId }) {
                        DispatchQueue.main.async {
                            managedPost.wasDeletedFromServer = false
                            if let fetchedPostUpdatedDate = fetchedPost.updatedDate,
                               let localPostUpdatedDate = managedPost.updatedDate {
                                managedPost.hasNewerRemoteCopy = fetchedPostUpdatedDate > localPostUpdatedDate
                            } else {
                                self.setCurrentError(
                                    to: LocalStoreError.genericError("Could not determine which copy of post is newer")
                                )
                            }
                            postsToDelete.removeAll(where: { $0.postId == fetchedPost.postId })
                        }
                    } else {
                        DispatchQueue.main.async {
                            let managedPost = WFAPost(context: LocalStorageManager.standard.container.viewContext)
                            self.importData(from: fetchedPost, into: managedPost)
                            managedPost.collectionAlias = fetchedPost.collectionAlias
                            managedPost.wasDeletedFromServer = false
                        }
                    }
                }
                DispatchQueue.main.async {
                    for post in postsToDelete { post.wasDeletedFromServer = true }
                    LocalStorageManager.standard.saveContext()
                }
            } catch {
                setCurrentError(to: error)
            }
        } catch WFError.unauthorized {
            setCurrentError(to: AccountError.genericAuthError)
            self.logout()
        } catch {
            setCurrentError(to: LocalStoreError.couldNotFetchPosts("cached"))
        }
    }

    func publishHandler(result: Result<WFPost, Error>) {
        // We're done with the network request.
        DispatchQueue.main.async {
            self.isProcessingRequest = false
        }
        // ⚠️ NOTE:
        // The API does not return a collection alias, so we take care not to overwrite the
        // cached post's collection alias with the 'nil' value from the fetched post.
        // See: https://github.com/writeas/writefreely-swift/issues/20
        do {
            let fetchedPost = try result.get()
            // If this is an updated post, check it against postToUpdate.
            if let updatingPost = self.postToUpdate {
                importData(from: fetchedPost, into: updatingPost)
                DispatchQueue.main.async {
                    LocalStorageManager.standard.saveContext()
                }
            } else {
                // Otherwise if it's a newly-published post, find it in the local store.
                let request = WFAPost.createFetchRequest()
                let matchBodyPredicate = NSPredicate(format: "body == %@", fetchedPost.body)
                if let fetchedPostTitle = fetchedPost.title {
                    let matchTitlePredicate = NSPredicate(format: "title == %@", fetchedPostTitle)
                    request.predicate = NSCompoundPredicate(
                        andPredicateWithSubpredicates: [
                            matchTitlePredicate,
                            matchBodyPredicate
                        ]
                    )
                } else {
                    request.predicate = matchBodyPredicate
                }
                do {
                    let cachedPostsResults = try LocalStorageManager.standard.container.viewContext.fetch(request)
                    guard let cachedPost = cachedPostsResults.first else {
                        setCurrentError(to: LocalStoreError.genericError("Could not get cached post from results"))
                        return
                    }
                    importData(from: fetchedPost, into: cachedPost)
                    DispatchQueue.main.async {
                        LocalStorageManager.standard.saveContext()
                    }
                } catch {
                    setCurrentError(to: LocalStoreError.couldNotFetchPosts("cached"))
                }
            }
        } catch {
            setCurrentError(to: error)
        }
    }

    func updateFromServerHandler(result: Result<WFPost, Error>) {
        // We're done with the network request.
        DispatchQueue.main.async {
            self.isProcessingRequest = false
        }
        // ⚠️ NOTE:
        // The API does not return a collection alias, so we take care not to overwrite the
        // cached post's collection alias with the 'nil' value from the fetched post.
        // See: https://github.com/writeas/writefreely-swift/issues/20
        do {
            let fetchedPost = try result.get()
            guard let cachedPost = self.selectedPost else {
                setCurrentError(to: LocalStoreError.genericError("Could not get cached post"))
                return
            }
            importData(from: fetchedPost, into: cachedPost)
            cachedPost.hasNewerRemoteCopy = false
            DispatchQueue.main.async {
                LocalStorageManager.standard.saveContext()
            }
        } catch {
            setCurrentError(to: error)
        }
    }

    func movePostHandler(result: Result<Bool, Error>) {
        // We're done with the network request.
        DispatchQueue.main.async {
            self.isProcessingRequest = false
        }
        do {
            let succeeded = try result.get()
            if succeeded {
                if let post = selectedPost {
                    updateFromServer(post: post)
                } else {
                    setCurrentError(to: LocalStoreError.genericError("Could not update post from server"))
                }
            }
        } catch {
            DispatchQueue.main.async {
                LocalStorageManager.standard.container.viewContext.rollback()
                self.currentError = error
            }
        }
    }

    private func importData(from fetchedPost: WFPost, into cachedPost: WFAPost) {
        cachedPost.appearance = fetchedPost.appearance
        cachedPost.body = fetchedPost.body
        cachedPost.createdDate = fetchedPost.createdDate
        cachedPost.language = fetchedPost.language
        cachedPost.postId = fetchedPost.postId
        cachedPost.rtl = fetchedPost.rtl ?? false
        cachedPost.slug = fetchedPost.slug
        cachedPost.status = PostStatus.published.rawValue
        cachedPost.title = fetchedPost.title ?? ""
        cachedPost.updatedDate = fetchedPost.updatedDate
    }

    private func setCurrentError(to error: Error) {
        DispatchQueue.main.async {
            self.currentError = error
        }
    }
}
