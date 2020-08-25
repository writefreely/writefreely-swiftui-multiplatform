import SwiftUI

struct ContentView: View {
    @EnvironmentObject var model: WriteFreelyModel

    var body: some View {
        NavigationView {
            SidebarView()

            PostListView(selectedCollection: allPostsCollection)

            Text("Select a post, or create a new draft.")
                .foregroundColor(.secondary)
        }
        .environmentObject(model)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let model = WriteFreelyModel()
        model.collections = CollectionListModel(with: [userCollection1, userCollection2, userCollection3])
        for post in testPostData {
            model.store.add(post)
        }
        return ContentView()
            .environmentObject(model)
    }
}
