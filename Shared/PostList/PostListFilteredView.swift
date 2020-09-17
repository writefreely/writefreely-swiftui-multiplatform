import SwiftUI

struct PostListFilteredView: View {
    @EnvironmentObject var model: WriteFreelyModel

    var fetchRequest: FetchRequest<WFAPost>

    init(filter: String?, showAllPosts: Bool) {
        if showAllPosts {
            fetchRequest = FetchRequest<WFAPost>(
                entity: WFAPost.entity(),
                sortDescriptors: [NSSortDescriptor(key: "createdDate", ascending: false)]
            )
        } else {
            if let filter = filter {
                fetchRequest = FetchRequest<WFAPost>(
                    entity: WFAPost.entity(),
                    sortDescriptors: [NSSortDescriptor(key: "createdDate", ascending: false)],
                    predicate: NSPredicate(format: "collectionAlias == %@", filter)
                )
            } else {
                fetchRequest = FetchRequest<WFAPost>(
                    entity: WFAPost.entity(),
                    sortDescriptors: [NSSortDescriptor(key: "createdDate", ascending: false)],
                    predicate: NSPredicate(format: "collectionAlias == nil")
                )
            }
        }
    }

    var body: some View {
        List {
            ForEach(fetchRequest.wrappedValue, id: \.self) { post in
                NavigationLink(
                    destination: PostEditorView(post: post),
                    tag: post,
                    selection: $model.selectedPost
                ) {
                    PostCellView(post: post)
                }
            }.onDelete(perform: { indexSet in
                for index in indexSet {
                    let post = fetchRequest.wrappedValue[index]
                    if post.status == PostStatus.local.rawValue {
                        delete(post)
                    }
                }
            })
        }
    }

    func delete(_ post: WFAPost) {
        model.posts.remove(post)
    }
}

struct PostListFilteredView_Previews: PreviewProvider {
    static var previews: some View {
        return PostListFilteredView(filter: nil, showAllPosts: false)
    }
}
