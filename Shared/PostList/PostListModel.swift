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

//    func add(_ post: WFAPost) {
//        posts.append(post)
//    }

//    func update(_ post: WFAPost) {
//        // Find the local copy in the store
//        let localCopy = posts.first(where: { $0.id == post.id })
//
//        // If there's a local copy, update the updatedDate property of its WFPost
//        if let localCopy = localCopy {
//            localCopy.wfPost.updatedDate = Date()
//        } else {
//            print("Error: Local copy not found")
//        }
//    }

//    func replace(post: Post, with fetchedPost: WFPost) {
//        // Find the local copy in the store.
//        let localCopy = posts.first(where: { $0.id == post.id })
//
//        // Replace the local copy's wfPost property with the fetched copy.
//        if let localCopy = localCopy {
//            localCopy.wfPost = fetchedPost
//            DispatchQueue.main.async {
//                localCopy.hasNewerRemoteCopy = false
//                localCopy.status = .published
//            }
//        } else {
//            print("Error: Local copy not found")
//        }
//    }

//    func updateStore(with fetchedPosts: [Post]) {
//        for fetchedPost in fetchedPosts {
//            // Find the local copy in the store.
//            let localCopy = posts.first(where: { $0.wfPost.postId == fetchedPost.wfPost.postId })
//
//            // If there's a local copy, check which is newer; if not, add the fetched post to the store.
//            if let localCopy = localCopy {
//                // We do not discard the local copy; we simply set the hasNewerRemoteCopy flag accordingly.
//                if let remoteCopyUpdatedDate = fetchedPost.wfPost.updatedDate,
//                   let localCopyUpdatedDate = localCopy.wfPost.updatedDate {
//                    localCopy.hasNewerRemoteCopy = remoteCopyUpdatedDate > localCopyUpdatedDate
//                } else {
//                    print("Error: could not determine which copy of post is newer")
//                }
//            } else {
//                add(fetchedPost)
//            }
//        }
//    }
}
