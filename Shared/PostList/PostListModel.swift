import SwiftUI
import CoreData

class PostListModel: ObservableObject {
    func remove(_ post: WFAPost) {
        LocalStorageManager.persistentContainer.viewContext.delete(post)
        LocalStorageManager().saveContext()
    }

    func purgePublishedPosts() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "WFAPost")
        fetchRequest.predicate = NSPredicate(format: "status != %i", 0)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try LocalStorageManager.persistentContainer.viewContext.executeAndMergeChanges(using: deleteRequest)
        } catch {
            print("Error: Failed to purge cached posts.")
        }
    }
}
