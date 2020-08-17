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
                PostStatusBadgeView(post: post)
            }
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    post.status = .published
                }, label: {
                    Image(systemName: "paperplane")
                })
            }
        }
        .onAppear(perform: {
            checkIfNewPost()
            if self.isNewPost {
                addNewPostToStore()
            }
        })
    }

    private func checkIfNewPost() {
        self.isNewPost = !postStore.posts.contains(where: { $0.id == post.id })
    }

    private func addNewPostToStore() {
        withAnimation {
            postStore.add(post)
            self.isNewPost = false
        }
    }
}

struct PostEditor_NewDraftPreviews: PreviewProvider {
    static var previews: some View {
        PostEditor(post: Post())
            .environmentObject(testPostStore)
    }
}

struct PostEditor_ExistingPostPreviews: PreviewProvider {
    static var previews: some View {
        PostEditor(post: testPostData[0])
            .environmentObject(testPostStore)
    }
}
