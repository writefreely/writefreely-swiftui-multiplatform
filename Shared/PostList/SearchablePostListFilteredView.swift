import SwiftUI

@available(iOS 15, macOS 12.0, *)
struct SearchablePostListFilteredView: View {
    @EnvironmentObject var model: WriteFreelyModel
    @Binding var postCount: Int
    @State private var searchString = ""

    // Only used for NavigationStack in iOS 16/macOS 13 or later
    @State private var path: [WFAPost] = []

    var collections: FetchedResults<WFACollection>
    var fetchRequest: FetchRequest<WFAPost>
    var onDelete: (WFAPost) -> Void

    var body: some View {
//        if #available(iOS 16, macOS 13, *) {
//            NavigationStack(path: $path) {
//                Text("Hello, modern stack navigator!")
//            }
//        } else {
        DeprecatedListView(
            searchString: $searchString,
            collections: collections,
            fetchRequest: fetchRequest,
            onDelete: onDelete
        )
//        }
    }

    func delete(_ post: WFAPost) {
        onDelete(post)
    }
}
