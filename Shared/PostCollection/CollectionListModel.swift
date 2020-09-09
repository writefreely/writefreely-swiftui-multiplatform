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
            let cachedCollections = try LocalStorageManager.persistentContainer.viewContext.fetch(request)
            userCollections.append(contentsOf: cachedCollections)
        } catch {
            print("Error: Failed to fetch cached user collections.")
        }
    }

    func clearUserCollection() {
        userCollections = []
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "WFACollection")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try LocalStorageManager.persistentContainer.persistentStoreCoordinator.execute(
                deleteRequest, with: LocalStorageManager.persistentContainer.viewContext
            )
        } catch {
            print("Error: Failed to purge cached collections.")
        }
    }
}
