import Foundation
import WriteFreely

class PostCollection: Identifiable {
    let id = UUID()
    var title: String
    var wfCollection: WFCollection?

    init(title: String) {
        self.title = title
    }
}

extension PostCollection {
    static func == (lhs: PostCollection, rhs: PostCollection) -> Bool {
        return lhs.id == rhs.id
    }
}
