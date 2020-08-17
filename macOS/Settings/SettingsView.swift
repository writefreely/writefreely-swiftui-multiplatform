import SwiftUI

struct MacAccountView: View {
    @ObservedObject var preferences: PreferencesModel
    @ObservedObject var account: AccountModel

    @State var selectedView = 0

    var body: some View {
        TabView(selection: $selectedView) {
            Form {
                Section(header: Text("Login Details")) {
                    AccountView(account: account)
                }
            }
            .tabItem {
                Image(systemName: "person.crop.circle")
                Text("Account")
            }
            .tag(0)
            VStack {
                PreferencesView(preferences: preferences)
                Spacer()
            }
            .tabItem {
                Image(systemName: "gear")
                Text("Preferences")
            }
            .tag(1)
        }
    }
}

struct SettingsView_AccountTabPreviews: PreviewProvider {
    static var previews: some View {
        MacAccountView(preferences: PreferencesModel(), account: AccountModel(), selectedView: 0)
    }
}

struct SettingsView_PreferencesTabPreviews: PreviewProvider {
    static var previews: some View {
        MacAccountView(preferences: PreferencesModel(), account: AccountModel(), selectedView: 1)
    }
}
