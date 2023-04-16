import SwiftUI

struct HelpCommands: Commands {
    @ObservedObject var model: WriteFreelyModel

    private let logger = Logging(for: String(describing: PostCommands.self))

    var body: some Commands {
        CommandGroup(replacing: .help) {
            Button("Visit Support Forum") {
                NSWorkspace().open(model.helpURL)
            }
            Button(action: createLogsPost, label: { Text("Generate Log for Support") })
        }
    }

    private func createLogsPost() {
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
