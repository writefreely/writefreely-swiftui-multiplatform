import SwiftUI

struct PostEditor: View {
    @ObservedObject var post: Post
    @State private var hasUnpublishedChanges: Bool = false

    var body: some View {
        VStack {
            TextEditor(text: $post.title)
                .border(Color.blue, width: 1)
                .font(.title)
                .frame(height: 100)
                .onChange(of: post.title) { _ in
                    if post.status == .published {
                        hasUnpublishedChanges = true
                    }
                }
            TextEditor(text: $post.body)
                .border(Color.red, width: 1)
                .font(.body)
                .onChange(of: post.body) { _ in
                    if post.status == .published {
                        hasUnpublishedChanges = true
                    }
                }
        }
        .padding()
        .toolbar {
            if hasUnpublishedChanges {
                PostStatusBadge(postStatus: .edited)
            } else {
                PostStatusBadge(postStatus: post.status)
            }
        }
    }
}

struct PostEditor_Previews: PreviewProvider {
    static var previews: some View {
        PostEditor(post: testPost)
    }
}
