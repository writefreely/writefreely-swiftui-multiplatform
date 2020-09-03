import SwiftUI

struct PostListView: View {
    @EnvironmentObject var model: WriteFreelyModel
    @State var selectedCollection: PostCollection

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
                            reloadFromServer()
                        }, label: {
                            Image(systemName: "arrow.clockwise")
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
                reloadFromServer()
            }, label: {
                Image(systemName: "arrow.clockwise")
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
        var posts: [Post]
        if collection == CollectionListModel.allPostsCollection {
            posts = model.store.posts
        } else if collection == CollectionListModel.draftsCollection {
            posts = model.store.posts.filter { $0.collection == nil }
        } else {
            posts = model.store.posts.filter { $0.collection?.title == collection.title }
        }
        return posts
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
            PostListView(selectedCollection: CollectionListModel.allPostsCollection)
                .environmentObject(model)
        }
    }
}
