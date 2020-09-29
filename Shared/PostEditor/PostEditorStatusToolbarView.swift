import SwiftUI

struct PostEditorStatusToolbarView: View {
    @EnvironmentObject var model: WriteFreelyModel

    @ObservedObject var post: WFAPost

    var body: some View {
        if post.hasNewerRemoteCopy {
            #if os(iOS)
            PostStatusBadgeView(post: post)
            #else
            HStack {
                PostStatusBadgeView(post: post)
                    .padding(.trailing)
                Text("⚠️ Newer copy on server. Replace local copy?")
                    .font(.callout)
                    .foregroundColor(.secondary)
                Button(action: {
                    model.updateFromServer(post: post)
                }, label: {
                    Image(systemName: "square.and.arrow.down")
                })
            }
            #endif
        } else if post.wasDeletedFromServer && post.status != PostStatus.local.rawValue {
            #if os(iOS)
            PostStatusBadgeView(post: post)
            #else
            HStack {
                PostStatusBadgeView(post: post)
                    .padding(.trailing)
                Text("⚠️ Post deleted from server. Delete local copy?")
                    .font(.callout)
                    .foregroundColor(.secondary)
                Button(action: {
                    model.selectedPost = nil
                    model.posts.remove(post)
                }, label: {
                    Image(systemName: "trash")
                })
            }
            #endif
        } else {
            PostStatusBadgeView(post: post)
        }
    }
}

struct PESTView_StandardPreviews: PreviewProvider {
    static var previews: some View {
        let context = LocalStorageManager.persistentContainer.viewContext
        let model = WriteFreelyModel()
        let testPost = WFAPost(context: context)
        testPost.status = PostStatus.published.rawValue

        return PostEditorStatusToolbarView(post: testPost)
            .environmentObject(model)
    }
}

struct PESTView_OutdatedLocalCopyPreviews: PreviewProvider {
    static var previews: some View {
        let context = LocalStorageManager.persistentContainer.viewContext
        let model = WriteFreelyModel()
        let updatedPost = WFAPost(context: context)
        updatedPost.status = PostStatus.published.rawValue
        updatedPost.hasNewerRemoteCopy = true

        return PostEditorStatusToolbarView(post: updatedPost)
            .environmentObject(model)
    }
}

struct PESTView_DeletedRemoteCopyPreviews: PreviewProvider {
    static var previews: some View {
        let context = LocalStorageManager.persistentContainer.viewContext
        let model = WriteFreelyModel()
        let deletedPost = WFAPost(context: context)
        deletedPost.status = PostStatus.published.rawValue
        deletedPost.wasDeletedFromServer = true

        return PostEditorStatusToolbarView(post: deletedPost)
            .environmentObject(model)
    }
}
