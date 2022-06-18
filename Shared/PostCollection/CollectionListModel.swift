import SwiftUI
import CoreData
import os

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
            Self.logger.info("Fetching collections from local store...")
            try collectionsController.performFetch()
            list = collectionsController.fetchedObjects ?? []
            Self.logger.notice("Fetched collections from local store.")
        } catch {
            logCrashAndSetFlag(error: LocalStoreError.couldNotFetchCollections)
        }
    }
}

extension CollectionListModel: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let collections = controller.fetchedObjects as? [WFACollection] else { return }
        self.list = collections
    }
}

extension CollectionListModel {
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: CollectionListModel.self)
    )

    private func logCrashAndSetFlag(error: Error) {
        let errorDescription = error.localizedDescription
        UserDefaults.shared.set(true, forKey: WFDefaults.didHaveFatalError)
        UserDefaults.shared.set(errorDescription, forKey: WFDefaults.fatalErrorDescription)
        Self.logger.critical("\(errorDescription)")
        fatalError(errorDescription)
    }
}

extension WFACollection {
    static var collectionsFetchRequest: NSFetchRequest<WFACollection> {
        let request: NSFetchRequest<WFACollection> = WFACollection.createFetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \WFACollection.title, ascending: true)]
        return request
    }
}
