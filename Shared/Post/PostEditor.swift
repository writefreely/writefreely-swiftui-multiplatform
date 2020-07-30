import SwiftUI

struct PostEditor: View {
    @EnvironmentObject var postStore: PostStore
    @ObservedObject var post: Post
    @State private var isNewPost = false

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
            ToolbarItem(placement: .status) {
                PostStatusBadge(post: post)
            }
        }
        .onAppear(perform: checkIfNewPost)
        .onDisappear(perform: addPostToStore)
    }

    private func checkIfNewPost() {
        if !postStore.posts.contains(where: { $0.id == post.id }) {
            self.isNewPost = true
        }
    }

    private func addPostToStore() {
        if isNewPost {
            withAnimation {
                postStore.add(post)
            }
        }
    }
}

struct PostEditor_Previews: PreviewProvider {
    static var previews: some View {
        PostEditor(post: testPost)
    }
}
