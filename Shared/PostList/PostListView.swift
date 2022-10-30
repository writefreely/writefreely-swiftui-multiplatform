import SwiftUI
import Combine

struct PostListView: View {
    @EnvironmentObject var model: WriteFreelyModel
    @EnvironmentObject var errorHandling: ErrorHandling
    @Environment(\.managedObjectContext) var managedObjectContext

    @State private var postCount: Int = 0
    @State private var filteredListViewId: Int = 0

    var selectedCollection: WFACollection?
    var showAllPosts: Bool

    #if os(iOS)
    private var frameHeight: CGFloat {
        var height: CGFloat = 50
        let bottom = UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0
        height += bottom
        return height
    }
    #endif

    var body: some View {
        #if os(iOS)
        ZStack(alignment: .bottom) {
            PostListFilteredView(
                collection: selectedCollection,
                showAllPosts: showAllPosts,
                postCount: $postCount
            )
                .id(self.filteredListViewId)
                .navigationTitle(
                    showAllPosts ? "All Posts" : selectedCollection?.title ?? (
                        model.account.server == "https://write.as" ? "Anonymous" : "Drafts"
                    )
                )
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        ZStack {
                            // We have to add a Spacer as a sibling view to the Button in some kind of Stack so that any
                            // a11y modifiers are applied as expected: bug report filed as FB8956392.
                            if #unavailable(iOS 16) {
                                Spacer()
                            }
                            Button(action: {
                                let managedPost = model.editor.generateNewLocalPost(withFont: model.preferences.font)
                                withAnimation {
                                    self.model.showAllPosts = false
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        self.model.selectedPost = managedPost
                                    }
                                }
                            }, label: {
                                ZStack {
                                    Image("does.not.exist")
                                        .accessibilityHidden(true)
                                    Image(systemName: "square.and.pencil")
                                        .accessibilityHidden(true)
                                        .imageScale(.large)         // These modifiers compensate for the resizing
                                        .padding(.vertical, 12)     // done to the Image (and the button tap target)
                                        .padding(.leading, 12)      // by the SwiftUI layout system from adding a
                                        .padding(.trailing, 8)      // Spacer in this ZStack (FB8956392).
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            })
                            .accessibilityLabel(Text("Compose"))
                            .accessibilityHint(Text("Compose a new local draft"))
                        }
                    }
                }
            VStack {
                HStack(spacing: 0) {
                    Button(action: {
                        model.isPresentingSettingsView = true
                    }, label: {
                        Image(systemName: "gear")
                            .padding(.vertical, 4)
                            .padding(.horizontal, 8)
                    })
                    .accessibilityLabel(Text("Settings"))
                    .accessibilityHint(Text("Open the Settings sheet"))
                    .sheet(
                        isPresented: $model.isPresentingSettingsView,
                        onDismiss: { model.isPresentingSettingsView = false },
                        content: {
                            SettingsView()
                                .environmentObject(model)
                        }
                    )
                    Spacer()
                    Text(postCount == 1 ? "\(postCount) post" : "\(postCount) posts")
                        .foregroundColor(.secondary)
                    Spacer()
                    if model.isProcessingRequest {
                        ProgressView()
                            .padding(.vertical, 4)
                            .padding(.horizontal, 8)
                    } else {
                        Button(action: {
                            DispatchQueue.main.async {
                                model.fetchUserCollections()
                                model.fetchUserPosts()
                            }
                        }, label: {
                            Image(systemName: "arrow.clockwise")
                                .padding(.vertical, 4)
                                .padding(.horizontal, 8)
                        })
                        .accessibilityLabel(Text("Refresh Posts"))
                        .accessibilityHint(Text("Fetch changes from the server"))
                        .disabled(!model.account.isLoggedIn)
                    }
                }
                .padding(.top, 8)
                .padding(.horizontal, 8)
                Spacer()
            }
            .frame(height: frameHeight)
            .background(Color(UIColor.systemGray5))
            .overlay(Divider(), alignment: .top)
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                // We use this to invalidate and refresh the view, so that new posts created outside of the app (e.g.,
                // in the action extension) show up.
                withAnimation {
                    self.filteredListViewId += 1
                }
            }
        }
        .ignoresSafeArea(.all, edges: .bottom)
        .onAppear {
            model.selectedCollection = selectedCollection
            model.showAllPosts = showAllPosts
        }
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
        PostListFilteredView(
            collection: selectedCollection,
            showAllPosts: showAllPosts,
            postCount: $postCount
        )
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                if model.selectedPost != nil {
                    ActivePostToolbarView(activePost: model.selectedPost!)
                }
            }
        }
        .navigationTitle(
            showAllPosts ? "All Posts" : selectedCollection?.title ?? (
                model.account.server == "https://write.as" ? "Anonymous" : "Drafts"
            )
        )
        .onAppear {
            model.selectedCollection = selectedCollection
            model.showAllPosts = showAllPosts
        }
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

struct PostListView_Previews: PreviewProvider {
    static var previews: some View {
        let context = LocalStorageManager.standard.container.viewContext
        let model = WriteFreelyModel()

        return PostListView(showAllPosts: true)
            .environment(\.managedObjectContext, context)
            .environmentObject(model)
    }
}
