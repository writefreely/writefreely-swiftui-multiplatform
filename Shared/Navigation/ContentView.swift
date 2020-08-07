import SwiftUI

struct ContentView: View {
    @ObservedObject var postStore: PostStore
    @State private var selectedCollection: PostCollection? = allPostsCollection

    var body: some View {
        NavigationView {
                CollectionSidebar(selectedCollection: $selectedCollection)

                PostList(
                    title: selectedCollection?.title ?? allPostsCollection.title,
                    posts: showPosts(for: selectedCollection ?? allPostsCollection)
                )

            Text("Select a post, or create a new draft.")
                .foregroundColor(.secondary)
        }
        .environmentObject(postStore)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(postStore: testPostStore)
    }
}
