import Foundation

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
            print("local copy not found")
        }
    }
