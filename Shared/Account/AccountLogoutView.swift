import SwiftUI

struct AccountLogoutView: View {
    @ObservedObject var account: AccountModel

    var body: some View {
        VStack {
            Spacer()
            VStack {
                Text("Logged in as \(account.username)")
                Text("on \(account.server)")
            }
            Spacer()
            Button(action: logoutHandler, label: {
                Text("Logout")
            })
        }
    }

    func logoutHandler() {
        account.logout()
    }
}

struct AccountLogoutView_Previews: PreviewProvider {
    static var previews: some View {
        AccountLogoutView(account: AccountModel())
    }
}
