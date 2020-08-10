import SwiftUI

struct SettingsView: View {
    var body: some View {
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

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
