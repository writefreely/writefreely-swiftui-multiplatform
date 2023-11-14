import SwiftUI

struct ContentView: View {
    @EnvironmentObject var model: WriteFreelyModel
    @EnvironmentObject var errorHandling: ErrorHandling

    var body: some View {
        #if os(macOS)
        WFNavigation(
            collectionList: {
                CollectionListView()
                    .withErrorHandling()
                    .toolbar {
                        if #available(macOS 13, *) {
                            EmptyView()
                        } else {
                            Button(
                                action: {
                                    NSApp.keyWindow?.contentViewController?.tryToPerform(
                                        #selector(NSSplitViewController.toggleSidebar(_:)), with: nil
                                    )
                                },
                                label: { Image(systemName: "sidebar.left") }
                            )
                            .help("Toggle the sidebar's visibility.")
                        }
                        Spacer()
                        Button(action: {
                            withAnimation {
                                // Un-set the currently selected post
                                self.model.selectedPost = nil
                            }
                            // Create the new-post managed object
                            let managedPost = model.editor.generateNewLocalPost(withFont: model.preferences.font)
                            withAnimation {
                                DispatchQueue.main.async {
                                    // Load the new post in the editor
                                    self.model.selectedPost = managedPost
                                }
                            }
                        }, label: { Image(systemName: "square.and.pencil") })
                        .help("Create a new local draft.")
                    }
                    .frame(width: 200)
            },
            postList: {
                ZStack {
                    PostListView(selectedCollection: model.selectedCollection, showAllPosts: model.showAllPosts)
                        .withErrorHandling()
                        .frame(width: 300)
                    if model.isProcessingRequest {
                        ZStack {
                            Color(NSColor.controlBackgroundColor).opacity(0.75)
                            ProgressView()
                        }
                    }
                }
            },
            postDetail: {
                NoSelectedPostView(isConnected: $model.hasNetworkConnection)
            }
        )
        .environmentObject(model)
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
        #else
        WFNavigation(
            collectionList: {
                CollectionListView()
                    .withErrorHandling()
            },
            postList: {
                PostListView(selectedCollection: model.selectedCollection, showAllPosts: model.showAllPosts)
                    .withErrorHandling()
            },
            postDetail: {
                NoSelectedPostView(isConnected: $model.hasNetworkConnection)
            }
        )
        .environmentObject(model)
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
        #endif
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
