import SwiftUI

struct AccountView: View {
    @State private var accountModel = AccountModel()
    @State private var isLoggingIn: Bool = false
    @State private var isLoggedIn: Bool = false

    var body: some View {
        if isLoggedIn {
            HStack {
                Spacer()
                AccountLogoutView(accountModel: $accountModel, isLoggedIn: $isLoggedIn, isLoggingIn: $isLoggingIn)
                Spacer()
            }
        } else {
            AccountLoginView(accountModel: $accountModel, isLoggedIn: $isLoggedIn, isLoggingIn: $isLoggingIn)
        }
    }
}

struct AccountLogin_Previews: PreviewProvider {
    static var previews: some View {
        AccountView()
    }
}
