import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var model: WriteFreelyModel

    var body: some View {
        VStack {
            SettingsHeaderView()
            Form {
                Section(header: Text("Login Details")) {
                    AccountView()
                }
                Section(header: Text("Appearance")) {
                    PreferencesView(preferences: model.preferences)
                }
                Section(header: Text("Support")) {
                    HStack {
                        Spacer()
                        Link("Visit Help Forum", destination: model.helpURL)
                        Spacer()
                    }
                }
            }
        }
//        .preferredColorScheme(preferences.selectedColorScheme)    // See PreferencesModel for info.
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(WriteFreelyModel())
    }
}
