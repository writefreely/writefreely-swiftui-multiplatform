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
                    Button(action: {
                        withAnimation {
                            self.model.selectedPost = nil
                        }
                        let managedPost = WFAPost(context: LocalStorageManager.persistentContainer.viewContext)
                        managedPost.createdDate = Date()
                        managedPost.title = ""
                        managedPost.body = ""
                        managedPost.status = PostStatus.local.rawValue
                        managedPost.collectionAlias = nil
                        switch model.preferences.font {
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
                        withAnimation {
                            DispatchQueue.main.async {
                                self.model.selectedPost = managedPost
                            }
                        }
                    }, label: { Image(systemName: "square.and.pencil") })
                }
            #else
            SidebarView()
            #endif

            #if os(macOS)
            PostListView(selectedCollection: nil, showAllPosts: model.account.isLoggedIn)
                .toolbar {
                    ToolbarItem(placement: .navigation) {
                        Button(action: {
                            DispatchQueue.main.async {
                                model.fetchUserCollections()
                                model.fetchUserPosts()
                            }
                        }, label: { Image(systemName: "arrow.clockwise") })
                        .disabled(!model.account.isLoggedIn)
                        .padding(.leading, sidebarIsHidden ? 8 : 0)
                        .animation(.linear)
                        .alert(isPresented: $model.isPresentingNetworkErrorAlert, content: {
                            Alert(
                                title: Text("Connection Error"),
                                message: Text("""
                                    There is no internet connection at the moment. Please reconnect or try again later.
                                    """),
                                dismissButton: .default(Text("OK"), action: {
                                    model.isPresentingNetworkErrorAlert = false
                                })
                            )
                        })
                    }
                    ToolbarItemGroup(placement: .primaryAction) {
                        if let selectedPost = model.selectedPost {
                            ActivePostToolbarView(activePost: selectedPost)
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
            .alert(isPresented: $model.isPresentingNetworkErrorAlert, content: {
                Alert(
                    title: Text("Connection Error"),
                    message: Text("""
                        There is no internet connection at the moment. Please reconnect or try again later.
                        """),
                    dismissButton: .default(Text("OK"), action: {
                        model.isPresentingNetworkErrorAlert = false
                    })
                )
            })
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
