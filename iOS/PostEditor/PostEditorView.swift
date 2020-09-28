import SwiftUI

struct PostEditorView: View {
    @EnvironmentObject var model: WriteFreelyModel

    @ObservedObject var post: WFAPost

    var body: some View {
        VStack {
            switch post.appearance {
            case "sans":
                TextField("Title (optional)", text: $post.title)
                    .font(.custom("OpenSans-Regular", size: 26, relativeTo: Font.TextStyle.largeTitle))
                    .onChange(of: post.title) { _ in
                        if post.status == PostStatus.published.rawValue {
                            post.status = PostStatus.edited.rawValue
                        }
                    }
                ZStack(alignment: .topLeading) {
                    if post.body.count == 0 {
                        Text("Write...")
                            .foregroundColor(Color(UIColor.placeholderText))
                            .padding(.horizontal, 4)
                            .padding(.vertical, 8)
                            .font(.custom("OpenSans-Regular", size: 17, relativeTo: Font.TextStyle.body))
                    }
                    TextEditor(text: $post.body)
                        .font(.custom("OpenSans-Regular", size: 17, relativeTo: Font.TextStyle.body))
                        .onChange(of: post.body) { _ in
                            if post.status == PostStatus.published.rawValue {
                                post.status = PostStatus.edited.rawValue
                            }
                    }
                }
            case "wrap", "mono", "code":
                TextField("Title (optional)", text: $post.title)
                    .font(.custom("Hack", size: 26, relativeTo: Font.TextStyle.largeTitle))
                    .onChange(of: post.title) { _ in
                        if post.status == PostStatus.published.rawValue {
                            post.status = PostStatus.edited.rawValue
                        }
                    }
                ZStack(alignment: .topLeading) {
                    if post.body.count == 0 {
                        Text("Write...")
                            .foregroundColor(Color(UIColor.placeholderText))
                            .padding(.horizontal, 4)
                            .padding(.vertical, 8)
                            .font(.custom("Hack", size: 17, relativeTo: Font.TextStyle.body))
                    }
                    TextEditor(text: $post.body)
                        .font(.custom("Hack", size: 17, relativeTo: Font.TextStyle.body))
                        .onChange(of: post.body) { _ in
                            if post.status == PostStatus.published.rawValue {
                                post.status = PostStatus.edited.rawValue
                            }
                    }
                }
            default:
                TextField("Title (optional)", text: $post.title)
                    .font(.custom("Lora", size: 26, relativeTo: Font.TextStyle.largeTitle))
                    .onChange(of: post.title) { _ in
                        if post.status == PostStatus.published.rawValue {
                            post.status = PostStatus.edited.rawValue
                        }
                    }
                ZStack(alignment: .topLeading) {
                    if post.body.count == 0 {
                        Text("Write...")
                            .foregroundColor(Color(UIColor.placeholderText))
                            .padding(.horizontal, 4)
                            .padding(.vertical, 8)
                            .font(.custom("Lora", size: 17, relativeTo: Font.TextStyle.body))
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
        }
        .navigationBarTitleDisplayMode(.inline)
        .padding()
        .toolbar {
            ToolbarItem(placement: .principal) {
                PostEditorStatusToolbarView(post: post)
            }
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button(action: {
                    sharePost()
                }, label: {
                    Image(systemName: "square.and.arrow.up")
                })
                .disabled(post.postId == nil)

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
        .onChange(of: post.status, perform: { _ in
            if post.status != PostStatus.published.rawValue {
                DispatchQueue.main.async {
                    model.editor.setLastDraft(post)
                }
            } else {
                DispatchQueue.main.async {
                    model.editor.clearLastDraft()
                }
            }
        })
        .onDisappear(perform: {
            if post.title.count == 0
                && post.body.count == 0
                && post.status == PostStatus.local.rawValue
                && post.updatedDate == nil
                && post.postId == nil {
                withAnimation {
                    model.posts.remove(post)
                    model.posts.loadCachedPosts()
                }
            } else if post.status != PostStatus.published.rawValue {
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
        #if os(iOS)
        self.hideKeyboard()
        #endif
    }

    private func sharePost() {
        guard let urlString = model.selectedPost?.slug != nil ?
                "\(model.account.server)/\((model.selectedPost?.collectionAlias)!)/\((model.selectedPost?.slug)!)" :
                "\(model.account.server)/\((model.selectedPost?.postId)!)" else { return }
        guard let data = URL(string: urlString) else { return }
        let activityView = UIActivityViewController(activityItems: [data], applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?.present(activityView, animated: true, completion: nil)
    }
}

struct PostEditorView_EmptyPostPreviews: PreviewProvider {
    static var previews: some View {
        let context = LocalStorageManager.persistentContainer.viewContext
        let testPost = WFAPost(context: context)
        testPost.createdDate = Date()
        testPost.appearance = "norm"

        let model = WriteFreelyModel()

        return PostEditorView(post: testPost)
            .environment(\.managedObjectContext, context)
            .environmentObject(model)
    }
}

struct PostEditorView_ExistingPostPreviews: PreviewProvider {
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
