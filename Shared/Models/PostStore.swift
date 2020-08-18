import Foundation

class PostStore: ObservableObject {
    @Published var posts: [Post]

    init(posts: [Post] = []) {
        self.posts = posts
    }

    func add(_ post: Post) {
        posts.append(post)
    }
}

var testPostStore = PostStore(posts: testPostData)
