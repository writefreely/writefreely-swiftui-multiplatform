import SwiftUI

// MARK: - Navigation State

final class WFNavigationState: ObservableObject {

    @Published var selectedCollection: WFACollection?
    @Published var selectedPost: WFAPost?
    @Published var showAllPosts: Bool = true

}

// MARK: - Navigation Implementation

struct WFNavigation<CollectionList, PostList, PostDetail>: View
    where CollectionList: View, PostList: View, PostDetail: View {

    @EnvironmentObject var model: WriteFreelyModel
    @FetchRequest(sortDescriptors: []) var collections: FetchedResults<WFACollection>

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
        if #available(iOS 16, *) {
            /// Consider converting this into a NavigationStack instead, and using `$model.selectedCollection` to set
            /// the detail view that should be shown. Try moving navigation state out of **WriteFreelyModel** and into
            /// **WFNavigation** instead, so that it eventually encapsulates _all_ things related to app navigation.
//            NavigationSplitView {
//                collectionList
//            } detail: {
//                postList
//            }

            NavigationStack {
                List(collections, id: \.self, selection: $model.navState.selectedPost) { collection in
                    NavigationLink("\(collection.title)", destination: PostListView(selectedCollection: model.navState.selectedCollection, showAllPosts: model.navState.showAllPosts))
                }
//                List(fetchRequest.wrappedValue, id: \.self, selection: $model.navState.selectedPost) { post in
//                    NavigationLink(
//                        "\(post.title.isEmpty ? "UNTITLED" : post.title)",
//                        destination: PostEditorView(post: post)
//                    )
//                }
            }
        } else {
            NavigationView {
                collectionList
                postList
                postDetail
            }
        }
        #endif
    }

}
