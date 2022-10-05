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
            .frame(width: .infinity)
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

struct PostStatusBadge_LocalDraftPreviews: PreviewProvider {
    static var previews: some View {
        let context = LocalStorageManager.standard.container.viewContext
        let testPost = WFAPost(context: context)
        testPost.status = PostStatus.local.rawValue

        return PostStatusBadgeView(post: testPost)
            .environment(\.managedObjectContext, context)
    }
}

struct PostStatusBadge_EditedPreviews: PreviewProvider {
    static var previews: some View {
        let context = LocalStorageManager.standard.container.viewContext
        let testPost = WFAPost(context: context)
        testPost.status = PostStatus.edited.rawValue

        return PostStatusBadgeView(post: testPost)
            .environment(\.managedObjectContext, context)
    }
}

struct PostStatusBadge_PublishedPreviews: PreviewProvider {
    static var previews: some View {
        let context = LocalStorageManager.standard.container.viewContext
        let testPost = WFAPost(context: context)
        testPost.status = PostStatus.published.rawValue

        return PostStatusBadgeView(post: testPost)
            .environment(\.managedObjectContext, context)
    }
}
