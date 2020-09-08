import SwiftUI

struct PostEditorView: View {
    @EnvironmentObject var model: WriteFreelyModel
    @Environment(\.managedObjectContext) var moc

    @ObservedObject var post: WFAPost

    @State private var postTitle = ""
    @State private var postBody = ""

    var body: some View {
        VStack {
            TextEditor(text: $postTitle)
                .font(.title)
                .frame(height: 100)
                .onChange(of: postTitle) { _ in
                    if post.status == PostStatus.published.rawValue && post.title != postTitle {
                        post.status = PostStatus.edited.rawValue
                    }
                    post.title = postTitle
                }
            TextEditor(text: $postBody)
                .font(.body)
                .onChange(of: postBody) { _ in
                    if post.status == PostStatus.published.rawValue {
                        post.status = PostStatus.edited.rawValue
                    }
                    post.body = postBody
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
        .onAppear(perform: {
            postTitle = post.title ?? ""
            postBody = post.body ?? ""
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
