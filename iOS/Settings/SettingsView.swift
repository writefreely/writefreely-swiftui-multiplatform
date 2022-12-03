import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var model: WriteFreelyModel

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

    private func didTapGenerateLogPostButton() {
        logger.log("Generating local log post...")

        DispatchQueue.main.asyncAfter(deadline: .now()) {
            // Unset selected post and collection and navigate to local drafts.
            self.model.selectedPost = nil
            self.model.selectedCollection = nil
            self.model.showAllPosts = false

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
