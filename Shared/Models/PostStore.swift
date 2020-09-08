import Foundation
import WriteFreely

struct PostStore {
    var posts: [Post]

    init(posts: [Post] = []) {
        self.posts = posts
    }

    mutating func add(_ post: Post) {
        posts.append(post)
    }

    mutating func purgeAllPosts() {
        posts = []
    }

    mutating func update(_ post: Post) {
        // Find the local copy in the store
        let localCopy = posts.first(where: { $0.id == post.id })

        // If there's a local copy, update the updatedDate property of its WFPost
        if let localCopy = localCopy {
            localCopy.wfPost.updatedDate = Date()
        } else {
            print("Error: Local copy not found")
        }
    }

    mutating func replace(post: Post, with fetchedPost: WFPost) {
        // Find the local copy in the store.
        let localCopy = posts.first(where: { $0.id == post.id })

        // Replace the local copy's wfPost property with the fetched copy.
        if let localCopy = localCopy {
            localCopy.wfPost = fetchedPost
            DispatchQueue.main.async {
                localCopy.hasNewerRemoteCopy = false
                localCopy.status = .published
            }
        } else {
            print("Error: Local copy not found")
        }
    }

    mutating func updateStore(with fetchedPosts: [Post]) {
        for fetchedPost in fetchedPosts {
            // Find the local copy in the store.
            let localCopy = posts.first(where: { $0.wfPost.postId == fetchedPost.wfPost.postId })

            // If there's a local copy, check which is newer; if not, add the fetched post to the store.
            if let localCopy = localCopy {
                // We do not discard the local copy; we simply set the hasNewerRemoteCopy flag accordingly.
                if let remoteCopyUpdatedDate = fetchedPost.wfPost.updatedDate,
                   let localCopyUpdatedDate = localCopy.wfPost.updatedDate {
                    localCopy.hasNewerRemoteCopy = remoteCopyUpdatedDate > localCopyUpdatedDate
                } else {
                    print("Error: could not determine which copy of post is newer")
                }
            } else {
                add(fetchedPost)
            }
        }
    }
}
