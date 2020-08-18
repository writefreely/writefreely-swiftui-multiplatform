import Foundation
import WriteFreely

// MARK: - WriteFreelyModel

class WriteFreelyModel: ObservableObject {
    @Published var account = AccountModel()
    @Published var preferences = PreferencesModel()
    @Published var store = PostStore()
    @Published var post: Post?
    @Published var isLoggingIn: Bool = false

    private var client: WFClient?

    init() {
        #if DEBUG
        for post in testPostData { store.add(post) }
        #endif
    }
}

// MARK: - WriteFreelyModel API

extension WriteFreelyModel {
    func login(
        to server: URL,
        as username: String,
        password: String
    ) {
        isLoggingIn = true
        account.server = server.absoluteString
        client = WFClient(for: server)
        client?.login(username: username, password: password, completion: loginHandler)
    }

    func logout () {
        guard let loggedInClient = client else { return }
        loggedInClient.logout(completion: logoutHandler)
    }
}

private extension WriteFreelyModel {
    func loginHandler(result: Result<WFUser, Error>) {
        isLoggingIn = false
        do {
            let user = try result.get()
            account.login(user)
            dump(user)
        } catch {
            dump(error)
        }
    }

    func logoutHandler(result: Result<Bool, Error>) {
        do {
            let loggedOut = try result.get()
            if loggedOut {
                client = nil
                account.logout()
            }
        } catch {
            dump(error)
        }
    }
}
