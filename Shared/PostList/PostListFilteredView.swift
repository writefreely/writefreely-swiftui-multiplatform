import SwiftUI

struct PostListFilteredView: View {
    @EnvironmentObject var model: WriteFreelyModel

    @FetchRequest(entity: WFACollection.entity(), sortDescriptors: []) var collections: FetchedResults<WFACollection>
    var fetchRequest: FetchRequest<WFAPost>
    var showAllPosts: Bool

    init(filter: String?, showAllPosts: Bool) {
        self.showAllPosts = showAllPosts
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
        #if os(iOS)
        List {
            ForEach(fetchRequest.wrappedValue, id: \.self) { post in
                NavigationLink(
                    destination: PostEditorView(post: post),
                    tag: post,
                    selection: $model.selectedPost
                ) {
                    if showAllPosts {
                        if let collection = collections.filter { $0.alias == post.collectionAlias }.first {
                            PostCellView(post: post, collectionName: collection.title)
                        } else {
                            let collectionName = model.account.server == "https://write.as" ? "Anonymous" : "Drafts"
                            PostCellView(post: post, collectionName: collectionName)
                        }
                    } else {
                        PostCellView(post: post)
                    }
                }
                .deleteDisabled(post.status != PostStatus.local.rawValue)
            }
            .onDelete(perform: { indexSet in
                for index in indexSet {
                    let post = fetchRequest.wrappedValue[index]
                    delete(post)
                }
            })
        }
        #else
        List {
            ForEach(fetchRequest.wrappedValue, id: \.self) { post in
                NavigationLink(
                    destination: PostEditorView(post: post),
                    tag: post,
                    selection: $model.selectedPost
                ) {
                    PostCellView(post: post)
                }
                .deleteDisabled(post.status != PostStatus.local.rawValue)
            }
            .onDelete(perform: { indexSet in
                for index in indexSet {
                    let post = fetchRequest.wrappedValue[index]
                    delete(post)
                }
            })
        }
        .onDeleteCommand(perform: {
            guard let selectedPost = model.selectedPost else { return }
            if selectedPost.status == PostStatus.local.rawValue {
                model.postToDelete = selectedPost
                model.isPresentingDeleteAlert = true
            }
        })
        #endif
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
