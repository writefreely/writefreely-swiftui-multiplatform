import SwiftUI

struct PostListView: View {
    @EnvironmentObject var model: WriteFreelyModel
    @Environment(\.managedObjectContext) var moc

    @State var selectedCollection: WFACollection?
    @State var showAllPosts: Bool = false

    #if os(iOS)
    @State private var isPresentingSettings = false
    #endif

    var body: some View {
        #if os(iOS)
        GeometryReader { geometry in
            PostListFilteredView(filter: selectedCollection?.alias, showAllPosts: showAllPosts)
            .navigationTitle(
                showAllPosts ? "All Posts" : selectedCollection?.title ?? (
                    model.account.server == "https://write.as" ? "Anonymous" : "Drafts"
                )
            )
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        createNewLocalDraft()
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
        PostListFilteredView(filter: selectedCollection?.alias, showAllPosts: showAllPosts)
        .navigationTitle(
            showAllPosts ? "All Posts" : selectedCollection?.title ?? (
                model.account.server == "https://write.as" ? "Anonymous" : "Drafts"
            )
        )
        .navigationSubtitle(pluralizedPostCount(for: showPosts(for: selectedCollection)))
        .toolbar {
            Button(action: {
                createNewLocalDraft()
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

    private func pluralizedPostCount(for posts: [WFAPost]) -> String {
        if posts.count == 1 {
            return "1 post"
        } else {
            return "\(posts.count) posts"
        }
    }

    private func showPosts(for collection: WFACollection?) -> [WFAPost] {
        if showAllPosts {
            return model.posts.userPosts
        } else {
            if let selectedCollection = collection {
                return model.posts.userPosts.filter { $0.collectionAlias == selectedCollection.alias }
            } else {
                return model.posts.userPosts.filter { $0.collectionAlias == nil }
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

    private func createNewLocalDraft() {
        let managedPost = WFAPost(context: PersistenceManager.persistentContainer.viewContext)
        managedPost.createdDate = Date()
        managedPost.title = ""
        managedPost.body = ""
        managedPost.status = PostStatus.local.rawValue
        DispatchQueue.main.async {
            PersistenceManager().saveContext()
        }
    }
}

//struct PostList_Previews: PreviewProvider {
//    static var previews: some View {
//        let userCollection1 = WFACollection(context: PersistenceManager.persistentContainer.viewContext)
//        let userCollection2 = WFACollection(context: PersistenceManager.persistentContainer.viewContext)
//        let userCollection3 = WFACollection(context: PersistenceManager.persistentContainer.viewContext)
//
//        userCollection1.title = "Collection 1"
//        userCollection2.title = "Collection 2"
//        userCollection3.title = "Collection 3"
//
//        let testPostData = [
//            Post(
//                title: "My First Post",
//                body: "Look at me, creating a first post! That's cool.",
//                createdDate: Date(timeIntervalSince1970: 1595429452),
//                status: .published,
//                collection: userCollection1
//            ),
//            Post(
//                title: "Post 2: The Quickening",
//                body: "See, here's the rule about Highlander jokes: _there can be only one_.",
//                createdDate: Date(timeIntervalSince1970: 1595514125),
//                status: .edited,
//                collection: userCollection1
//            ),
//            Post(
//                title: "The Post Revolutions",
//                body: "I can never keep the Matrix movie order straight. Why not just call them part 2 and part 3?",
//                createdDate: Date(timeIntervalSince1970: 1595600006)
//            ),
//            Post(
//                title: "Episode IV: A New Post",
//                body: "How many movies does this person watch? How many movie-title jokes will they make?",
//                createdDate: Date(timeIntervalSince1970: 1596219877),
//                status: .published,
//                collection: userCollection2
//            ),
//            Post(
//                title: "Fast (Post) Five",
//                body: "Look, it was either a Fast and the Furious reference, or a Resident Evil reference."
//            ),
//            Post(
//                title: "Post: The Final Chapter",
//                body: "And there you have it, a Resident Evil movie reference.",
//                createdDate: Date(timeIntervalSince1970: 1596043684),
//                status: .edited,
//                collection: userCollection3
//            )
//        ]
//
//        let model = WriteFreelyModel()
//        for post in testPostData {
//            model.store.add(post)
//        }
//        return Group {
//            PostListView(selectedCollection: userCollection1)
//                .environmentObject(model)
//        }
//    }
//}
