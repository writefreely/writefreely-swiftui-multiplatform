import SwiftUI

struct PostCommands: Commands {
    @ObservedObject var model: WriteFreelyModel

    var body: some Commands {
        CommandMenu("Post") {
            Group {
                Button(action: sendPostUrlToPasteboard, label: { Text("Copy Link To Published Post") })
                    .disabled(model.selectedPost?.status == PostStatus.local.rawValue)
            }
            .disabled(model.selectedPost == nil || !model.account.isLoggedIn)
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
}
