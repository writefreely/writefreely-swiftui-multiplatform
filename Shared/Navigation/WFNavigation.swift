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
        if #available(macOS 13, *) {
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
        #else
        // If we uncomment this, when we back out of the postDetail to the postList, the app further backs us out
        // to the collectionList for some reason.
//        if #available(iOS 16, *) {
//            NavigationSplitView {
//                collectionList
//            } content: {
//                postList
//            } detail: {
//                postDetail
//            }
//        } else {
            NavigationView {
                collectionList
                postList
                postDetail
            }
//        }
        #endif
    }
}
