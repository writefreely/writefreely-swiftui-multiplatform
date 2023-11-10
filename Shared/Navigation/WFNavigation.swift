import SwiftUI

struct WFNavigation<CollectionList, PostList, PostDetail>: View
    where CollectionList: View, PostList: View, PostDetail: View {
    @ViewBuilder var collectionList: () -> CollectionList
    @ViewBuilder var postList: () -> PostList
    @ViewBuilder var postDetail: () -> PostDetail

    var body: some View {
        if #available(iOS 16, macOS 13, *) {
            NavigationSplitView {
                collectionList()
            } content: {
                postList()
            } detail: {
                postDetail()
            }
        } else {
            NavigationView {
                collectionList()
                postList()
                postDetail()
            }
        }
    }
}
