import SwiftUI

struct MacAccountView: View {
    @ObservedObject var account: AccountModel

    var body: some View {
            Form {
                Section(header: Text("Login Details")) {
                    AccountView(account: account)
                }
            }
    }
}

struct MacAccountView_Previews: PreviewProvider {
    static var previews: some View {
        MacAccountView(account: AccountModel())
    }
}
