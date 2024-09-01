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
            NavigationStack {
                if model.account.isLoggedIn {
                    List(selection: $model.navState.selectedCollection) {
                        NavigationLink(
                            "All Posts",
                            destination: PostListView(selectedCollection: nil, showAllPosts: true)
                        )
                        NavigationLink(
                            model.account.server == "https://write.as" ? "Anonymous" : "Drafts",
                            destination: PostListView(selectedCollection: nil, showAllPosts: false)
                        )
                        Section("Your Blogs") {
                            ForEach(collections, id: \.self) { collection in
                                NavigationLink(
                                    "\(collection.title)",
                                    destination: PostListView(
                                        selectedCollection: model.navState.selectedCollection,
                                        showAllPosts: model.navState.showAllPosts
                                    )
                                )
                            }
                        }
                    }
                    .navigationTitle("\(URL(string: model.account.server)?.host ?? "WriteFreely")")
                } else {
                    List {
                        NavigationLink(
                            "Drafts",
                            destination: PostListView(selectedCollection: nil, showAllPosts: false)
                        )
                    }
                    .navigationTitle("WriteFreely")
                }
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
