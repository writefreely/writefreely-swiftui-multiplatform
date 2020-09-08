import Foundation
import WriteFreely
import CoreData

class PostListModel: ObservableObject {
    @Published var posts = [WFAPost]()

    init() {
        loadCachedPosts()
    }

    func loadCachedPosts() {
        let request = WFAPost.createFetchRequest()
        let sort = NSSortDescriptor(key: "createdDate", ascending: false)
        request.sortDescriptors = [sort]

        posts = []
        do {
            let cachedPosts = try PersistenceManager.persistentContainer.viewContext.fetch(request)
            posts.append(contentsOf: cachedPosts)
        } catch {
            print("Error: Failed to fetch cached posts.")
        }
    }

    func purgeAllPosts() {
        posts = []
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
