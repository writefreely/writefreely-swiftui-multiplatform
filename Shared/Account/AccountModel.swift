import Foundation
import WriteFreely

enum AccountError: Error {
    case invalidPassword
    case usernameNotFound
    case serverNotFound
}

extension AccountError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .serverNotFound:
            return NSLocalizedString(
                "The server could not be found. Please check the information you've entered and try again.",
                comment: ""
            )
        case .invalidPassword:
            return NSLocalizedString(
                "Invalid password. Please check that you've entered your password correctly and try logging in again.",
                comment: ""
            )
        case .usernameNotFound:
            return NSLocalizedString(
                "Username not found. Did you use your email address by mistake?",
                comment: ""
            )
        }
    }
}

struct AccountModel {
    var server: String = ""
    private(set) var user: WFUser?
    private(set) var isLoggedIn: Bool = false

    mutating func login(_ user: WFUser) {
        self.user = user
        self.isLoggedIn = true
    }

    mutating func logout() {
        self.user = nil
        self.isLoggedIn = false
    }
}
