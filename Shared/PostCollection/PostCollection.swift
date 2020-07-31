import Foundation

struct PostCollection: Identifiable, Hashable {
    let id = UUID()
    let title: String
}

let allPostsCollection = PostCollection(title: "All Posts")
let defaultDraftCollection = PostCollection(title: "Drafts")
let testPostCollection1 = PostCollection(title: "Collection 1")
let testPostCollection2 = PostCollection(title: "Collection 2")
let testPostCollection3 = PostCollection(title: "Collection 3")
