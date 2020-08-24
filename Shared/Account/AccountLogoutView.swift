import SwiftUI

struct AccountLogoutView: View {
    @EnvironmentObject var model: WriteFreelyModel

    var body: some View {
        VStack {
            Spacer()
            VStack {
                Text("Logged in as \(model.account.username ?? "Anonymous")")
                Text("on \(model.account.server)")
            }
            Spacer()
            Button(action: logoutHandler, label: {
                Text("Logout")
            })
        }
    }

    func logoutHandler() {
        model.logout()
    }
}

struct AccountLogoutView_Previews: PreviewProvider {
    static var previews: some View {
        AccountLogoutView()
            .environmentObject(WriteFreelyModel())
    }
}
