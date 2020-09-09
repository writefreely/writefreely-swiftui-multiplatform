import SwiftUI

struct PostEditorView: View {
    @EnvironmentObject var model: WriteFreelyModel

    @ObservedObject var post: WFAPost

    var body: some View {
        VStack {
            TextEditor(text: $post.title)
                .font(.title)
                .frame(height: 100)
                .onChange(of: post.title) { _ in
                    if post.status == PostStatus.published.rawValue {
                        post.status = PostStatus.edited.rawValue
                    }
                }
            TextEditor(text: $post.body)
                .font(.body)
                .onChange(of: post.body) { _ in
                    if post.status == PostStatus.published.rawValue {
                        post.status = PostStatus.edited.rawValue
                    }
                }
        }
        .padding()
        .toolbar {
            ToolbarItem(placement: .status) {
                PostEditorStatusToolbarView(post: post)
            }
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    model.publish(post: post)
                    post.status = PostStatus.published.rawValue
                }, label: {
                    Image(systemName: "paperplane")
                })
            }
        }
        .onChange(of: post.hasNewerRemoteCopy, perform: { _ in
            if post.status == PostStatus.edited.rawValue && !post.hasNewerRemoteCopy {
                post.status = PostStatus.published.rawValue
            }
        })
        .onDisappear(perform: {
            if post.status == PostStatus.edited.rawValue {
                DispatchQueue.main.async {
                    PersistenceManager().saveContext()
                }
            }
        })
    }
}

//struct PostEditorView_NewLocalDraftPreviews: PreviewProvider {
//    static var previews: some View {
//        PostEditorView(post: Post())
//            .environmentObject(WriteFreelyModel())
//    }
//}
//
//struct PostEditorView_NewerLocalPostPreviews: PreviewProvider {
//    static var previews: some View {
//        return PostEditorView(post: testPost)
//            .environmentObject(WriteFreelyModel())
//    }
//}
//
//struct PostEditorView_NewerRemotePostPreviews: PreviewProvider {
//    static var previews: some View {
//        let newerRemotePost = Post(
//            title: testPost.wfPost.title ?? "",
//            body: testPost.wfPost.body,
//            createdDate: testPost.wfPost.createdDate ?? Date(),
//            status: testPost.status,
//            collection: testPost.collection
//        )
//        newerRemotePost.hasNewerRemoteCopy = true
//        return PostEditorView(post: newerRemotePost)
//            .environmentObject(WriteFreelyModel())
//    }
//}
