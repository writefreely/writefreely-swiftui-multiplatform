import SwiftUI
import CoreData

class PostListModel: ObservableObject {
    @Published var userPosts = [WFAPost]()

    init() {
        loadCachedPosts()
    }

    func loadCachedPosts() {
        let request = WFAPost.createFetchRequest()
        let sort = NSSortDescriptor(key: "createdDate", ascending: false)
        request.sortDescriptors = [sort]

        userPosts = []
        do {
            let cachedPosts = try LocalStorageManager.persistentContainer.viewContext.fetch(request)
            userPosts.append(contentsOf: cachedPosts)
        } catch {
            print("Error: Failed to fetch cached posts.")
        }
    }

    func remove(_ post: WFAPost) {
        LocalStorageManager.persistentContainer.viewContext.delete(post)
        LocalStorageManager().saveContext()
    }

    func purgePublishedPosts() {
        userPosts = []
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "WFAPost")
        fetchRequest.predicate = NSPredicate(format: "status != %i", 0)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try LocalStorageManager.persistentContainer.viewContext.executeAndMergeChanges(using: deleteRequest)
            loadCachedPosts()
        } catch {
            print("Error: Failed to purge cached posts.")
        }
    }
}
