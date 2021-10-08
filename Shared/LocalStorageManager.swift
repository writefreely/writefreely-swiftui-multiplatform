import CoreData

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

final class LocalStorageManager {
    public static var standard = LocalStorageManager()
    public let container: NSPersistentContainer

    private var oldStoreURL: URL {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        return appSupport.appendingPathComponent("LocalStorageModel.sqlite")
    }

    private var sharedStoreURL: URL {
        let id = "group.com.abunchtell.writefreely"
        let groupContainer = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: id)!
        return groupContainer.appendingPathComponent("LocalStorageModel.sqlite")
    }

    init() {
        // Set up the persistent container.
        container = NSPersistentContainer(name: "LocalStorageModel")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Core Data store failed to load with error: \(error)")
            }
        }
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

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
        if container.viewContext.hasChanges {
            do {
                try container.viewContext.save()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }

    func purgeUserCollections() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "WFACollection")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try container.viewContext.executeAndMergeChanges(using: deleteRequest)
        } catch {
            print("Error: Failed to purge cached collections.")
        }
    }

    func migrateStore(for container: NSPersistentContainer) {
        let coordinator = container.persistentStoreCoordinator

        guard let oldStore = coordinator.persistentStore(for: oldStoreURL) else {
            return
        }

        do {
            try coordinator.migratePersistentStore(oldStore,
                                                   to: sharedStoreURL,
                                                   options: nil,
                                                   withType: NSSQLiteStoreType)
        } catch {
            fatalError("Something went wrong migrating the store: \(error)")
        }

        do {
            try FileManager.default.removeItem(at: oldStoreURL)
        } catch {
            fatalError("Something went wrong while deleting the old store: \(error)")
        }
    }
}

private extension LocalStorageManager {
    func saveContextOnResignActive(_ notification: Notification) {
        saveContext()
    }
}
