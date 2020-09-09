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
            if post.status < PostStatus.published.rawValue {
                DispatchQueue.main.async {
                    LocalStorageManager().saveContext()
                }
            }
        })
    }
}

struct PostEditorView_Previews: PreviewProvider {
    static var previews: some View {
        let context = LocalStorageManager.persistentContainer.viewContext
        let testPost = WFAPost(context: context)
        testPost.title = "Test Post Title"
        testPost.body = "Here's some cool sample body text."
        testPost.createdDate = Date()

        let model = WriteFreelyModel()

        return PostEditorView(post: testPost)
            .environment(\.managedObjectContext, context)
            .environmentObject(model)
    }
}
