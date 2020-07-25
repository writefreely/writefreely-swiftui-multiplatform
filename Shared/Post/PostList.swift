import SwiftUI

struct PostList: View {
    var postStore: PostStore

    var body: some View {
        List {
            Text("\(postStore.posts.count) Posts")
                .foregroundColor(.secondary)
            ForEach(postStore.posts) { post in
                PostCell(post: post)
            }
        }
    }
}

struct PostList_Previews: PreviewProvider {
    static var previews: some View {
        PostList(postStore: testPostStore)
    }
}
