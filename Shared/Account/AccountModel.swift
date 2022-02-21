import SwiftUI
import WriteFreely

struct AccountModel {
    @AppStorage(WFDefaults.isLoggedIn, store: UserDefaults.shared) var isLoggedIn: Bool = false
    private let defaults = UserDefaults.shared

    var server: String = ""
    var username: String = ""

    private(set) var user: WFUser?

    mutating func login(_ user: WFUser) {
        self.user = user
        self.username = user.username ?? ""
        self.isLoggedIn = true
        defaults.set(user.username, forKey: WFDefaults.usernameStringKey)
        defaults.set(server, forKey: WFDefaults.serverStringKey)
    }

    mutating func logout() {
        self.user = nil
        self.isLoggedIn = false
        defaults.removeObject(forKey: WFDefaults.usernameStringKey)
        defaults.removeObject(forKey: WFDefaults.serverStringKey)
    }

    mutating func restoreState() {
        server = defaults.string(forKey: WFDefaults.serverStringKey) ?? ""
        username = defaults.string(forKey: WFDefaults.usernameStringKey) ?? ""
    }
}
