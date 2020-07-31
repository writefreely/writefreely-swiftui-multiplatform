import SwiftUI

struct PostList: View {
    @EnvironmentObject var postStore: PostStore
    var title: String

    var body: some View {
        List {
            Text("\(postStore.posts.count) Posts")
                .foregroundColor(.secondary)
            ForEach(postStore.posts) { post in
                PostCell(post: post)
            }
        }
        .navigationTitle(title)
    }
}

struct PostList_Previews: PreviewProvider {
    static var previews: some View {
        PostList(title: "Posts")
            .environmentObject(testPostStore)
    }
}
