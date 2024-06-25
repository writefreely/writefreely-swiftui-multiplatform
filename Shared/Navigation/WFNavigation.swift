import SwiftUI

struct WFNavigation<CollectionList, PostList, PostDetail>: View
    where CollectionList: View, PostList: View, PostDetail: View {

    private var collectionList: CollectionList
    private var postList: PostList
    private var postDetail: PostDetail

    init(
        @ViewBuilder collectionList: () -> CollectionList,
        @ViewBuilder postList: () -> PostList,
        @ViewBuilder postDetail: () -> PostDetail
    ) {
        self.collectionList = collectionList()
        self.postList = postList()
        self.postDetail = postDetail()
    }

    var body: some View {
        if #available(iOS 16, macOS 13, *) {
            /// This works better in iOS 17.5 but still has some issues:
            /// - Does not respect the editor-launching policy, going right to the NoSelectedPostView
            NavigationSplitView {
                collectionList
            } content: {
                postList
            } detail: {
                postDetail
            }
        } else {
            NavigationView {
                collectionList
                postList
                postDetail
            }
        }
    }
}
