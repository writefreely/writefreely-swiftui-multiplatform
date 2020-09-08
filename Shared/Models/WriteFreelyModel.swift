import Foundation
import WriteFreely
import Security

// MARK: - WriteFreelyModel

class WriteFreelyModel: ObservableObject {
    @Published var account = AccountModel()
    @Published var preferences = PreferencesModel()
    @Published var store = PostStore()
    @Published var collections = CollectionListModel(with: [])
    @Published var isLoggingIn: Bool = false
    @Published var selectedPost: Post?

    private var client: WFClient?
    private let defaults = UserDefaults.standard

    init() {
        // Set the color scheme based on what's been saved in UserDefaults.
        DispatchQueue.main.async {
            self.preferences.appearance = self.defaults.integer(forKey: self.preferences.colorSchemeIntegerKey)
        }

        #if DEBUG
//        for post in testPostData { store.add(post) }
        #endif

        DispatchQueue.main.async {
            self.account.restoreState()
            if self.account.isLoggedIn {
                guard let serverURL = URL(string: self.account.server) else {
                    print("Server URL not found")
                    return
                }
                guard let token = self.fetchTokenFromKeychain(
                        username: self.account.username,
                        server: self.account.server
                ) else {
                    print("Could not fetch token from Keychain")
                    return
                }
                self.account.login(WFUser(token: token, username: self.account.username))
                self.client = WFClient(for: serverURL)
                self.client?.user = self.account.user
                self.collections.clearUserCollection()
                self.fetchUserCollections()
                self.fetchUserPosts()
            }
        }
    }
}

// MARK: - WriteFreelyModel API

extension WriteFreelyModel {
    func login(to server: URL, as username: String, password: String) {
        isLoggingIn = true
        account.server = server.absoluteString
        client = WFClient(for: server)
        client?.login(username: username, password: password, completion: loginHandler)
    }

    func logout() {
        guard let loggedInClient = client else {
            do {
                try purgeTokenFromKeychain(username: account.username, server: account.server)
                account.logout()
            } catch {
                fatalError("Failed to log out persisted state")
            }
            return
        }
        loggedInClient.logout(completion: logoutHandler)
    }

    func fetchUserCollections() {
        guard let loggedInClient = client else { return }
        loggedInClient.getUserCollections(completion: fetchUserCollectionsHandler)
    }

    func fetchUserPosts() {
        guard let loggedInClient = client else { return }
        loggedInClient.getPosts(completion: fetchUserPostsHandler)
    }

    func publish(post: Post) {
        guard let loggedInClient = client else { return }

        if let existingPostId = post.wfPost.postId {
            // This is an existing post.
            loggedInClient.updatePost(
                postId: existingPostId,
                updatedPost: post.wfPost,
                completion: publishHandler
            )
        } else {
            // This is a new local draft.
            loggedInClient.createPost(
                post: post.wfPost, in: post.collection.wfCollection?.alias, completion: publishHandler
            )
        }
    }

    func updateFromServer(post: Post) {
        guard let loggedInClient = client else { return }
        guard let postId = post.wfPost.postId else { return }
        DispatchQueue.main.async {
            self.selectedPost = post
        }
        loggedInClient.getPost(byId: postId, completion: updateFromServerHandler)
    }
}

private extension WriteFreelyModel {
    func loginHandler(result: Result<WFUser, Error>) {
        DispatchQueue.main.async {
            self.isLoggingIn = false
        }
        do {
            let user = try result.get()
            fetchUserCollections()
            fetchUserPosts()
            saveTokenToKeychain(user.token, username: user.username, server: account.server)
            DispatchQueue.main.async {
                self.account.login(user)
            }
        } catch WFError.notFound {
            DispatchQueue.main.async {
                self.account.currentError = AccountError.usernameNotFound
            }
        } catch WFError.unauthorized {
            DispatchQueue.main.async {
                self.account.currentError = AccountError.invalidPassword
            }
        } catch {
            if let error = error as? NSError, error.domain == NSURLErrorDomain, error.code == -1003 {
                DispatchQueue.main.async {
                    self.account.currentError = AccountError.serverNotFound
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
                    self.collections.clearUserCollection()
                    self.store.purgeAllPosts()
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
                    self.collections.clearUserCollection()
                    self.store.purgeAllPosts()
                }
            } catch {
                print("Something went wrong purging the token from the Keychain.")
            }
        } catch {
            // We get a 'cannot parse response' (similar to what we were seeing in the Swift package) NSURLError here,
            // so we're using a hacky workaround — if we get the NSURLError, but the AccountModel still thinks we're
            // logged in, try calling the logout function again and see what we get.
            // Conditional cast from 'Error' to 'NSError' always succeeds but is the only way to check error properties.
            if let error = error as? NSError,
               error.domain == NSURLErrorDomain,
               error.code == NSURLErrorCannotParseResponse {
                if account.isLoggedIn {
                    self.logout()
                }
            }
        }
    }

