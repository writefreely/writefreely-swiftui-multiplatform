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
                HStack {
                    Text("⚠️ Newer copy on server. Replace local copy?")
                        .font(.callout)
                        .foregroundColor(.secondary)
                    Button(action: {
                        model.updateFromServer(post: post)
                    }, label: {
                        Image(systemName: "square.and.arrow.down")
                    })
                    .accessibilityLabel(Text("Update post"))
                    .accessibilityHint(Text("Replace this post with the server version"))
                }
                .padding(.horizontal)
                .background(Color.primary.opacity(0.1))
                .clipShape(Capsule())
                .padding(.trailing)
                PostStatusBadgeView(post: post)
            }
            #endif
        } else if post.wasDeletedFromServer && post.status != PostStatus.local.rawValue {
            #if os(iOS)
            PostStatusBadgeView(post: post)
            #else
            HStack {
                HStack {
                    Text("⚠️ Post deleted from server. Delete local copy?")
                        .font(.callout)
                        .foregroundColor(.secondary)
                    Button(action: {
                        model.selectedPost = nil
                        DispatchQueue.main.async {
                            model.posts.remove(post)
                        }
                    }, label: {
                        Image(systemName: "trash")
                    })
                    .accessibilityLabel(Text("Delete"))
                    .accessibilityHint(Text("Delete this post from your Mac"))
                }
                .padding(.horizontal)
                .background(Color.primary.opacity(0.1))
                .clipShape(Capsule())
                .padding(.trailing)
                PostStatusBadgeView(post: post)
            }
            #endif
        } else {
            PostStatusBadgeView(post: post)
        }
    }
}

struct PESTView_StandardPreviews: PreviewProvider {
    static var previews: some View {
        let context = LocalStorageManager.standard.container.viewContext
        let model = WriteFreelyModel()
        let testPost = WFAPost(context: context)
        testPost.status = PostStatus.published.rawValue

        return PostEditorStatusToolbarView(post: testPost)
            .environmentObject(model)
    }
}

struct PESTView_OutdatedLocalCopyPreviews: PreviewProvider {
    static var previews: some View {
        let context = LocalStorageManager.standard.container.viewContext
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
        let context = LocalStorageManager.standard.container.viewContext
        let model = WriteFreelyModel()
        let deletedPost = WFAPost(context: context)
        deletedPost.status = PostStatus.published.rawValue
        deletedPost.wasDeletedFromServer = true

        return PostEditorStatusToolbarView(post: deletedPost)
            .environmentObject(model)
    }
}
