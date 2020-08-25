import Foundation
import WriteFreely

struct PostCollection: Identifiable {
    let id = UUID()
    let title: String
    var wfCollection: WFCollection?
}

extension PostCollection {
    static func == (lhs: PostCollection, rhs: PostCollection) -> Bool {
        return lhs.id == rhs.id
    }
}

let allPostsCollection = PostCollection(title: "All Posts")
let draftsCollection = PostCollection(title: "Drafts")

#if DEBUG
let userCollection1 = PostCollection(title: "Collection 1")
let userCollection2 = PostCollection(title: "Collection 2")
let userCollection3 = PostCollection(title: "Collection 3")
#endif
