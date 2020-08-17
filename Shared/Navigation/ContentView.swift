import SwiftUI

struct ContentView: View {
    @ObservedObject var postStore: PostStore
    @ObservedObject var preferences: PreferencesModel
    @ObservedObject var account: AccountModel

    var body: some View {
        NavigationView {
            SidebarView()

            PostList(selectedCollection: allPostsCollection)

            Text("Select a post, or create a new draft.")
                .foregroundColor(.secondary)
        }
        .environmentObject(postStore)
        .environmentObject(preferences)
        .environmentObject(account)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(postStore: testPostStore, preferences: PreferencesModel(), account: AccountModel())
    }
}
