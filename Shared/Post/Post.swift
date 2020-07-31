import Foundation

enum PostStatus {
    case draft
    case edited
    case published
}

class Post: Identifiable, ObservableObject {
    @Published var title: String
    @Published var body: String
    @Published var createdDate: Date
    @Published var status: PostStatus
    @Published var collection: PostCollection

    let id = UUID()

    init(
        title: String = "Title",
        body: String = "Write your post here...",
        createdDate: Date = Date(),
        status: PostStatus = .draft,
        collection: PostCollection = defaultDraftCollection
    ) {
        self.title = title
        self.body = body
        self.createdDate = createdDate
        self.status = status
        self.collection = collection
    }
}

let testPost = Post(
    title: "Test Post Title",
    body: """
    Here's some cool sample body text. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean ultrices \
    posuere dignissim. Vestibulum a libero tempor, lacinia nulla vitae, congue purus. Nunc ac nulla quam. Duis \
    tincidunt eros augue, et volutpat tortor pulvinar ut. Nullam sit amet maximus urna. Phasellus non dignissim lacus.\
    Nulla ac posuere ex. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec \
    non molestie mauris. Suspendisse potenti. Vivamus at erat turpis.

    Pellentesque porttitor gravida tincidunt. Sed vitae eros non metus aliquam hendrerit. Aliquam sed risus suscipit \
    turpis dictum dictum. Duis lacus lectus, dictum vel felis in, rhoncus fringilla felis. Nunc id dolor nisl. Aliquam \
    euismod purus elit. Nullam egestas neque leo, sed aliquet ligula ultrices nec.
    """,
    createdDate: Date()
)

let testPostData = [
    Post(
        title: "My First Post",
        body: "Look at me, creating a first post! That's cool.",
        createdDate: Date(timeIntervalSince1970: 1595429452),
        status: .published,
        collection: testPostCollection1
    ),
    Post(
        title: "Post 2: The Quickening",
        body: "See, here's the rule about Highlander jokes: _there can be only one_.",
        createdDate: Date(timeIntervalSince1970: 1595514125),
        status: .edited,
        collection: testPostCollection1
    ),
    Post(
        title: "The Post Revolutions",
        body: "I can never keep the Matrix movie order straight. Why not just call them part 2 and part 3?",
        createdDate: Date(timeIntervalSince1970: 1595600006)
    ),
    Post(
        title: "Episode IV: A New Post",
        body: "How many movies does this person watch? How many movie-title jokes will they make?",
        createdDate: Date(timeIntervalSince1970: 1596219877),
        status: .published,
        collection: testPostCollection2
    ),
    Post(
        title: "Fast (Post) Five",
        body: "Look, it was either a Fast and the Furious reference, or a Resident Evil reference."
    ),
    Post(
        title: "Post: The Final Chapter",
        body: "And there you have it, a Resident Evil movie reference.",
        createdDate: Date(timeIntervalSince1970: 1596043684),
        status: .edited,
        collection: testPostCollection3
    )
]
