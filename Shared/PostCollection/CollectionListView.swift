import SwiftUI

struct CollectionListView: View {
    private let collections = postCollections

    var body: some View {
        List {
            ForEach(collections) { collection in
                NavigationLink(
                    destination: PostListView(selectedCollection: collection)
                ) {
                    Text(collection.title)
                }
            }
        }
        .navigationTitle("Collections")
        .listStyle(SidebarListStyle())
    }
}

struct CollectionSidebar_Previews: PreviewProvider {
    static var previews: some View {
        CollectionListView()
    }
}
