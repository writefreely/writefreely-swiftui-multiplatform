import SwiftUI

struct AccountView: View {
    @EnvironmentObject var model: WriteFreelyModel

    var body: some View {
        if model.account.isLoggedIn {
            HStack {
                Spacer()
                AccountLogoutView()
                Spacer()
            }
            .padding()
        } else {
            AccountLoginView()
                .padding(.top)
        }
    }
}

struct AccountLogin_Previews: PreviewProvider {
    static var previews: some View {
        AccountView()
            .environmentObject(WriteFreelyModel())
    }
}
