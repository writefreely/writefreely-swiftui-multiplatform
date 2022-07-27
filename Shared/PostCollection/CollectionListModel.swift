import SwiftUI
import CoreData

class CollectionListModel: NSObject, ObservableObject {

    private let logger = Logging(for: String(describing: CollectionListModel.self))

    @Published var list: [WFACollection] = []
    private let collectionsController: NSFetchedResultsController<WFACollection>

    init(managedObjectContext: NSManagedObjectContext) {
        collectionsController = NSFetchedResultsController(fetchRequest: WFACollection.collectionsFetchRequest,
                                                           managedObjectContext: managedObjectContext,
                                                           sectionNameKeyPath: nil,
                                                           cacheName: nil)

        super.init()

        collectionsController.delegate = self

        do {
            logger.log("Fetching collections from local store...")
            try collectionsController.performFetch()
            list = collectionsController.fetchedObjects ?? []
            logger.log("Fetched collections from local store.")
        } catch {
            logger.logCrashAndSetFlag(error: LocalStoreError.couldNotFetchCollections)
        }
    }
}

extension CollectionListModel: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let collections = controller.fetchedObjects as? [WFACollection] else { return }
        self.list = collections
    }
}

extension WFACollection {
    static var collectionsFetchRequest: NSFetchRequest<WFACollection> {
        let request: NSFetchRequest<WFACollection> = WFACollection.createFetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \WFACollection.title, ascending: true)]
        return request
    }
}
