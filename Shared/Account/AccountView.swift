import SwiftUI

struct AccountView: View {
    @ObservedObject var account: AccountModel

    var body: some View {
        if account.isLoggedIn {
            HStack {
                Spacer()
                AccountLogoutView(account: account)
                Spacer()
            }
            .padding()
        } else {
            AccountLoginView(account: account)
                .padding()
        }
    }
}

struct AccountLogin_Previews: PreviewProvider {
    static var previews: some View {
        AccountView(account: AccountModel())
    }
}
