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
            CollectionListView(selectedCollection: model.selectedCollection)
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
            PostListView(selectedCollection: model.selectedCollection, showAllPosts: model.showAllPosts)
            #endif

            Text("Select a post, or create a new local draft.")
                .foregroundColor(.secondary)
        }
        .environmentObject(model)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let context = LocalStorageManager.standard.container.viewContext
        let model = WriteFreelyModel()

        return ContentView()
            .environment(\.managedObjectContext, context)
            .environmentObject(model)
    }
}
