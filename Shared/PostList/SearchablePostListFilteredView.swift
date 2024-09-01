import SwiftUI

@available(iOS 15, macOS 12.0, *)
struct SearchablePostListFilteredView: View {
    @EnvironmentObject var model: WriteFreelyModel
    @State private var searchString = ""

    var collections: FetchedResults<WFACollection>
    var fetchRequest: FetchRequest<WFAPost>
    var onDelete: (WFAPost) -> Void

    var body: some View {
        if #available(iOS 16, macOS 13, *) {
            /// TODO: Add back post search
            NavigationStack {
                List(fetchRequest.wrappedValue, id: \.self, selection: $model.navState.selectedPost) { post in
                    NavigationLink(
                        destination: PostEditorView(post: post),
                        label: {
                            if model.navState.showAllPosts {
                                if let collection = collections.filter({ $0.alias == post.collectionAlias }).first {
                                    PostCellView(post: post, collectionName: collection.title)
                                } else {
                                    let collectionName = model.account.server == "https://write.as" ? "Anonymous" : "Drafts"
                                    PostCellView(post: post, collectionName: collectionName)
                                }
                            } else {
                                PostCellView(post: post)
                            }
                        }
                    )
                }
            }
        } else {
            DeprecatedListView(
                searchString: $searchString,
                collections: collections,
                fetchRequest: fetchRequest,
                onDelete: onDelete
            )
        }
    }

    func delete(_ post: WFAPost) {
        onDelete(post)
    }
}
