import SwiftUI
import CoreData

class CollectionListModel: ObservableObject {
    @Published var userCollections = [WFACollection]()

    static let allPostsCollection = PostCollection(title: "All Posts")
    static let draftsCollection = PostCollection(title: "Drafts")

    init() {
//        let request = WFACollection.createFetchRequest()
//        request.sortDescriptors = []
//        do {
//            userCollections = try PersistenceManager.persistentContainer.viewContext.fetch(request)
//        } catch {
//            print("Error: Failed to fetch user collections from local store")
//            userCollections = []
//        }
    }

    func clearUserCollection() {
        userCollections = []
        // Clear collections from CoreData store.
    }
}
