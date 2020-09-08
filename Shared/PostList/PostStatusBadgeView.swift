import SwiftUI

struct PostStatusBadgeView: View {
    @ObservedObject var post: WFAPost

    var body: some View {
        let (badgeLabel, badgeColor) = setupBadgeProperties(for: PostStatus(rawValue: post.status)!)
        Text(badgeLabel)
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .textCase(.uppercase)
            .lineLimit(1)
            .padding(EdgeInsets(top: 2.5, leading: 7.5, bottom: 2.5, trailing: 7.5))
            .background(badgeColor)
            .clipShape(RoundedRectangle(cornerRadius: 5.0, style: .circular))
    }

    func setupBadgeProperties(for status: PostStatus) -> (String, Color) {
        var badgeLabel: String
        var badgeColor: Color

        switch status {
        case .local:
            badgeLabel = "local"
            badgeColor = Color(red: 0.75, green: 0.5, blue: 0.85, opacity: 1.0)
        case .edited:
            badgeLabel = "edited"
            badgeColor = Color(red: 0.75, green: 0.7, blue: 0.1, opacity: 1.0)
        case .published:
            badgeLabel = "published"
            badgeColor = .gray
        }

        return (badgeLabel, badgeColor)
    }
}

//#if DEBUG
//let userCollection1 = WFACollection(context: PersistenceManager.persistentContainer.viewContext)
//let userCollection2 = WFACollection(context: PersistenceManager.persistentContainer.viewContext)
//let userCollection3 = WFACollection(context: PersistenceManager.persistentContainer.viewContext)
//
//let testPostData = [
//    Post(
//        title: "My First Post",
//        body: "Look at me, creating a first post! That's cool.",
//        createdDate: Date(timeIntervalSince1970: 1595429452),
//        status: .published,
//        collection: userCollection1
//    ),
//    Post(
//        title: "Post 2: The Quickening",
//        body: "See, here's the rule about Highlander jokes: _there can be only one_.",
//        createdDate: Date(timeIntervalSince1970: 1595514125),
//        status: .edited,
//        collection: userCollection1
//    ),
//    Post(
//        title: "The Post Revolutions",
//        body: "I can never keep the Matrix movie order straight. Why not just call them part 2 and part 3?",
//        createdDate: Date(timeIntervalSince1970: 1595600006)
//    ),
//    Post(
//        title: "Episode IV: A New Post",
//        body: "How many movies does this person watch? How many movie-title jokes will they make?",
//        createdDate: Date(timeIntervalSince1970: 1596219877),
//        status: .published,
//        collection: userCollection2
//    ),
//    Post(
//        title: "Fast (Post) Five",
//        body: "Look, it was either a Fast and the Furious reference, or a Resident Evil reference."
//    ),
//    Post(
//        title: "Post: The Final Chapter",
//        body: "And there you have it, a Resident Evil movie reference.",
//        createdDate: Date(timeIntervalSince1970: 1596043684),
//        status: .edited,
//        collection: userCollection3
//    )
//]
//#endif
//
//struct PostStatusBadge_LocalDraftPreviews: PreviewProvider {
//    static var previews: some View {
//        userCollection1.title = "Collection 1"
//        return PostStatusBadgeView(post: testPostData[2])
//    }
//}
//
//struct PostStatusBadge_EditedPreviews: PreviewProvider {
//    static var previews: some View {
//        userCollection1.title = "Collection 1"
//        return PostStatusBadgeView(post: testPostData[1])
//    }
//}
//
//struct PostStatusBadge_PublishedPreviews: PreviewProvider {
//    static var previews: some View {
//        PostStatusBadgeView(post: testPostData[0])
//    }
//}
