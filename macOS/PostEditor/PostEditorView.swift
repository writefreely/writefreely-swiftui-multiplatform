import SwiftUI

struct PostEditorView: View {
    @EnvironmentObject var model: WriteFreelyModel

    @ObservedObject var post: WFAPost
    @State private var isHovering: Bool = false

    var body: some View {
        VStack {
            switch post.appearance {
            case "sans":
                TextField("Title (optional)", text: $post.title)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(.bottom)
                    .font(.custom("OpenSans-Regular", size: 26, relativeTo: Font.TextStyle.largeTitle))
                    .onChange(of: post.title) { _ in
                        if post.status == PostStatus.published.rawValue {
                            post.status = PostStatus.edited.rawValue
                        }
                    }
                ZStack(alignment: .topLeading) {
                    if post.body.count == 0 {
                        Text("Write...")
                            .foregroundColor(Color(NSColor.placeholderTextColor))
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .font(.custom("OpenSans-Regular", size: 17, relativeTo: Font.TextStyle.body))
                    }
                    TextEditor(text: $post.body)
                        .font(.custom("OpenSans-Regular", size: 17, relativeTo: Font.TextStyle.body))
                        .opacity(post.body.count == 0 && !isHovering ? 0.0 : 1.0)
                        .onChange(of: post.body) { _ in
                            if post.status == PostStatus.published.rawValue {
                                post.status = PostStatus.edited.rawValue
                            }
                        }
                        .onHover(perform: { hovering in
                            self.isHovering = hovering
                        })
                }
                .background(Color(NSColor.controlBackgroundColor))
            case "wrap", "mono", "code":
                TextField("Title (optional)", text: $post.title)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(.bottom)
                    .font(.custom("Hack", size: 26, relativeTo: Font.TextStyle.largeTitle))
                    .onChange(of: post.title) { _ in
                        if post.status == PostStatus.published.rawValue {
                            post.status = PostStatus.edited.rawValue
                        }
                    }
                ZStack(alignment: .topLeading) {
                    if post.body.count == 0 {
                        Text("Write...")
                            .foregroundColor(Color(NSColor.placeholderTextColor))
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .font(.custom("Hack", size: 17, relativeTo: Font.TextStyle.body))
                    }
                    TextEditor(text: $post.body)
                        .font(.custom("Hack", size: 17, relativeTo: Font.TextStyle.body))
                        .opacity(post.body.count == 0 && !isHovering ? 0.0 : 1.0)
                        .onChange(of: post.body) { _ in
                            if post.status == PostStatus.published.rawValue {
                                post.status = PostStatus.edited.rawValue
                            }
                        }
                        .onHover(perform: { hovering in
                            self.isHovering = hovering
                        })
                }
                .background(Color(NSColor.controlBackgroundColor))
            default:
                TextField("Title (optional)", text: $post.title)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(.bottom)
                    .font(.custom("Lora", size: 26, relativeTo: Font.TextStyle.largeTitle))
                    .onChange(of: post.title) { _ in
                        if post.status == PostStatus.published.rawValue {
                            post.status = PostStatus.edited.rawValue
                        }
                    }
                ZStack(alignment: .topLeading) {
                    if post.body.count == 0 {
                        Text("Write...")
                            .foregroundColor(Color(NSColor.placeholderTextColor))
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .font(.custom("Lora", size: 17, relativeTo: Font.TextStyle.body))
                    }
                    TextEditor(text: $post.body)
                        .font(.custom("Lora", size: 17, relativeTo: Font.TextStyle.body))
                        .opacity(post.body.count == 0 && !isHovering ? 0.0 : 1.0)
                        .onChange(of: post.body) { _ in
                            if post.status == PostStatus.published.rawValue {
                                post.status = PostStatus.edited.rawValue
                            }
                        }
                        .onHover(perform: { hovering in
                            self.isHovering = hovering
                        })
                }
                .background(Color(NSColor.controlBackgroundColor))
            }
        }
        .padding()
        .background(Color.white)
        .toolbar {
            ToolbarItem(placement: .status) {
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
        .onChange(of: post.status, perform: { _ in
            if post.status != PostStatus.published.rawValue {
                DispatchQueue.main.async {
                    model.editor.setLastDraft(post)
                }
            }
        })
        .onDisappear(perform: {
            if post.status != PostStatus.published.rawValue {
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
