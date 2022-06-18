import CoreData
import os

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
                Self.logger.info("Saving context to local store started...")
                try container.viewContext.save()
                Self.logger.notice("Context saved to local store.")
            } catch {
                logCrashAndSetFlag(error: LocalStoreError.couldNotSaveContext)
            }
        }
    }

    func purgeUserCollections() throws {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "WFACollection")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            Self.logger.info("Purging user collections from local store...")
            try container.viewContext.executeAndMergeChanges(using: deleteRequest)
            Self.logger.notice("User collections purged from local store.")
        } catch {
            Self.logger.error("\(LocalStoreError.couldNotPurgeCollections.localizedDescription)")
            throw LocalStoreError.couldNotPurgeCollections
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
            Self.logger.info("Loading local store...")
            if let error = error {
                self.logCrashAndSetFlag(error: LocalStoreError.couldNotLoadStore(error.localizedDescription))
            }
            Self.logger.notice("Loaded local store.")
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
            Self.logger.info("Migrating local store to shared store...")
            try coordinator.migratePersistentStore(oldStore,
                                                   to: sharedStoreURL,
                                                   options: nil,
                                                   withType: NSSQLiteStoreType)
            Self.logger.notice("Migrated local store to shared store.")
        } catch {
            logCrashAndSetFlag(error: LocalStoreError.couldNotMigrateStore(error.localizedDescription))
        }

        // Attempt to delete the old store.
        do {
            Self.logger.info("Deleting migrated local store...")
            try FileManager.default.removeItem(at: oldStoreURL)
            Self.logger.notice("Deleted migrated local store.")
        } catch {
            logCrashAndSetFlag(error: LocalStoreError.couldNotDeleteStoreAfterMigration(error.localizedDescription))
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

private extension LocalStorageManager {

    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: LocalStorageManager.self)
    )

    private func logCrashAndSetFlag(error: Error) {
        let errorDescription = error.localizedDescription
        UserDefaults.shared.set(true, forKey: WFDefaults.didHaveFatalError)
        UserDefaults.shared.set(errorDescription, forKey: WFDefaults.fatalErrorDescription)
        Self.logger.critical("\(errorDescription)")
        fatalError(errorDescription)
    }

}
