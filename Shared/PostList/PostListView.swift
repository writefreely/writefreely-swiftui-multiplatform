import SwiftUI

struct PostListView: View {
    @EnvironmentObject var model: WriteFreelyModel
    @State var selectedCollection: PostCollection
    @State private var isPresentingRefreshWarning = false

    #if os(iOS)
    @State private var isPresentingSettings = false
    #endif

    var body: some View {
        #if os(iOS)
        GeometryReader { geometry in
            List {
                ForEach(showPosts(for: selectedCollection)) { post in
                    NavigationLink(
                        destination: PostEditorView(post: post)
                    ) {
                        PostCellView(
                            post: post
                        )
                    }
                }
            }
            .environmentObject(model)
            .navigationTitle(selectedCollection.title)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        let post = Post()
                        model.store.add(post)
                    }, label: {
                        Image(systemName: "square.and.pencil")
                    })
                }
                ToolbarItem(placement: .bottomBar) {
                    HStack {
                        Button(action: {
                            isPresentingSettings = true
                        }, label: {
                            Image(systemName: "gear")
                        }).sheet(
                            isPresented: $isPresentingSettings,
                            onDismiss: {
                                isPresentingSettings = false
                            },
                            content: {
                                SettingsView(isPresented: $isPresentingSettings)
                            }
                        )
                        .padding(.leading)
                        Spacer()
                        Text(pluralizedPostCount(for: showPosts(for: selectedCollection)))
                            .foregroundColor(.secondary)
                        Spacer()
                        Button(action: {
                            isPresentingRefreshWarning = true
                        }, label: {
                            Image(systemName: "arrow.clockwise")
                        })
                        .actionSheet(isPresented: $isPresentingRefreshWarning, content: {
                            ActionSheet(
                                title: Text("Are you sure you want to reload content from the server?"),
                                message: Text("""
                        Content on your device will be replaced by content from the server and any unpublished changes \
                        will be lost, except for local drafts.

                        You can't undo this action.
                        """),
                                buttons: [
                                    .cancel(),
                                    .destructive(Text("Reload From Server"), action: reloadFromServer)
                                ]
                            )
                        })
                        .disabled(!model.account.isLoggedIn)
                    }
                    .padding()
                    .frame(width: geometry.size.width)
                }
            }
        }
        #else //if os(macOS)
        List {
            ForEach(showPosts(for: selectedCollection)) { post in
                NavigationLink(
                    destination: PostEditorView(post: post)
                ) {
                    PostCellView(
                        post: post
                    )
                }
            }
        }
        .navigationTitle(selectedCollection.title)
        .navigationSubtitle(pluralizedPostCount(for: showPosts(for: selectedCollection)))
        .toolbar {
            Button(action: {
                let post = Post()
                model.store.add(post)
            }, label: {
                Image(systemName: "square.and.pencil")
            })
            Button(action: {
                isPresentingRefreshWarning = true
            }, label: {
                Image(systemName: "arrow.clockwise")
            })
            .alert(isPresented: $isPresentingRefreshWarning, content: {
                Alert(
                    title: Text("Are you sure you want to reload content from the server?"),
                    message: Text("""
                        Content on your Mac will be replaced by content from the server and any unpublished changes \
                        will be lost, except for local drafts.

                        You can't undo this action.
                        """),
                    primaryButton: .cancel(),
                    secondaryButton: .destructive(Text("Reload From Server"), action: reloadFromServer)
                )
            })
            .disabled(!model.account.isLoggedIn)
        }
        #endif
    }

    private func pluralizedPostCount(for posts: [Post]) -> String {
        if posts.count == 1 {
            return "1 post"
        } else {
            return "\(posts.count) posts"
        }
    }

    private func showPosts(for collection: PostCollection) -> [Post] {
        if collection == allPostsCollection {
            return model.store.posts
        } else {
            return model.store.posts.filter {
                $0.collection.title == collection.title
            }
        }
    }

    private func reloadFromServer() {
        DispatchQueue.main.async {
            model.collections.clearUserCollection()
            model.fetchUserCollections()
            model.fetchUserPosts()
        }
    }
}

struct PostList_Previews: PreviewProvider {
    static var previews: some View {
        let model = WriteFreelyModel()
        for post in testPostData {
            model.store.add(post)
        }
        return Group {
            PostListView(selectedCollection: allPostsCollection)
                .environmentObject(model)
        }
    }
}
