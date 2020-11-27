import SwiftUI

struct ActivePostToolbarView: View {
    @EnvironmentObject var model: WriteFreelyModel
    @ObservedObject var activePost: WFAPost

    var body: some View {
        HStack(spacing: 16) {
            PostEditorStatusToolbarView(post: activePost)
            HStack(spacing: 4) {
                Button(action: { publishPost(activePost) }, label: { Image(systemName: "paperplane") })
                    .disabled(activePost.body.isEmpty || activePost.status == PostStatus.published.rawValue)
                Button(action: {}, label: { Image(systemName: "square.and.arrow.up") })
                    .disabled(activePost.status == PostStatus.local.rawValue)
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
