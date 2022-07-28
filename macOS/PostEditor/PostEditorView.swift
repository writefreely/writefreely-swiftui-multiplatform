import SwiftUI

struct PostEditorView: View {
    @EnvironmentObject var model: WriteFreelyModel
    @EnvironmentObject var errorHandling: ErrorHandling

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
        .onAppear(perform: {
            if post.status != PostStatus.published.rawValue {
                DispatchQueue.main.async {
                    self.model.editor.saveLastDraft(post)
                }
            } else {
                self.model.editor.clearLastDraft()
            }
        })
        .onChange(of: post.hasNewerRemoteCopy, perform: { _ in
            if !post.hasNewerRemoteCopy {
                self.updatingFromServer = true
            }
        })
        .onChange(of: post.status, perform: { value in
            if value != PostStatus.published.rawValue {
                self.model.editor.saveLastDraft(post)
            } else {
                self.model.editor.clearLastDraft()
            }
            DispatchQueue.main.async {
                LocalStorageManager.standard.saveContext()
            }
        })
        .onChange(of: model.hasError) { value in
            if value {
                if let error = model.currentError {
                    self.errorHandling.handle(error: error)
                } else {
                    self.errorHandling.handle(error: AppError.genericError())
                }
                model.hasError = false
            }
        }
        .onDisappear(perform: {
            DispatchQueue.main.async {
                model.editor.clearLastDraft()
            }
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
                    LocalStorageManager.standard.saveContext()
                }
            }
        })
    }
}

struct PostEditorView_EmptyPostPreviews: PreviewProvider {
    static var previews: some View {
        let context = LocalStorageManager.standard.container.viewContext
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
        let context = LocalStorageManager.standard.container.viewContext
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
