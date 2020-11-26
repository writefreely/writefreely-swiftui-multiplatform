import SwiftUI

struct PostListFilteredView: View {
    @EnvironmentObject var model: WriteFreelyModel
    @Binding var postCount: Int
    @FetchRequest(entity: WFACollection.entity(), sortDescriptors: []) var collections: FetchedResults<WFACollection>
    var fetchRequest: FetchRequest<WFAPost>
    var showAllPosts: Bool

    init(filter: String?, showAllPosts: Bool, postCount: Binding<Int>) {
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
        _postCount = postCount
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
        .onAppear(perform: {
            self.postCount = fetchRequest.wrappedValue.count
        })
        .onChange(of: fetchRequest.wrappedValue.count, perform: { value in
            self.postCount = value
        })
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
        .onAppear(perform: {
            self.postCount = fetchRequest.wrappedValue.count
        })
        .onChange(of: fetchRequest.wrappedValue.count, perform: { value in
            self.postCount = value
        })
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
        DispatchQueue.main.async {
            model.posts.remove(post)
        }
    }
}

struct PostListFilteredView_Previews: PreviewProvider {
    static var previews: some View {
        return PostListFilteredView(filter: nil, showAllPosts: false, postCount: .constant(999))
    }
}
