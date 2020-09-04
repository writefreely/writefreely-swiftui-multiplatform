import SwiftUI
import CoreData

class CollectionListModel: ObservableObject {
    @Published var userCollections = [WFACollection]()

    init() {
        loadCachedUserCollections()
    }

    func loadCachedUserCollections() {
        let request = WFACollection.createFetchRequest()
        let sort = NSSortDescriptor(key: "title", ascending: true)
        request.sortDescriptors = [sort]

        userCollections = []
        do {
            let cachedCollections = try PersistenceManager.persistentContainer.viewContext.fetch(request)
            userCollections.append(contentsOf: cachedCollections)
        } catch {
            print("Error: Failed to fetch cached user collections.")
        }
    }

    func clearUserCollection() {
        // Make sure the userCollections property is properly populated.
        // FIXME: Without this, sometimes the userCollections array is empty.
        loadCachedUserCollections()

        for userCollection in userCollections {
            PersistenceManager.persistentContainer.viewContext.delete(userCollection)
        }
        PersistenceManager().saveContext()

        userCollections = []
    }
}
