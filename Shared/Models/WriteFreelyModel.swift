import Foundation
import WriteFreely
import Security
import Network

// MARK: - WriteFreelyModel

class WriteFreelyModel: ObservableObject {
    @Published var account = AccountModel()
    @Published var preferences = PreferencesModel()
    @Published var posts = PostListModel()
    @Published var editor = PostEditorModel()
    @Published var isLoggingIn: Bool = false
    @Published var hasNetworkConnection: Bool = false
    @Published var selectedPost: WFAPost?
    @Published var isPresentingDeleteAlert: Bool = false
    @Published var postToDelete: WFAPost?
    #if os(iOS)
    @Published var isPresentingSettingsView: Bool = false
    #endif

    // swiftlint:disable line_length
    let helpURL = URL(string: "https://discuss.write.as/c/help/5")!
    let licensesURL = URL(string: "https://github.com/writeas/writefreely-swiftui-multiplatform/tree/main/Shared/Resources/Licenses")!
    // swiftlint:enable line_length

    private var client: WFClient?
    private let defaults = UserDefaults.standard
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")

    init() {
        DispatchQueue.main.async {
            self.preferences.appearance = self.defaults.integer(forKey: self.preferences.colorSchemeIntegerKey)
            self.preferences.font = self.defaults.integer(forKey: self.preferences.defaultFontIntegerKey)
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
                self.fetchUserCollections()
                self.fetchUserPosts()
            }
        }

        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                self.hasNetworkConnection = path.status == .satisfied
            }
        }
        monitor.start(queue: queue)
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

    func publish(post: WFAPost) {
        guard let loggedInClient = client else { return }

        if post.language == nil {
            if let languageCode = Locale.current.languageCode {
                post.language = languageCode
                post.rtl = Locale.characterDirection(forLanguage: languageCode) == .rightToLeft
            }
        }

        var wfPost = WFPost(
            body: post.body,
            title: post.title.isEmpty ? "" : post.title,
            appearance: post.appearance,
            language: post.language,
            rtl: post.rtl,
            createdDate: post.createdDate
        )

        if let existingPostId = post.postId {
            // This is an existing post.
            wfPost.postId = post.postId
            wfPost.slug = post.slug
            wfPost.updatedDate = post.updatedDate
            wfPost.collectionAlias = post.collectionAlias

            loggedInClient.updatePost(
                postId: existingPostId,
                updatedPost: wfPost,
                completion: publishHandler
            )
        } else {
            // This is a new local draft.
            loggedInClient.createPost(
                post: wfPost, in: post.collectionAlias, completion: publishHandler
            )
        }
    }

    func updateFromServer(post: WFAPost) {
        guard let loggedInClient = client else { return }
        guard let postId = post.postId else { return }
        DispatchQueue.main.async {
            self.selectedPost = post
        }
        if let postCollectionAlias = post.collectionAlias,
           let postSlug = post.slug {
            loggedInClient.getPost(bySlug: postSlug, from: postCollectionAlias, completion: updateFromServerHandler)
        } else {
            loggedInClient.getPost(byId: postId, completion: updateFromServerHandler)
        }
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
            if (error as NSError).domain == NSURLErrorDomain,
               (error as NSError).code == -1003 {
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
                    LocalStorageManager().purgeUserCollections()
                    self.posts.purgeAllPosts()
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
                    LocalStorageManager().purgeUserCollections()
                    self.posts.purgeAllPosts()
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
        do {
            let fetchedCollections = try result.get()
            for fetchedCollection in fetchedCollections {
                DispatchQueue.main.async {
                    let localCollection = WFACollection(context: LocalStorageManager.persistentContainer.viewContext)
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
                LocalStorageManager().saveContext()
            }
        } catch {
            print(error)
        }
    }

    func fetchUserPostsHandler(result: Result<[WFPost], Error>) {
        do {
            var postsToDelete = posts.userPosts.filter { $0.status != PostStatus.local.rawValue }
            let fetchedPosts = try result.get()
            for fetchedPost in fetchedPosts {
                if let managedPost = posts.userPosts.first(where: { $0.postId == fetchedPost.postId }) {
                    managedPost.wasDeletedFromServer = false
                    if let fetchedPostUpdatedDate = fetchedPost.updatedDate,
                       let localPostUpdatedDate = managedPost.updatedDate {
                        managedPost.hasNewerRemoteCopy = fetchedPostUpdatedDate > localPostUpdatedDate
                    } else {
                        print("Error: could not determine which copy of post is newer")
                    }
                    postsToDelete.removeAll(where: { $0.postId == fetchedPost.postId })
                } else {
                    let managedPost = WFAPost(context: LocalStorageManager.persistentContainer.viewContext)
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
            for post in postsToDelete {
                post.wasDeletedFromServer = true
            }
            DispatchQueue.main.async {
                LocalStorageManager().saveContext()
                self.posts.loadCachedPosts()
            }
        } catch {
            print(error)
        }
    }

    func publishHandler(result: Result<WFPost, Error>) {
        do {
            let fetchedPost = try result.get()
            let foundPostIndex = posts.userPosts.firstIndex(where: {
                $0.title == fetchedPost.title && $0.body == fetchedPost.body
            })
            guard let index = foundPostIndex else { return }
            let cachedPost = self.posts.userPosts[index]
            cachedPost.appearance = fetchedPost.appearance
            cachedPost.body = fetchedPost.body
            cachedPost.collectionAlias = fetchedPost.collectionAlias
            cachedPost.createdDate = fetchedPost.createdDate
            cachedPost.language = fetchedPost.language
            cachedPost.postId = fetchedPost.postId
            cachedPost.rtl = fetchedPost.rtl ?? false
            cachedPost.slug = fetchedPost.slug
            cachedPost.status = PostStatus.published.rawValue
            cachedPost.title = fetchedPost.title ?? ""
            cachedPost.updatedDate = fetchedPost.updatedDate
            DispatchQueue.main.async {
                LocalStorageManager().saveContext()
            }
        } catch {
            print(error)
        }
    }

    func updateFromServerHandler(result: Result<WFPost, Error>) {
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
                LocalStorageManager().saveContext()
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
