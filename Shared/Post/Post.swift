import Foundation
import WriteFreely

struct Post: Identifiable {
    var id = UUID()
    var title: String
    var body: String
    var createdDate: Date
    var status: PostStatus = .draft
    var editableText: String {
        return """
                # \(self.title)

                \(self.body)
                """
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
    createdDate: Date(),
    status: .published)

let testPostData = [
    Post(
        title: "My First Post",
        body: "Look at me, creating a first post! That's cool.",
        createdDate: Date(timeIntervalSince1970: 1595429452),
        status: .published
    ),
    Post(
        title: "Post 2: The Quickening",
        body: "See, here's the rule about Highlander jokes: _there can be only one_.",
        createdDate: Date(timeIntervalSince1970: 1595514125),
        status: .edited
    ),
    Post(
        title: "The Post Revolutions",
        body: "I can never keep the Matrix movie order straight. Why not just call them part 2 and part 3?",
        createdDate: Date(timeIntervalSince1970: 1595600006)
    )
]
