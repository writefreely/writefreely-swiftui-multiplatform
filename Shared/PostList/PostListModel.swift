import Foundation
import WriteFreely
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
            let cachedPosts = try PersistenceManager.persistentContainer.viewContext.fetch(request)
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
            try PersistenceManager.persistentContainer.persistentStoreCoordinator.execute(
                deleteRequest, with: PersistenceManager.persistentContainer.viewContext
            )
        } catch {
            print("Error: Failed to purge cached posts.")
        }
    }
}
