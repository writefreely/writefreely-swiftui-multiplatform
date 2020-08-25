import SwiftUI

struct MacAccountView: View {
    @EnvironmentObject var model: WriteFreelyModel

    var body: some View {
            Form {
                Section(header: Text("Login Details")) {
                    AccountView()
                }
            }
    }
}

struct MacAccountView_Previews: PreviewProvider {
    static var previews: some View {
        MacAccountView()
            .environmentObject(WriteFreelyModel())
    }
}
