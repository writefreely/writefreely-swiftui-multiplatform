import SwiftUI

struct ContentView: View {
    @EnvironmentObject var model: WriteFreelyModel

    var body: some View {
        NavigationView {
            SidebarView()

            PostListView(selectedCollection: nil, showAllPosts: true)

            Text("Select a post, or create a new local draft.")
                .foregroundColor(.secondary)
        }
        .environmentObject(model)
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        let userCollection1 = WFACollection(context: PersistenceManager.persistentContainer.viewContext)
//        let userCollection2 = WFACollection(context: PersistenceManager.persistentContainer.viewContext)
//        let userCollection3 = WFACollection(context: PersistenceManager.persistentContainer.viewContext)
//        userCollection1.title = "Collection 1"
//        userCollection2.title = "Collection 2"
//        userCollection3.title = "Collection 3"
//
//        let model = WriteFreelyModel()
//        model.collections = CollectionListModel()
//
//        for post in testPostData {
//            model.store.add(post)
//        }
//        return ContentView()
//            .environmentObject(model)
//            .environment(\.managedObjectContext, PersistenceManager.persistentContainer.viewContext)
//    }
//}
