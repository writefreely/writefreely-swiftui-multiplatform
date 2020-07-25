import Foundation

class PostStore: ObservableObject {
    @Published var posts: [Post]

    init(posts: [Post] = []) {
        self.posts = posts
    }
}

let testPostStore = PostStore(posts: testPostData)
