import SwiftUI

struct SettingsView: View {

    @EnvironmentObject var model: WriteFreelyModel
    @State private var isShowingAlert = false

    private let logger = Logging(for: String(describing: SettingsView.self))

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
                Section(header: Text("Help and Support")) {
                    Link("View the Guide", destination: model.howToURL)
                    Link("Visit the Help Forum", destination: model.helpURL)
                    Link("Write a Review on the App Store", destination: model.reviewURL)
                    if #available(iOS 15.0, *) {
                        VStack(alignment: .leading, spacing: 8) {
                            Button(
                                action: didTapGenerateLogPostButton,
                                label: {
                                    Text("Create Log Post")
                                }
                            )
                            Text("Generates a local post using recent logs. You can share this for troubleshooting.")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
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
        .alert(isPresented: $isShowingAlert) {
            Alert(
                title: Text("Log Post Created"),
                message: Text("Check your local drafts for app logs from the past 24 hours.")
            )
        }
//        .preferredColorScheme(preferences.selectedColorScheme)    // See PreferencesModel for info.
    }

    @available(iOS 15, *)
    private func didTapGenerateLogPostButton() {
        logger.log("Generating local log post...")

        DispatchQueue.main.asyncAfter(deadline: .now()) {
            // Unset selected post and collection and navigate to local drafts.
            self.model.navState.selectedPost = nil
            self.model.navState.selectedCollection = nil
            self.model.navState.showAllPosts = false

            // Create the new log post.
            let newLogPost = model.editor.generateNewLocalPost(withFont: 2)
            newLogPost.title = "Logs For Support"
            var postBody: [String] = [
                "WriteFreely-Multiplatform v\(Bundle.main.appMarketingVersion) (\(Bundle.main.appBuildVersion))",
                "Generated \(Date())",
                ""
            ]
            postBody.append(contentsOf: logger.fetchLogs())
            newLogPost.body = postBody.joined(separator: "\n")

            self.isShowingAlert = true
        }

        logger.log("Generated local log post.")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(WriteFreelyModel())
    }
}
