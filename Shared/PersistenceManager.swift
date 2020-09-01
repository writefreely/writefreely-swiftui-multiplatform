import CoreData

#if os(macOS)
import AppKit
#endif

class PersistenceManager {
    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "LocalStorageModel")
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error loading persistent store: \(error) - \(error.userInfo)")
            }
        })
        return container
    }()

    init() {
        let center = NotificationCenter.default

        #if os(iOS)
        let notification = UIApplication.willResignActiveNotification
        #elseif os(macOS)
        let notification = NSApplication.willResignActiveNotification
        #endif

        center.addObserver(forName: notification, object: nil, queue: nil) { [weak self] _ in
            guard let self = self else { return }

            if self.persistentContainer.viewContext.hasChanges {
                try? self.persistentContainer.viewContext.save()
            }
        }
    }
}
