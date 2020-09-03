import SwiftUI

struct CollectionListView: View {
    @EnvironmentObject var model: WriteFreelyModel
    @Environment(\.managedObjectContext) var moc

    @FetchRequest(entity: WFACollection.entity(), sortDescriptors: []) var collections: FetchedResults<WFACollection>

    var body: some View {
        List {
            NavigationLink(destination: PostListView(selectedCollection: CollectionListModel.allPostsCollection)) {
                Text(CollectionListModel.allPostsCollection.title)
            }
            NavigationLink(destination: PostListView(selectedCollection: CollectionListModel.draftsCollection)) {
                Text(CollectionListModel.draftsCollection.title)
            }
            Section(header: Text("Your Blogs")) {
                ForEach(collections, id: \.alias) { collection in
                    NavigationLink(
                        destination: PostListView(selectedCollection: PostCollection(title: collection.title))
                    ) {
                        Text(collection.title)
                    }
                }
            }
        }
        .navigationTitle("Collections")
        .listStyle(SidebarListStyle())
    }
}

struct CollectionSidebar_Previews: PreviewProvider {
    @Environment(\.managedObjectContext) var moc

    static var previews: some View {
        let userCollection1 = WFACollection(context: PersistenceManager.persistentContainer.viewContext)
        let userCollection2 = WFACollection(context: PersistenceManager.persistentContainer.viewContext)
        let userCollection3 = WFACollection(context: PersistenceManager.persistentContainer.viewContext)
        userCollection1.title = "Collection 1"
        userCollection2.title = "Collection 2"
        userCollection3.title = "Collection 3"

        let model = WriteFreelyModel()
        model.collections = CollectionListModel()

        return CollectionListView()
            .environmentObject(model)
            .environment(\.managedObjectContext, PersistenceManager.persistentContainer.viewContext)
    }
}
