import SwiftUI

struct ContentView: View {
    @ObservedObject var postStore: PostStore

    var body: some View {
        NavigationView {
            PostList(postStore: postStore)
                .frame(maxHeight: .infinity)
                .navigationTitle("Posts")
                .toolbar {
                    NavigationLink(
                        destination: PostEditor(
                            post: Post(title: "Title", body: "Write your post here...", createdDate: Date())
                        )
                    ) {
                        Image(systemName: "plus")
                    }
                }

            Text("Select a post, or create a new draft.")
                .foregroundColor(.secondary)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(postStore: testPostStore)
    }
}
