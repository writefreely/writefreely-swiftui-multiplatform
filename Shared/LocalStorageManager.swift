import CoreData

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

final class LocalStorageManager {

    public static var standard = LocalStorageManager()
    public let container: NSPersistentContainer
    private let containerName = "LocalStorageModel"

    private init() {
        container = NSPersistentContainer(name: containerName)
        setupStore(in: container)
        registerObservers()
    }

    func saveContext() {
        if container.viewContext.hasChanges {
            do {
                try container.viewContext.save()
            } catch {
                fatalError("Error saving context: \(error)")
            }
        }
    }

    func purgeUserCollections() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "WFACollection")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try container.viewContext.executeAndMergeChanges(using: deleteRequest)
        } catch {
            fatalError("Error: Failed to purge cached collections.")
        }
    }

}

private extension LocalStorageManager {

    var oldStoreURL: URL {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        return appSupport.appendingPathComponent("LocalStorageModel.sqlite")
    }

    var sharedStoreURL: URL {
        let id = "group.com.abunchtell.writefreely"
        let groupContainer = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: id)!
        return groupContainer.appendingPathComponent("LocalStorageModel.sqlite")
    }

    func setupStore(in container: NSPersistentContainer) {
        if !FileManager.default.fileExists(atPath: oldStoreURL.path) {
            container.persistentStoreDescriptions.first!.url = sharedStoreURL
        }

        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data store failed to load with error: \(error)")
            }
        }
        migrateStore(for: container)
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    func migrateStore(for container: NSPersistentContainer) {
        // Check if the shared store exists before attempting a migration — for example, in case we've already attempted
        // and successfully completed a migration, but the deletion of the old store failed for some reason.
        guard !FileManager.default.fileExists(atPath: sharedStoreURL.path) else { return }

        let coordinator = container.persistentStoreCoordinator

        // Get a reference to the old store.
        guard let oldStore = coordinator.persistentStore(for: oldStoreURL) else {
            return
        }

        // Attempt to migrate the old store over to the shared store URL.
        do {
            try coordinator.migratePersistentStore(oldStore,
                                                   to: sharedStoreURL,
                                                   options: nil,
                                                   withType: NSSQLiteStoreType)
        } catch {
            fatalError("Something went wrong migrating the store: \(error)")
        }

        // Attempt to delete the old store.
        do {
            try FileManager.default.removeItem(at: oldStoreURL)
        } catch {
            fatalError("Something went wrong while deleting the old store: \(error)")
        }
    }

    func registerObservers() {
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

    func saveContextOnResignActive(_ notification: Notification) {
        saveContext()
    }

}
