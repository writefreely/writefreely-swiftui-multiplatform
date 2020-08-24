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
    private let defaults = UserDefaults.standard

    init() {
        // Set the color scheme based on what's been saved in UserDefaults.
        DispatchQueue.main.async {
            self.preferences.appearance = self.defaults.integer(forKey: self.preferences.colorSchemeIntegerKey)
        }

        #if DEBUG
        for post in testPostData { store.add(post) }
        #endif
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
        guard let loggedInClient = client else { return }
        loggedInClient.logout(completion: logoutHandler)
    }
}

private extension WriteFreelyModel {
    func loginHandler(result: Result<WFUser, Error>) {
        DispatchQueue.main.async {
            self.isLoggingIn = false
        }
        do {
            let user = try result.get()
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
            client = nil
            DispatchQueue.main.async {
                self.account.logout()
            }
        } catch WFError.notFound {
            // The user token is invalid or doesn't exist, so it's been invalidated by the server. Proceed with
            // destroying the client object and setting the AccountModel to its logged-out state.
            client = nil
            DispatchQueue.main.async {
                self.account.logout()
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
}
