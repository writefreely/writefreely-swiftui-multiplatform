import SwiftUI

struct PostEditorView: View {
    @EnvironmentObject var model: WriteFreelyModel

    @ObservedObject var post: WFAPost
    @State private var isHovering: Bool = false
    @State private var didCopyUrlToPasteboard: Bool = false

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
            ToolbarItemGroup(placement: .primaryAction) {
                Spacer()
                Button(action: {
                    if model.account.isLoggedIn {
                        publishPost()
                    } else {
                        let mainMenu = NSApplication.shared.mainMenu
                        let appMenuItem = mainMenu?.item(withTitle: "WriteFreely")
                        let prefsItem = appMenuItem?.submenu?.item(withTitle: "Preferences…")
                        NSApplication.shared.sendAction(prefsItem!.action!, to: prefsItem?.target, from: nil)
                    }
                }, label: {
                    Image(systemName: "paperplane")
                })
                .help("Publish the post to the web. You must be logged in to do this.")
                .disabled(
                    post.status == PostStatus.published.rawValue || !model.hasNetworkConnection || post.body.count == 0
                )
                Button(action: {
                        sharePost()
                }, label: {
                    Image(systemName: "square.and.arrow.up")
                })
                .help("Copy the post's URL to your Mac's pasteboard.")
                .disabled(post.postId == nil)
                .alert(isPresented: $didCopyUrlToPasteboard) {
                    Alert(
                        title: Text("Copied post URL to the pasteboard."),
                        message: nil,
                        dismissButton: .default(Text("OK"))
                    )
                }
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
                DispatchQueue.main.async {
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
    }

    private func sharePost() {
        guard let urlString = model.selectedPost?.slug != nil ?
                "\(model.account.server)/\((model.selectedPost?.collectionAlias)!)/\((model.selectedPost?.slug)!)" :
                "\(model.account.server)/\((model.selectedPost?.postId)!)" else { return }
        // guard let data = URL(string: urlString) else { return }
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        didCopyUrlToPasteboard = pasteboard.setString(urlString, forType: .string)
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
