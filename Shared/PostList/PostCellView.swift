import SwiftUI

struct PostCellView: View {
    @EnvironmentObject var model: WriteFreelyModel
    @ObservedObject var post: WFAPost
    var collectionName: String?

    static let createdDateFormat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter
    }()

    var titleText: String {
        if post.title.isEmpty {
            return model.posts.getBodyPreview(of: post)
        }
        return post.title
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                if let collectionName = collectionName {
                    Text(collectionName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(EdgeInsets(top: 3, leading: 4, bottom: 3, trailing: 4))
                        .overlay(RoundedRectangle(cornerRadius: 2).stroke(Color.secondary, lineWidth: 1))
                }
                Text(titleText)
                    .font(.headline)
                Text(post.createdDate ?? Date(), formatter: Self.createdDateFormat)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, -3)
            }
            Spacer()
            PostStatusBadgeView(post: post)
        }
        .padding(5)
        .contextMenu {
            Button(
                action: didTapDeleteContextMenuItem,
                label: { Label("Delete", systemImage: "trash") }
            )
            .disabled(post.status != PostStatus.local.rawValue)
        }
    }

    private func didTapDeleteContextMenuItem() {
        guard post.status == PostStatus.local.rawValue else { return }
        if post === model.navState.selectedPost {
            model.navState.selectedPost = nil
            model.editor.clearLastDraft()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            model.posts.remove(post)
        }
    }
}

struct PostCell_AllPostsPreviews: PreviewProvider {
    static var previews: some View {
        let context = LocalStorageManager.standard.container.viewContext
        let testPost = WFAPost(context: context)
        testPost.title = "Test Post Title"
        testPost.body = "Here's some cool sample body text."
        testPost.createdDate = Date()

        return PostCellView(post: testPost, collectionName: "My Cool Blog")
            .environment(\.managedObjectContext, context)
    }
}

struct PostCell_NormalPreviews: PreviewProvider {
    static var previews: some View {
        let context = LocalStorageManager.standard.container.viewContext
        let testPost = WFAPost(context: context)
        testPost.title = "Test Post Title"
        testPost.body = "Here's some cool sample body text."
        testPost.collectionAlias = "My Cool Blog"
        testPost.createdDate = Date()

        return PostCellView(post: testPost)
            .environment(\.managedObjectContext, context)
    }
}

struct PostCell_NoTitlePreviews: PreviewProvider {
    static var previews: some View {
        let context = LocalStorageManager.standard.container.viewContext
        let testPost = WFAPost(context: context)
        testPost.title = ""
        testPost.body = "Here's some cool sample body text."
        testPost.collectionAlias = "My Cool Blog"
        testPost.createdDate = Date()

        return PostCellView(post: testPost)
            .environment(\.managedObjectContext, context)
    }
}
