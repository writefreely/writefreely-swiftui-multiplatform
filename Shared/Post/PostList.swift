import SwiftUI

struct PostList: View {
    @EnvironmentObject var postStore: PostStore
    var title: String
    var posts: [Post]

    var body: some View {
        List {
            Text("\(posts.count) Posts")
                .foregroundColor(.secondary)
            ForEach(posts) { post in
                PostCell(post: post)
            }
        }
        .navigationTitle(title)
    }
}

struct PostList_Previews: PreviewProvider {
    static var previews: some View {
        PostList(title: "Posts", posts: testPostData)
            .environmentObject(testPostStore)
    }
}
