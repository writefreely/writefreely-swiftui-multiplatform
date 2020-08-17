import Foundation

enum AccountError: Error {
    case invalidPassword
    case usernameNotFound
    case serverNotFound
}

class AccountModel: ObservableObject {
    @Published private(set) var id: UUID?
    @Published private(set) var isLoggedIn: Bool = false
    @Published private(set) var isLoggingIn: Bool = false
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var server: String = ""

    func login(
        to server: String,
        as username: String,
        password: String,
        completion: @escaping (Result<UUID, AccountError>) -> Void
    ) {
        self.isLoggingIn = true
        let result: Result<UUID, AccountError>

        if server != validServer {
            result = .failure(.serverNotFound)
        } else if username != validCredentials["username"] {
            result = .failure(.usernameNotFound)
        } else if password != validCredentials["password"] {
            result = .failure(.invalidPassword)
        } else {
            self.id = UUID()
            self.username = username
            self.password = password
            self.server = server
            result = .success(self.id!)
        }

        #if DEBUG
        // Delay to simulate async network call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.isLoggingIn = false
            do {
                _ = try result.get()
                self.isLoggedIn = true
            } catch {
                self.isLoggedIn = false
            }
            completion(result)
        }
        #endif
    }

    func logout() {
        id = nil
        isLoggedIn = false
        isLoggingIn = false
        username = ""
        password = ""
        server = ""
    }
}

#if DEBUG
let validCredentials = [
    "username": "test-writer",
    "password": "12345"
]
let validServer = "https://test.server.url"
#endif
