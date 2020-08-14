import SwiftUI

struct PostCell: View {
    @EnvironmentObject var postStore: PostStore
    @ObservedObject var post: Post

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(post.title)
                    .font(.headline)
                    .lineLimit(1)
                Text(buildDateString(from: post.createdDate))
                    .font(.caption)
                    .lineLimit(1)
            }
            Spacer()
            PostStatusBadge(post: post)
        }
        .padding(5)
    }

    func buildDateString(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short

        return dateFormatter.string(from: date)
    }
}

struct PostCell_Previews: PreviewProvider {
    static var previews: some View {
        PostCell(post: testPost)
    }
}
