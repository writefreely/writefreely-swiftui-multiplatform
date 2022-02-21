import SwiftUI
import CoreData

class CollectionListModel: NSObject, ObservableObject {
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
            try collectionsController.performFetch()
            list = collectionsController.fetchedObjects ?? []
        } catch {
            fatalError("Failed to fetch collections!")
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
