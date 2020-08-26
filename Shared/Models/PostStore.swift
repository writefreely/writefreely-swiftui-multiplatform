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

    mutating func purgeRemotePosts() {
        posts = posts.filter { $0.wfPost.postId == nil }
    }
}
