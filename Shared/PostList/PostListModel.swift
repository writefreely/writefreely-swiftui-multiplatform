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

    func purgeAllPosts() {
        userPosts = []
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "WFAPost")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try LocalStorageManager.persistentContainer.persistentStoreCoordinator.execute(
                deleteRequest, with: LocalStorageManager.persistentContainer.viewContext
            )
        } catch {
            print("Error: Failed to purge cached posts.")
        }
    }
}
