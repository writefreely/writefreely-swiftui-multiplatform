import SwiftUI

struct ContentView: View {
    @EnvironmentObject var model: WriteFreelyModel

    var body: some View {
        NavigationView {
            #if os(macOS)
            CollectionListView()
                .toolbar {
                    Button(
                        action: {
                            NSApp.keyWindow?.contentViewController?.tryToPerform(
                                #selector(NSSplitViewController.toggleSidebar(_:)), with: nil
                            )
                        },
                        label: { Image(systemName: "sidebar.left") }
                    )
                    .help("Toggle the sidebar's visibility.")
                    Spacer()
                    Button(action: {
                        withAnimation {
                            // Un-set the currently selected post
                            self.model.selectedPost = nil
                        }
                        // Create the new-post managed object
                        let managedPost = model.editor.generateNewLocalPost(withFont: model.preferences.font)
                        withAnimation {
                            DispatchQueue.main.asyncAfter(deadline: .now()) {
                                // Load the new post in the editor
                                self.model.selectedPost = managedPost
                            }
                        }
                    }, label: { Image(systemName: "square.and.pencil") })
                    .help("Create a new local draft.")
                }
            #else
            if #available(iOS 15.0, *) {
                CollectionListView()
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
            } else {
                CollectionListView()
            }
            #endif

            #if os(macOS)
            ZStack {
                PostListView()
                if model.isProcessingRequest {
                    ZStack {
                        Color(NSColor.controlBackgroundColor).opacity(0.75)
                        ProgressView()
                    }
                }
            }
            #else
            if #available(iOS 15.0, *) {
                PostListView()
                    .sheet(
                        isPresented: $model.isPresentingSettingsView,
                        onDismiss: { model.isPresentingSettingsView = false },
                        content: {
                            SettingsView()
                                .environmentObject(model)
                        }
                    )
            } else {
                PostListView()
            }
            #endif

            Text("Select a post, or create a new local draft.")
                .foregroundColor(.secondary)
        }
        .environmentObject(model)
        // For iOS 14
        if #available(iOS 15.0, *) {
            // Do nothing.
        } else {
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