    func fetchUserCollectionsHandler(result: Result<[WFCollection], Error>) {
        do {
            let fetchedCollections = try result.get()
            var fetchedCollectionsArray: [PostCollection] = []
            for fetchedCollection in fetchedCollections {
                var postCollection = PostCollection(title: fetchedCollection.title)
                postCollection.wfCollection = fetchedCollection
                fetchedCollectionsArray.append(postCollection)
            }
            DispatchQueue.main.async {
                self.collections = CollectionListModel(with: fetchedCollectionsArray)
            }
        } catch {
            print(error)
        }
    }

    func fetchUserPostsHandler(result: Result<[WFPost], Error>) {
        do {
            let fetchedPosts = try result.get()
            var fetchedPostsArray: [Post] = []
            for fetchedPost in fetchedPosts {
                var post: Post
                if let matchingAlias = fetchedPost.collectionAlias {
                    let postCollection = (
                        collections.userCollections.filter { $0.wfCollection?.alias == matchingAlias }
                    ).first
                    post = Post(wfPost: fetchedPost, in: postCollection ?? draftsCollection)
                } else {
                    post = Post(wfPost: fetchedPost)
                }
                fetchedPostsArray.append(post)
            }
            DispatchQueue.main.async {
                self.store.updateStore(with: fetchedPostsArray)
            }
        } catch {
            print(error)
        }
    }

    func publishHandler(result: Result<WFPost, Error>) {
        do {
            let wfPost = try result.get()
            let foundPostIndex = store.posts.firstIndex(where: {
                $0.wfPost.title == wfPost.title && $0.wfPost.body == wfPost.body
            })
            guard let index = foundPostIndex else { return }
            DispatchQueue.main.async {
                self.store.posts[index].wfPost = wfPost
            }
        } catch {
            print(error)
        }
    }

    func updateFromServerHandler(result: Result<WFPost, Error>) {
        do {
            let fetchedPost = try result.get()
            DispatchQueue.main.async {
                guard let selectedPost = self.selectedPost else { return }
                self.store.replace(post: selectedPost, with: fetchedPost)
            }
        } catch {
            print(error)
        }
    }
}

private extension WriteFreelyModel {
    // MARK: - Keychain Helpers
    func saveTokenToKeychain(_ token: String, username: String?, server: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecValueData as String: token.data(using: .utf8)!,
            kSecAttrAccount as String: username ?? "anonymous",
            kSecAttrService as String: server
        ]

        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecDuplicateItem || status == errSecSuccess else {
            fatalError("Error storing in Keychain with OSStatus: \(status)")
        }
    }

    func purgeTokenFromKeychain(username: String?, server: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: username ?? "anonymous",
            kSecAttrService as String: server
        ]

        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            fatalError("Error deleting from Keychain with OSStatus: \(status)")
        }
    }

    func fetchTokenFromKeychain(username: String?, server: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: username ?? "anonymous",
            kSecAttrService as String: server,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnAttributes as String: true,
            kSecReturnData as String: true
        ]

        var secItem: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &secItem)

        guard status != errSecItemNotFound else {
            return nil
        }

        guard status == errSecSuccess else {
            fatalError("Error fetching from Keychain with OSStatus: \(status)")
        }

        guard let existingSecItem = secItem as? [String: Any],
              let tokenData = existingSecItem[kSecValueData as String] as? Data,
              let token = String(data: tokenData, encoding: .utf8) else {
            return nil
        }

        return token
    }
}
