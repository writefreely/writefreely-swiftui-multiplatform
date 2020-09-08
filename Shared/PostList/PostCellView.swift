import SwiftUI

struct PostCellView: View {
    @ObservedObject var post: WFAPost

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(post.title ?? "")
                    .font(.headline)
                    .lineLimit(1)
                Text(buildDateString(from: post.createdDate ?? Date()))
                    .font(.caption)
                    .lineLimit(1)
            }
            Spacer()
            PostStatusBadgeView(post: post)
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

//struct PostCell_Previews: PreviewProvider {
//    static var previews: some View {
//        let testPost = Post(
//            title: "Test Post Title",
//            body: "Here's some cool sample body text.",
//            createdDate: Date()
//        )
//        return PostCellView(post: testPost)
//    }
//}
