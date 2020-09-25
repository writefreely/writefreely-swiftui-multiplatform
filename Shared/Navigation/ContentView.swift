import SwiftUI

struct ContentView: View {
    @EnvironmentObject var model: WriteFreelyModel

    #if os(iOS)
    let didFinishLaunchingNotification = UIApplication.didFinishLaunchingNotification
    let didBecomeActiveNotification = UIApplication.didBecomeActiveNotification
    #elseif os(macOS)
    let didFinishLaunchingNotification = NSApplication.didFinishLaunchingNotification
    let didBecomeActiveNotification = NSApplication.didBecomeActiveNotification
    #endif

    var body: some View {
        NavigationView {
            SidebarView()

            PostListView(selectedCollection: nil, showAllPosts: true)

            Text("Select a post, or create a new local draft.")
                .foregroundColor(.secondary)
        }
        .onReceive(NotificationCenter.default.publisher(for: didFinishLaunchingNotification)) { _ in
            #if os(macOS)
            launchToEditor()
            #endif
        }
        .onReceive(NotificationCenter.default.publisher(for: didBecomeActiveNotification)) { _ in
            launchToEditor()
        }
        .onAppear {
            #if os(iOS)
            launchToEditor()
            #endif
        }
        .environmentObject(model)
        .alert(isPresented: $model.isPresentingDeleteAlert) {
            Alert(
                title: Text("Delete Post?"),
                message: Text("This action cannot be undone."),
                primaryButton: .destructive(Text("Delete"), action: {
                    if let postToDelete = model.postToDelete {
                        model.selectedPost = nil
                        withAnimation {
                            model.posts.remove(postToDelete)
                        }
                        model.postToDelete = nil
                    }
                }),
                secondaryButton: .cancel() {
                    model.postToDelete = nil
                }
            )
        }

        #if os(iOS)
        EmptyView()
            .sheet(
                isPresented: $model.isPresentingSettingsView,
                onDismiss: { model.isPresentingSettingsView = false },
                content: {
                    SettingsView()
                        .environmentObject(model)
                }
            )
        #endif
    }

    private func launchToEditor() {
        if let lastDraft = self.model.editor.fetchLastDraft() {
            DispatchQueue.main.async {
                model.selectedPost = lastDraft
            }
        } else {
            let managedPost = WFAPost(context: LocalStorageManager.persistentContainer.viewContext)
            managedPost.createdDate = Date()
            managedPost.title = ""
            managedPost.body = ""
            managedPost.status = PostStatus.local.rawValue
            switch self.model.preferences.font {
            case 1:
                managedPost.appearance = "sans"
            case 2:
                managedPost.appearance = "wrap"
            default:
                managedPost.appearance = "serif"
            }
            if let languageCode = Locale.current.languageCode {
                managedPost.language = languageCode
                managedPost.rtl = Locale.characterDirection(forLanguage: languageCode) == .rightToLeft
            }
            DispatchQueue.main.async {
                model.selectedPost = managedPost
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let context = LocalStorageManager.persistentContainer.viewContext
        let model = WriteFreelyModel()

        return ContentView()
            .environment(\.managedObjectContext, context)
            .environmentObject(model)
    }
}
