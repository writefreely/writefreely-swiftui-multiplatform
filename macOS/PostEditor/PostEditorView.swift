import SwiftUI

struct PostEditorView: View {
    private let bodyLineSpacing: CGFloat = 17 * 0.5
    @EnvironmentObject var model: WriteFreelyModel

    @ObservedObject var post: WFAPost
    @State private var isHovering: Bool = false
    @State private var updatingFromServer: Bool = false

    var body: some View {
        PostTextEditingView(
            post: post,
            updatingFromServer: $updatingFromServer
        )
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .toolbar {
            ToolbarItem(placement: .status) {
                PostEditorStatusToolbarView(post: post)
            }
            ToolbarItem(placement: .primaryAction) {
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
                .disabled(post.status == PostStatus.published.rawValue || post.body.count == 0)
            }
        }
        .onChange(of: post.hasNewerRemoteCopy, perform: { _ in
            if !post.hasNewerRemoteCopy {
                self.updatingFromServer = true
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
