import SwiftUI

struct CollectionListView: View {
    private var collections = CollectionListModel()

    var body: some View {
        List {
            ForEach(collections.collectionsList) { collection in
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
