import Foundation

enum AccountError: Error {
    case invalidCredentials
    case serverNotFound
}

struct AccountModel {
    private(set) var id: UUID?
    var username: String?
    var password: String?
    var server: String?

    mutating func login(
        to server: String,
        as username: String,
        password: String,
        completion: @escaping (Result<UUID, AccountError>) -> Void
    ) {
        let result: Result<UUID, AccountError>

        if server != validServer {
            result = .failure(.serverNotFound)
        } else if username == validCredentials["username"] && password == validCredentials["password"] {
            self.id = UUID()
            self.username = username
            self.password = password
            self.server = server
            result = .success(self.id!)
        } else {
            result = .failure(.invalidCredentials)
        }

        #if DEBUG
        // Delay to simulate async network call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            completion(result)
        }
        #endif
    }
}

#if DEBUG
let validCredentials = [
    "username": "name@example.com",
    "password": "12345"
]
let validServer = "https://test.server.url"
#endif
