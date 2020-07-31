import SwiftUI

struct ContentView: View {
    @ObservedObject var postStore: PostStore
    @State private var selectedCollection: PostCollection = defaultDraftCollection

    var body: some View {
        NavigationView {
            VStack {
                PostList(title: selectedCollection.title)
                    .frame(maxHeight: .infinity)
                    .toolbar {
                        NavigationLink(destination: PostEditor(post: Post())) {
                            Image(systemName: "plus")
                        }
                }
                CollectionPicker(selectedCollection: $selectedCollection)
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
