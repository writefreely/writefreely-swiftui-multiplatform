import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var model: WriteFreelyModel

    var body: some View {
        VStack {
            SettingsHeaderView()
            Form {
                Section(header: Text("Login Details")) {
                    AccountView()
                        .withErrorHandling()
                }
                Section(header: Text("Appearance")) {
                    PreferencesView(preferences: model.preferences)
                }
                Section(header: Text("External Links")) {
                    HStack {
                        Spacer()
                        Link("View the Guide", destination: model.howToURL)
                        Spacer()
                    }
                    HStack {
                        Spacer()
                        Link("Visit the Help Forum", destination: model.helpURL)
                        Spacer()
                    }
                    HStack {
                        Spacer()
                        Link("Write a Review on the App Store", destination: model.reviewURL)
                        Spacer()
                    }
                }
                Section(header: Text("Acknowledgements")) {
                        VStack {
                            VStack(alignment: .leading) {
                                Text("This application makes use of the following open-source projects:")
                                    .padding(.bottom)
                                Text("• Lora typeface")
                                    .padding(.leading)
                                Text("• Open Sans typeface")
                                    .padding(.leading)
                                Text("• Hack typeface")
                                    .padding(.leading)
                            }
                            .padding(.bottom)
                            .foregroundColor(.secondary)
                            HStack {
                                Spacer()
                                Link("View the licenses", destination: model.licensesURL)
                                Spacer()
                            }
                        }
                        .padding()
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
