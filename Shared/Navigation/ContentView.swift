import SwiftUI

struct ContentView: View {
    @EnvironmentObject var model: WriteFreelyModel
    @Binding var sidebarIsHidden: Bool

    var body: some View {
        NavigationView {
            #if os(macOS)
            SidebarView()
                .toolbar {
                    Button(
                        action: {
                            NSApp.keyWindow?.contentViewController?.tryToPerform(
                                #selector(NSSplitViewController.toggleSidebar(_:)), with: nil
                            )
                            withAnimation { self.sidebarIsHidden.toggle() }
                        },
                        label: { Image(systemName: "sidebar.left") }
                    )
                    Spacer()
                    Button(action: {}, label: { Image(systemName: "square.and.pencil") })
                }
            #else
            SidebarView()
            #endif

            #if os(macOS)
            PostListView(selectedCollection: nil, showAllPosts: model.account.isLoggedIn)
                .toolbar {
                    ToolbarItem(placement: .navigation) {
                        Button(action: {}, label: { Image(systemName: "arrow.clockwise") })
                            .padding(.leading, sidebarIsHidden ? 8 : 0)
                            .animation(.linear)
                    }
                    ToolbarItem(placement: .status) {
                        if let selectedPost = model.selectedPost {
                            PostStatusBadgeView(post: selectedPost)
                        }
                    }
                    ToolbarItemGroup(placement: .primaryAction) {
                        if let selectedPost = model.selectedPost {
                            Button(action: {}, label: { Image(systemName: "paperplane") })
                                .disabled(selectedPost.body.isEmpty)
                            Button(action: {}, label: { Image(systemName: "square.and.arrow.up") })
                                .disabled(selectedPost.status == PostStatus.local.rawValue)
                        }
                    }
                }
            #else
            PostListView(selectedCollection: nil, showAllPosts: model.account.isLoggedIn)
            #endif

            Text("Select a post, or create a new local draft.")
                .foregroundColor(.secondary)
        }
        .environmentObject(model)
        .alert(isPresented: $model.isPresentingDeleteAlert) {
            Alert(
                title: Text("Delete Post?"),
                message: Text("This action cannot be undone."),
                primaryButton: .destructive(Text("Delete"), action: {
                    if let postToDelete = model.postToDelete {
                        model.selectedPost = nil
                        DispatchQueue.main.async {
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
        .alert(isPresented: $model.isPresentingNetworkErrorAlert, content: {
            Alert(
                title: Text("Connection Error"),
                message: Text("There is no internet connection at the moment. Please reconnect or try again later"),
                dismissButton: .default(Text("OK"), action: {
                    model.isPresentingNetworkErrorAlert = false
                })
            )
        })

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
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let context = LocalStorageManager.persistentContainer.viewContext
        let model = WriteFreelyModel()

        return ContentView(sidebarIsHidden: .constant(false))
            .environment(\.managedObjectContext, context)
            .environmentObject(model)
    }
}
