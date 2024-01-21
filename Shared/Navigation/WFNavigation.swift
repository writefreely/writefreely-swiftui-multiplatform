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
        #if os(macOS)
        NavigationSplitView {
            collectionList
        } content: {
            postList
        } detail: {
            postDetail
        }
        #else
        NavigationView {
            collectionList
            postList
            postDetail
        }
        #endif
    }
}
