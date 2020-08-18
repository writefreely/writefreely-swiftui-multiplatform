import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var model: WriteFreelyModel

    @Binding var isPresented: Bool

    var body: some View {
        VStack {
            SettingsHeaderView(isPresented: $isPresented)
            Form {
                Section(header: Text("Login Details")) {
                    AccountView()
                }
                Section(header: Text("Appearance")) {
                    PreferencesView(preferences: model.preferences)
                }
            }
        }
//        .preferredColorScheme(preferences.selectedColorScheme)    // See PreferencesModel for info.
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(isPresented: .constant(true))
            .environmentObject(WriteFreelyModel())
    }
}
