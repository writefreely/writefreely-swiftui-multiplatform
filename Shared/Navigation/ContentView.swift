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
        ContentView()
            .environmentObject(WriteFreelyModel())
    }
}
