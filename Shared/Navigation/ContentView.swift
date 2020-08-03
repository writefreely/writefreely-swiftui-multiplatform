import SwiftUI

struct ContentView: View {
    @ObservedObject var postStore: PostStore
    @State private var selectedCollection: PostCollection = allPostsCollection

    var body: some View {
        NavigationView {
            VStack {
                PostList(
                    title: selectedCollection.title,
                    posts: showPosts(for: selectedCollection)
                )
                .frame(maxHeight: .infinity)
                .toolbar {
                    NavigationLink(destination: PostEditor(post: Post())) {
                        Image(systemName: "square.and.pencil")
                    }
                }
                CollectionPicker(selectedCollection: $selectedCollection)
            }
            
            Text("Select a post, or create a new draft.")
                .foregroundColor(.secondary)
        }
        .environmentObject(postStore)
    }
    
    func showPosts(for: PostCollection) -> [Post] {
        if selectedCollection == allPostsCollection {
            return postStore.posts
        } else {
            return postStore.posts.filter { $0.collection.title == selectedCollection.title }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(postStore: testPostStore)
    }
}
