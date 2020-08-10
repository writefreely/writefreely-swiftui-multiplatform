import SwiftUI

struct SettingsView: View {
    @Binding var isPresented: Bool

    var body: some View {
        VStack {
            SettingsHeaderView(isPresented: $isPresented)
            Form {
                Section(header: Text("Account")) {
                    AccountView()
                }
                Section(header: Text("Appearance")) {
                    PreferencesView()
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(isPresented: .constant(true))
    }
}
