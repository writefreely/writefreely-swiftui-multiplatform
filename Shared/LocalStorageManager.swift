import CoreData

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

final class LocalStorageManager {
    public static var standard = LocalStorageManager()
    public let persistentContainer: NSPersistentContainer

    init() {
        // Set up the persistent container.
        persistentContainer = NSPersistentContainer(name: "LocalStorageModel")
        persistentContainer.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Core Data store failed to load with error: \(error)")
            }
        }
        persistentContainer.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

        let center = NotificationCenter.default

        #if os(iOS)
        let notification = UIApplication.willResignActiveNotification
        #elseif os(macOS)
        let notification = NSApplication.willResignActiveNotification
        #endif

        // We don't need to worry about removing this observer because we're targeting iOS 9+ / macOS 10.11+; the
        // system will clean this up the next time it would be posted to.
        // See: https://developer.apple.com/documentation/foundation/notificationcenter/1413994-removeobserver
        // And: https://developer.apple.com/documentation/foundation/notificationcenter/1407263-removeobserver
        // swiftlint:disable:next discarded_notification_center_observer
        center.addObserver(forName: notification, object: nil, queue: nil, using: self.saveContextOnResignActive)
    }

    func saveContext() {
        if persistentContainer.viewContext.hasChanges {
            do {
                try persistentContainer.viewContext.save()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }

    func purgeUserCollections() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "WFACollection")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try persistentContainer.viewContext.executeAndMergeChanges(using: deleteRequest)
        } catch {
            print("Error: Failed to purge cached collections.")
        }
    }
}

private extension LocalStorageManager {
    func saveContextOnResignActive(_ notification: Notification) {
        saveContext()
    }
}
