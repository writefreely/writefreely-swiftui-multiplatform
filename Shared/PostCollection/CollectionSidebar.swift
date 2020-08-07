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

struct CollectionSidebar_Previews: PreviewProvider {
    static var previews: some View {
        CollectionSidebar()
            .environmentObject(testPostStore)
    }
}
