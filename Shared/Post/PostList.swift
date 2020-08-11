import SwiftUI

struct PostList: View {
    @EnvironmentObject var postStore: PostStore
    @State var selectedCollection: PostCollection
    @State var isPresentingSettings = false

    var body: some View {
        #if os(iOS)
        GeometryReader { geometry in
            List {
                ForEach(showPosts(for: selectedCollection)) { post in
                    NavigationLink(
                        destination: PostEditor(post: post)
                    ) {
                        PostCell(
                            post: post
                        )
                    }
                }
            }
            .navigationTitle(selectedCollection.title)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        let post = Post()
                        postStore.add(post)
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
                        Spacer()
                        Text(pluralizedPostCount(for: showPosts(for: selectedCollection)))
                            .foregroundColor(.secondary)
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
                    destination: PostEditor(post: post)
                ) {
                    PostCell(
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
                postStore.add(post)
            }, label: {
                Image(systemName: "square.and.pencil")
            })
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
            return postStore.posts
        } else {
            return postStore.posts.filter {
                $0.collection.title == collection.title
            }
        }
    }
}

struct PostList_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PostList(selectedCollection: allPostsCollection)
                .environmentObject(testPostStore)
        }
    }
}
