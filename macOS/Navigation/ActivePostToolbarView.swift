import SwiftUI

struct ActivePostToolbarView: View {
    @EnvironmentObject var model: WriteFreelyModel
    @ObservedObject var activePost: WFAPost

    var body: some View {
        HStack(spacing: 16) {
            PostEditorStatusToolbarView(post: activePost)
            HStack(spacing: 4) {
                Button(action: {}, label: { Image(systemName: "square.and.arrow.up") })
                    .disabled(activePost.status == PostStatus.local.rawValue)
                    .help("Copy the post's URL to your Mac's pasteboard.")
                Button(action: { publishPost(activePost) }, label: { Image(systemName: "paperplane") })
                    .disabled(activePost.body.isEmpty || activePost.status == PostStatus.published.rawValue)
                    .help("Publish the post to the web.\(model.account.isLoggedIn ? "" : "You must be logged in to do this.")") // swiftlint:disable:this line_length
            }
        }
    }

    private func publishPost(_ post: WFAPost) {
        DispatchQueue.main.async {
            LocalStorageManager().saveContext()
            model.publish(post: post)
        }
    }
}
