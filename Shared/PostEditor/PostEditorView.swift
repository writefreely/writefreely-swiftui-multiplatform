import SwiftUI

struct PostEditorView: View {
    @EnvironmentObject var model: WriteFreelyModel

    @ObservedObject var post: WFAPost

    var body: some View {
        VStack {
            switch post.appearance {
            case "sans":
                TextEditor(text: $post.title)
                    .font(.custom("OpenSans-Regular", size: 26, relativeTo: Font.TextStyle.largeTitle))
                    .frame(height: 100)
                    .onChange(of: post.title) { _ in
                        if post.status == PostStatus.published.rawValue {
                            post.status = PostStatus.edited.rawValue
                        }
                    }
                TextEditor(text: $post.body)
                    .font(.custom("OpenSans-Regular", size: 17, relativeTo: Font.TextStyle.body))
                    .onChange(of: post.body) { _ in
                        if post.status == PostStatus.published.rawValue {
                            post.status = PostStatus.edited.rawValue
                        }
                    }
            case "wrap", "mono", "code":
                TextEditor(text: $post.title)
                    .font(.custom("Hack", size: 26, relativeTo: Font.TextStyle.largeTitle))
                    .frame(height: 100)
                    .onChange(of: post.title) { _ in
                        if post.status == PostStatus.published.rawValue {
                            post.status = PostStatus.edited.rawValue
                        }
                    }
                TextEditor(text: $post.body)
                    .font(.custom("Hack", size: 17, relativeTo: Font.TextStyle.body))
                    .onChange(of: post.body) { _ in
                        if post.status == PostStatus.published.rawValue {
                            post.status = PostStatus.edited.rawValue
                        }
                    }
            default:
                TextEditor(text: $post.title)
                    .font(.custom("Lora", size: 26, relativeTo: Font.TextStyle.largeTitle))
                    .frame(height: 100)
                    .onChange(of: post.title) { _ in
                        if post.status == PostStatus.published.rawValue {
                            post.status = PostStatus.edited.rawValue
                        }
                    }
                TextEditor(text: $post.body)
                    .font(.custom("Lora", size: 17, relativeTo: Font.TextStyle.body))
                    .onChange(of: post.body) { _ in
                        if post.status == PostStatus.published.rawValue {
                            post.status = PostStatus.edited.rawValue
                        }
                    }
            }
        }
        .padding()
        .toolbar {
            ToolbarItem(placement: .principal) {
                PostEditorStatusToolbarView(post: post)
            }
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    publishPost()
                }, label: {
                    Image(systemName: "paperplane")
                })
                .disabled(
                    post.status == PostStatus.published.rawValue ||
                        !model.account.isLoggedIn ||
                        !model.hasNetworkConnection
                )
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

    private func publishPost() {
        DispatchQueue.main.async {
            LocalStorageManager().saveContext()
            model.posts.loadCachedPosts()
            model.publish(post: post)
        }
    }
}

struct PostEditorView_Previews: PreviewProvider {
    static var previews: some View {
        let context = LocalStorageManager.persistentContainer.viewContext
        let testPost = WFAPost(context: context)
        testPost.title = "Test Post Title"
        testPost.body = "Here's some cool sample body text."
        testPost.createdDate = Date()
        testPost.appearance = "code"

        let model = WriteFreelyModel()

        return PostEditorView(post: testPost)
            .environment(\.managedObjectContext, context)
            .environmentObject(model)
    }
}
