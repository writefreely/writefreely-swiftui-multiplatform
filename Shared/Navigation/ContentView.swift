import SwiftUI

struct ContentView: View {
    @ObservedObject var postStore: PostStore

    var body: some View {
        NavigationView {
            CollectionSidebar()

            PostList(selectedCollection: allPostsCollection)

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
