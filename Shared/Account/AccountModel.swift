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
    private let defaults = UserDefaults.standard
    let isLoggedInFlag = "isLoggedInFlag"
    let usernameStringKey = "usernameStringKey"
    let serverStringKey = "serverStringKey"

    var server: String = ""
    var username: String = ""
    var hasError: Bool = false
    var currentError: AccountError? {
        didSet {
            hasError = true
        }
    }
    private(set) var user: WFUser?
    private(set) var isLoggedIn: Bool = false

    mutating func login(_ user: WFUser) {
        self.user = user
        self.username = user.username ?? ""
        self.isLoggedIn = true
        defaults.set(true, forKey: isLoggedInFlag)
        defaults.set(user.username, forKey: usernameStringKey)
        defaults.set(server, forKey: serverStringKey)
    }

    mutating func logout() {
        self.user = nil
        self.isLoggedIn = false
        defaults.set(false, forKey: isLoggedInFlag)
        defaults.removeObject(forKey: usernameStringKey)
        defaults.removeObject(forKey: serverStringKey)
    }

    mutating func restoreState() {
        isLoggedIn = defaults.bool(forKey: isLoggedInFlag)
        server = defaults.string(forKey: serverStringKey) ?? ""
        username = defaults.string(forKey: usernameStringKey) ?? ""
    }
}
