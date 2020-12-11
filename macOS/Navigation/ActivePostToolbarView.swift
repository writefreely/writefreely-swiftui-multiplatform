import SwiftUI

struct ActivePostToolbarView: View {
    @EnvironmentObject var model: WriteFreelyModel
    @ObservedObject var activePost: WFAPost
    @State private var isPresentingSharingServicePicker: Bool = false

    var body: some View {
        HStack(spacing: 16) {
            PostEditorStatusToolbarView(post: activePost)
            HStack(spacing: 4) {
                Button(
                    action: { self.isPresentingSharingServicePicker = true },
                    label: { Image(systemName: "square.and.arrow.up") }
                )
                .disabled(activePost.status == PostStatus.local.rawValue)
                .popover(isPresented: $isPresentingSharingServicePicker) {
                    PostEditorSharingPicker(
                        isPresented: $isPresentingSharingServicePicker,
                        sharingItems: createPostUrl()
                    )
                }
                Button(action: { publishPost(activePost) }, label: { Image(systemName: "paperplane") })
                    .disabled(activePost.body.isEmpty || activePost.status == PostStatus.published.rawValue)
            }
        }
    }

    private func createPostUrl() -> [Any] {
        guard let postId = activePost.postId else { return [] }
        guard let urlString = activePost.slug != nil ?
                "\(model.account.server)/\((activePost.collectionAlias)!)/\((activePost.slug)!)" :
                "\(model.account.server)/\((postId))" else { return [] }
        guard let data = URL(string: urlString) else { return [] }
        return [data as NSURL]
    }

    private func publishPost(_ post: WFAPost) {
        DispatchQueue.main.async {
            LocalStorageManager().saveContext()
            model.publish(post: post)
        }
    }
}
