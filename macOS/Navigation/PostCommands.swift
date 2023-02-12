import SwiftUI

struct PostCommands: Commands {
    @ObservedObject var model: WriteFreelyModel

    private let logger = Logging(for: String(describing: PostCommands.self))

    var body: some Commands {
        CommandMenu("Post") {
            Group {
                Button(action: sendPostUrlToPasteboard, label: { Text("Copy Link To Published Post") })
                    .disabled(model.selectedPost?.status == PostStatus.local.rawValue)
            }
            .disabled(model.selectedPost == nil || !model.account.isLoggedIn)

            Button(action: createLogsPost, label: { Text("Create Log Post") })
        }
    }

    private func sendPostUrlToPasteboard() {
        guard let activePost = model.selectedPost else { return }
        guard let postId = activePost.postId else { return }
        guard let urlString = activePost.slug != nil ?
                "\(model.account.server)/\((activePost.collectionAlias)!)/\((activePost.slug)!)" :
                "\(model.account.server)/\((postId))" else { return }
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(urlString, forType: .string)
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
