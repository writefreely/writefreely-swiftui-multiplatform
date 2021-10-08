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
                DispatchQueue.main.async {
                    self.loginErrorMessage = "There was a problem storing your access token to the Keychain."
                    self.isPresentingLoginErrorAlert = true
                }
            }
        } catch WFError.notFound {
            DispatchQueue.main.async {
                self.loginErrorMessage = AccountError.usernameNotFound.localizedDescription
                self.isPresentingLoginErrorAlert = true
            }
        } catch WFError.unauthorized {
            DispatchQueue.main.async {
                self.loginErrorMessage = AccountError.invalidPassword.localizedDescription
                self.isPresentingLoginErrorAlert = true
            }
        } catch {
            if (error as NSError).domain == NSURLErrorDomain,
               (error as NSError).code == -1003 {
                DispatchQueue.main.async {
                    self.loginErrorMessage = AccountError.serverNotFound.localizedDescription
                    self.isPresentingLoginErrorAlert = true
                }
            } else {
                DispatchQueue.main.async {
                    self.loginErrorMessage = error.localizedDescription
                    self.isPresentingLoginErrorAlert = true
                }
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
                    LocalStorageManager.standard.purgeUserCollections()
                    self.posts.purgePublishedPosts()
                }
            } catch {
                print("Something went wrong purging the token from the Keychain.")
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
                    LocalStorageManager.standard.purgeUserCollections()
                    self.posts.purgePublishedPosts()
                }
            } catch {
                print("Something went wrong purging the token from the Keychain.")
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
                    let localCollection = WFACollection(context: LocalStorageManager.standard.persistentContainer.viewContext)
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
            DispatchQueue.main.async {
                self.loginErrorMessage = "Something went wrong, please try logging in again."
                self.isPresentingLoginErrorAlert = true
            }
            self.logout()
        } catch {
            print(error)
        }
    }

    func fetchUserPostsHandler(result: Result<[WFPost], Error>) {
        // We're done with the network request.
        DispatchQueue.main.async {
            self.isProcessingRequest = false
        }
        let request = WFAPost.createFetchRequest()
        do {
            let locallyCachedPosts = try LocalStorageManager.standard.persistentContainer.viewContext.fetch(request)
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
                            } else { print("Error: could not determine which copy of post is newer") }
                            postsToDelete.removeAll(where: { $0.postId == fetchedPost.postId })
                        }
                    } else {
                        DispatchQueue.main.async {
                            let managedPost = WFAPost(context: LocalStorageManager.standard.persistentContainer.viewContext)
                            managedPost.postId = fetchedPost.postId
                            managedPost.slug = fetchedPost.slug
                            managedPost.appearance = fetchedPost.appearance
                            managedPost.language = fetchedPost.language
                            managedPost.rtl = fetchedPost.rtl ?? false
                            managedPost.createdDate = fetchedPost.createdDate
                            managedPost.updatedDate = fetchedPost.updatedDate
                            managedPost.title = fetchedPost.title ?? ""
                            managedPost.body = fetchedPost.body
                            managedPost.collectionAlias = fetchedPost.collectionAlias
                            managedPost.status = PostStatus.published.rawValue
                            managedPost.wasDeletedFromServer = false
                        }
                    }
                }
                DispatchQueue.main.async {
                    for post in postsToDelete { post.wasDeletedFromServer = true }
                    LocalStorageManager.standard.saveContext()
                }
            } catch {
                print(error)
            }
        } catch WFError.unauthorized {
            DispatchQueue.main.async {
                self.loginErrorMessage = "Something went wrong, please try logging in again."
                self.isPresentingLoginErrorAlert = true
            }
            self.logout()
        } catch {
            print("Error: Failed to fetch cached posts")
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
                updatingPost.appearance = fetchedPost.appearance
                updatingPost.body = fetchedPost.body
                updatingPost.createdDate = fetchedPost.createdDate
                updatingPost.language = fetchedPost.language
                updatingPost.postId = fetchedPost.postId
                updatingPost.rtl = fetchedPost.rtl ?? false
                updatingPost.slug = fetchedPost.slug
                updatingPost.status = PostStatus.published.rawValue
                updatingPost.title = fetchedPost.title ?? ""
                updatingPost.updatedDate = fetchedPost.updatedDate
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
                    let cachedPostsResults = try LocalStorageManager.standard.persistentContainer.viewContext.fetch(request)
                    guard let cachedPost = cachedPostsResults.first else { return }
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
                    DispatchQueue.main.async {
                        LocalStorageManager.standard.saveContext()
                    }
                } catch {
                    print("Error: Failed to fetch cached posts")
                }
            }
        } catch {
            print(error)
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
            guard let cachedPost = self.selectedPost else { return }
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
            cachedPost.hasNewerRemoteCopy = false
            DispatchQueue.main.async {
                LocalStorageManager.standard.saveContext()
            }
        } catch {
            print(error)
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
                    return
                }
            }
        } catch {
            DispatchQueue.main.async {
                LocalStorageManager.standard.persistentContainer.viewContext.rollback()
            }
            print(error)
        }
    }
}
