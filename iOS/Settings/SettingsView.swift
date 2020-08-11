import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var preferences: PreferencesModel
    @EnvironmentObject var account: AccountModel

    @Binding var isPresented: Bool

    var body: some View {
        VStack {
            SettingsHeaderView(isPresented: $isPresented)
            Form {
                Section(header: Text("Login Details")) {
                    AccountView(account: account)
                }
                Section(header: Text("Appearance")) {
                    PreferencesView(preferences: preferences)
                }
            }
        }
        .preferredColorScheme(preferences.preferredColorScheme)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(isPresented: .constant(true))
    }
}
