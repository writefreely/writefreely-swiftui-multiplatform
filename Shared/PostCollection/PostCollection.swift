import Foundation

struct PostCollection: Identifiable, Hashable {
    let id = UUID()
    let title: String
}

let allPostsCollection = PostCollection(title: "All Posts")
let defaultDraftCollection = PostCollection(title: "Drafts")
let userCollections = [
    PostCollection(title: "Collection 1"),
    PostCollection(title: "Collection 2"),
    PostCollection(title: "Collection 3")
]

let postCollections = [
    allPostsCollection,
    defaultDraftCollection,
    userCollections[0],
    userCollections[1],
    userCollections[2]
]
