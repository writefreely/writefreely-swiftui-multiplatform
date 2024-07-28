import SwiftUI

@available(iOS 15, macOS 12.0, *)
struct DeprecatedListView: View {
    @EnvironmentObject var model: WriteFreelyModel
    @Binding var searchString: String

    var collections: FetchedResults<WFACollection>
    var fetchRequest: FetchRequest<WFAPost>
    var onDelete: (WFAPost) -> Void

    var body: some View {
        List(selection: $model.selectedPost) {
            ForEach(fetchRequest.wrappedValue, id: \.self) { post in
                if !searchString.isEmpty &&
                    !post.title.localizedCaseInsensitiveContains(searchString) &&
                    !post.body.localizedCaseInsensitiveContains(searchString) {
                    EmptyView()
                } else {
                    NavigationLink(
                        destination: PostEditorView(post: post),
                        tag: post,
                        selection: $model.selectedPost,
                        label: {
                            if model.showAllPosts {
                                if let collection = collections.filter({ $0.alias == post.collectionAlias }).first {
                                    PostCellView(post: post, collectionName: collection.title)
                                } else {
                                    // swiftlint:disable:next line_length
                                    let collectionName = model.account.server == "https://write.as" ? "Anonymous" : "Drafts"
                                    PostCellView(post: post, collectionName: collectionName)
                                }
                            } else {
                                PostCellView(post: post)
                            }
                        })
                    .deleteDisabled(post.status != PostStatus.local.rawValue)
                }
            }
            .onDelete(perform: { indexSet in
                for index in indexSet {
                    let post = fetchRequest.wrappedValue[index]
                    delete(post)
                }
            })
        }
#if os(iOS)
        .searchable(text: $searchString, prompt: "Search across posts")
#else
        .searchable(text: $searchString, placement: .toolbar, prompt: "Search across posts")
#endif
    }

    func delete(_ post: WFAPost) {
        onDelete(post)
    }
}
