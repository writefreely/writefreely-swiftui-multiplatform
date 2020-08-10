import SwiftUI

struct AccountLogoutView: View {
    @Binding var accountModel: AccountModel
    @Binding var isLoggedIn: Bool
    @Binding var isLoggingIn: Bool

    var body: some View {
        VStack {
            Spacer()
            VStack {
                Text("Logged in as \(accountModel.username ?? "UNKNOWN")")
                Text("on \(accountModel.server ?? "UNKNOWN")")
            }
            Spacer()
            Button(action: logoutHandler, label: {
                Text("Logout")
            })
        }
    }

    func logoutHandler() {
        isLoggedIn = false
        isLoggingIn = false
    }
}

struct AccountLogoutView_Previews: PreviewProvider {
    static var previews: some View {
        AccountLogoutView(
            accountModel: .constant(AccountModel()),
            isLoggedIn: .constant(true),
            isLoggingIn: .constant(false)
        )
    }
}
