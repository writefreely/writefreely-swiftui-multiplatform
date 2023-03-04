import SwiftUI

struct PostCommands: Commands {
    @ObservedObject var model: WriteFreelyModel

    var body: some Commands {
        CommandMenu("Post") {
            Button("Find In Posts") {
                if let toolbar = NSApp.keyWindow?.toolbar,
                   let search = toolbar.items.first(where: {
                       $0.itemIdentifier.rawValue == "com.apple.SwiftUI.search"
                   }) as? NSSearchToolbarItem {
                    search.beginSearchInteraction()
                }
            }
            .keyboardShortcut("f", modifiers: [.command, .shift])

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
