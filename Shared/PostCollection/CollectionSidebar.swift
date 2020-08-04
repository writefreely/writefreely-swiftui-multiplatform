import SwiftUI

struct CollectionSidebar: View {
    @EnvironmentObject var postStore: PostStore
    @Binding var selectedCollection: PostCollection?

    private let collections = postCollections

    var body: some View {
        List {
            ForEach(collections) { collection in
                NavigationLink(
                    destination: PostList(title: collection.title, posts: showPosts(for: collection)).tag(collection)) {
                    Text(collection.title)
                }
            }
        }
        .listStyle(SidebarListStyle())
    }

    func showPosts(for collection: PostCollection) -> [Post] {
        if collection == allPostsCollection {
            return postStore.posts
        } else {
            return postStore.posts.filter {
                $0.collection.title == collection.title
            }
        }
    }
}
