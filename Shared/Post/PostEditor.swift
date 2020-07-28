import SwiftUI

struct PostEditor: View {
    @ObservedObject var post: Post

    var body: some View {
        VStack {
            TextEditor(text: $post.title)
                .font(.title)
                .frame(height: 100)
                .onChange(of: post.title) { _ in
                    if post.status == .published {
                        post.status = .edited
                    }
                }
            TextEditor(text: $post.body)
                .font(.body)
                .onChange(of: post.body) { _ in
                    if post.status == .published {
                        post.status = .edited
                    }
                }
        }
        .padding()
        .toolbar {
            PostStatusBadge(post: post)
        }
    }
}

struct PostEditor_Previews: PreviewProvider {
    static var previews: some View {
        PostEditor(post: testPost)
    }
}
