import Foundation
import WriteFreely

extension WriteFreelyModel {
    func login(to server: URL, as username: String, password: String) {
        if !hasNetworkConnection {
            isPresentingNetworkErrorAlert = true
            return
        }
        let secureProtocolPrefix = "https://"
        let insecureProtocolPrefix = "http://"
        var serverString = server.absoluteString
        // If there's neither an http or https prefix, prepend "https://" to the server string.
        if !(serverString.hasPrefix(secureProtocolPrefix) || serverString.hasPrefix(insecureProtocolPrefix)) {
            serverString = secureProtocolPrefix + serverString
        }
        // If the server string is prefixed with http, upgrade to https before attempting to login.
        if serverString.hasPrefix(insecureProtocolPrefix) {
            serverString = serverString.replacingOccurrences(of: insecureProtocolPrefix, with: secureProtocolPrefix)
        }
        isLoggingIn = true
        var serverURL = URL(string: serverString)!
        if !serverURL.path.isEmpty {
            serverURL.deleteLastPathComponent()
        }
        account.server = serverURL.absoluteString
        client = WFClient(for: serverURL)
        client?.login(username: username, password: password, completion: loginHandler)
    }

    func logout() {
        if !hasNetworkConnection {
            DispatchQueue.main.async { self.isPresentingNetworkErrorAlert = true }
            return
        }
        guard let loggedInClient = client else {
            do {
                try purgeTokenFromKeychain(username: account.username, server: account.server)
                account.logout()
            } catch {
                self.currentError = KeychainError.couldNotPurgeAccessToken
            }
            return
        }
        loggedInClient.logout(completion: logoutHandler)
    }

    func fetchUserCollections() {
        if !hasNetworkConnection {
            DispatchQueue.main.async { self.isPresentingNetworkErrorAlert = true }
            return
        }
        guard let loggedInClient = client else {
            self.currentError = AppError.couldNotGetLoggedInClient
            return
        }
        // We're starting the network request.
        DispatchQueue.main.async {
            self.isProcessingRequest = true
        }
        loggedInClient.getUserCollections(completion: fetchUserCollectionsHandler)
    }

    func fetchUserPosts() {
        if !hasNetworkConnection {
            DispatchQueue.main.async { self.isPresentingNetworkErrorAlert = true }
            return
        }
        guard let loggedInClient = client else {
            self.currentError = AppError.couldNotGetLoggedInClient
            return
        }
        // We're starting the network request.
        DispatchQueue.main.async {
            self.isProcessingRequest = true
        }
        loggedInClient.getPosts(completion: fetchUserPostsHandler)
    }

    func publish(post: WFAPost) {
        postToUpdate = nil

        if !hasNetworkConnection {
            DispatchQueue.main.async { self.isPresentingNetworkErrorAlert = true }
            return
        }
        guard let loggedInClient = client else {
            self.currentError = AppError.couldNotGetLoggedInClient
            return
        }
        // We're starting the network request.
        DispatchQueue.main.async {
            self.isProcessingRequest = true
        }

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
            createdDate: post.status == PostStatus.local.rawValue ? Date() : post.createdDate
        )

        if let existingPostId = post.postId {
            // This is an existing post.
            postToUpdate = post
            wfPost.postId = post.postId

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
        if !hasNetworkConnection {
            DispatchQueue.main.async { self.isPresentingNetworkErrorAlert = true }
            return
        }
        guard let loggedInClient = client else {
            self.currentError = AppError.couldNotGetLoggedInClient
            return
        }
        guard let postId = post.postId else {
            self.currentError = AppError.couldNotGetPostId
            return
        }
        // We're starting the network request.
        DispatchQueue.main.async {
            self.selectedPost = post
            self.isProcessingRequest = true
        }
        loggedInClient.getPost(byId: postId, completion: updateFromServerHandler)
    }

    func move(post: WFAPost, from oldCollection: WFACollection?, to newCollection: WFACollection?) {
        if !hasNetworkConnection {
            DispatchQueue.main.async { self.isPresentingNetworkErrorAlert = true }
            return
        }
        guard let loggedInClient = client else {
            self.currentError = AppError.couldNotGetLoggedInClient
            return
        }
        guard let postId = post.postId else {
            self.currentError = AppError.couldNotGetPostId
            return
        }
        // We're starting the network request.
        DispatchQueue.main.async {
            self.isProcessingRequest = true
        }

        selectedPost = post
        post.collectionAlias = newCollection?.alias
        loggedInClient.movePost(postId: postId, to: newCollection?.alias, completion: movePostHandler)
    }
}
