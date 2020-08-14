import SwiftUI

struct PostStatusBadge: View {
    @ObservedObject var post: Post

    var body: some View {
        let (badgeLabel, badgeColor) = setupBadgeProperties(for: post.status)
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
        case .draft:
            badgeLabel = "draft"
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

struct PostStatusBadge_DraftPreviews: PreviewProvider {
    static var previews: some View {
        PostStatusBadge(post: testPostData[0])
    }
}

struct PostStatusBadge_EditedPreviews: PreviewProvider {
    static var previews: some View {
        Group {
            PostStatusBadge(post: testPostData[1])
        }
    }
}

struct PostStatusBadge_PublishedPreviews: PreviewProvider {
    static var previews: some View {
        PostStatusBadge(post: testPostData[2])
    }
}
