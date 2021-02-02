import SwiftUI
import WriteFreely

enum AccountError: Error {
    case invalidPassword
    case usernameNotFound
    case serverNotFound
    case invalidServerURL
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
        case .invalidServerURL:
            return NSLocalizedString(
                "The server entered doesn't appear to be a valid URL. Please check what you've entered and try again.",
                comment: ""
            )
        }
    }
}

struct AccountModel {
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    private let defaults = UserDefaults.standard
    let usernameStringKey = "usernameStringKey"
    let serverStringKey = "serverStringKey"

    var server: String = ""
    var username: String = ""

    private(set) var user: WFUser?

    mutating func login(_ user: WFUser) {
        self.user = user
        self.username = user.username ?? ""
        self.isLoggedIn = true
        defaults.set(user.username, forKey: usernameStringKey)
        defaults.set(server, forKey: serverStringKey)
    }

    mutating func logout() {
        self.user = nil
        self.isLoggedIn = false
        defaults.removeObject(forKey: usernameStringKey)
        defaults.removeObject(forKey: serverStringKey)
    }

    mutating func restoreState() {
        server = defaults.string(forKey: serverStringKey) ?? ""
        username = defaults.string(forKey: usernameStringKey) ?? ""
    }
}
