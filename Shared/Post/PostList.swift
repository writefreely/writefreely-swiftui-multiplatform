import SwiftUI

struct PostList: View {
    @EnvironmentObject var postStore: PostStore
    var title: String
    var posts: [Post]

    var body: some View {
        List {
            Text(pluralizedPostCount(for: posts))
                .foregroundColor(.secondary)
            ForEach(posts) { post in
                PostCell(post: post)
            }
        }
        .navigationTitle(title)
        .toolbar {
            Button(action: {
                print("Creating New Draft!")
            }, label: {
                Image(systemName: "square.and.pencil")
            })
        }
    }

    func pluralizedPostCount(for posts: [Post]) -> String {
        if posts.count == 1 {
            return "1 post"
        } else {
            return "\(posts.count) posts"
        }
    }
}

struct PostList_Previews: PreviewProvider {
    static var previews: some View {
        PostList(title: "Posts", posts: testPostData)
            .environmentObject(testPostStore)
    }
}
