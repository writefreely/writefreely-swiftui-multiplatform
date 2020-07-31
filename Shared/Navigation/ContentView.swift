import SwiftUI

struct ContentView: View {
    @ObservedObject var postStore: PostStore

    var body: some View {
        NavigationView {
            PostList(title: "Posts")
                .frame(maxHeight: .infinity)
                .toolbar {
                    NavigationLink(destination: PostEditor(post: Post())) {
                        Image(systemName: "plus")
                    }
                }

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
