import Foundation
import WriteFreely

enum AccountError: Error {
    case invalidPassword
    case usernameNotFound
    case serverNotFound
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
