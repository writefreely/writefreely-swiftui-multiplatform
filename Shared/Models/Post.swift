import Foundation
import WriteFreely

class Post: Identifiable, ObservableObject, Hashable {
    @Published var wfPost: WFPost
    @Published var status: PostStatus
    @Published var collection: WFACollection?
    @Published var hasNewerRemoteCopy: Bool = false

    let id = UUID()

    init(
        title: String = "Title",
        body: String = "Write your post here...",
        createdDate: Date = Date(),
        status: PostStatus = .local,
        collection: WFACollection? = nil
    ) {
        self.wfPost = WFPost(body: body, title: title, createdDate: createdDate)
        self.status = status
        self.collection = collection
    }

    convenience init(wfPost: WFPost, in collection: WFACollection? = nil) {
        self.init(
            title: wfPost.title ?? "",
            body: wfPost.body,
            createdDate: wfPost.createdDate ?? Date(),
            status: .published,
            collection: collection
        )
        self.wfPost = wfPost
    }
}

extension Post {
    static func == (lhs: Post, rhs: Post) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
