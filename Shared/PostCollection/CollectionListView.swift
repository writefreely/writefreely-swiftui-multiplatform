import SwiftUI

struct CollectionListView: View {
    @EnvironmentObject var model: WriteFreelyModel

    var body: some View {
        List {
            ForEach(model.collections.collectionsList) { collection in
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
