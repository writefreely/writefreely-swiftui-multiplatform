import CoreData

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

class LocalStorageManager {
    static let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "LocalStorageModel")
        container.loadPersistentStores { _, error in
            container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            if let error = error {
                fatalError("Unresolved error loading persistent store: \(error)")
            }
        }
        return container
    }()

    init() {
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
        if LocalStorageManager.persistentContainer.viewContext.hasChanges {
            do {
                try LocalStorageManager.persistentContainer.viewContext.save()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }
}

private extension LocalStorageManager {
    func saveContextOnResignActive(_ notification: Notification) {
        saveContext()
    }
}
