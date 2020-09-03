import SwiftUI

struct SidebarView: View {
    var body: some View {
        CollectionListView()
    }
}

struct SidebarView_Previews: PreviewProvider {
    static var previews: some View {
        let userCollection1 = WFACollection(context: PersistenceManager.persistentContainer.viewContext)
        let userCollection2 = WFACollection(context: PersistenceManager.persistentContainer.viewContext)
        let userCollection3 = WFACollection(context: PersistenceManager.persistentContainer.viewContext)
        userCollection1.title = "Collection 1"
        userCollection2.title = "Collection 2"
        userCollection3.title = "Collection 3"

        let model = WriteFreelyModel()
        model.collections = CollectionListModel()

        return SidebarView()
            .environmentObject(model)
            .environment(\.managedObjectContext, PersistenceManager.persistentContainer.viewContext)
    }
}
