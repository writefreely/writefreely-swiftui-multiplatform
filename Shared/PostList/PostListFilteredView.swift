import SwiftUI

struct PostListFilteredView: View {
    @EnvironmentObject var model: WriteFreelyModel
    @Binding var postCount: Int
    @FetchRequest(entity: WFACollection.entity(), sortDescriptors: []) var collections: FetchedResults<WFACollection>

    var fetchRequest: FetchRequest<WFAPost>

    init(collection: WFACollection?, showAllPosts: Bool, postCount: Binding<Int>) {
        if showAllPosts {
            fetchRequest = FetchRequest<WFAPost>(
                entity: WFAPost.entity(),
                sortDescriptors: [NSSortDescriptor(key: "createdDate", ascending: false)]
            )
        } else {
            if let collectionAlias = collection?.alias {
                fetchRequest = FetchRequest<WFAPost>(
                    entity: WFAPost.entity(),
                    sortDescriptors: [NSSortDescriptor(key: "createdDate", ascending: false)],
                    predicate: NSPredicate(format: "collectionAlias == %@", collectionAlias)
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
        if #available(iOS 15, *) {
            SearchablePostListFilteredView(
                postCount: $postCount,
                collections: collections,
                fetchRequest: fetchRequest,
                onDelete: delete(_:)
            )
            .environmentObject(model)
            .onAppear(perform: {
                self.postCount = fetchRequest.wrappedValue.count
            })
            .onChange(of: fetchRequest.wrappedValue.count, perform: { value in
                self.postCount = value
            })
        } else {
            List(selection: $model.selectedPost) {
                ForEach(fetchRequest.wrappedValue, id: \.self) { post in
                    NavigationLink(
                        destination: PostEditorView(post: post),
                        tag: post,
                        selection: $model.selectedPost,
                        label: {
                            if model.showAllPosts {
                                if let collection = collections.filter { $0.alias == post.collectionAlias }.first {
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
        }
        #else
        SearchablePostListFilteredView(
            postCount: $postCount,
            collections: collections,
            fetchRequest: fetchRequest,
            onDelete: delete(_:)
        )
        .environmentObject(model)
        .alert(isPresented: $model.isPresentingDeleteAlert) {
            Alert(
                title: Text("Delete Post?"),
                message: Text("This action cannot be undone."),
                primaryButton: .cancel {
                    model.postToDelete = nil
                },
                secondaryButton: .destructive(Text("Delete"), action: {
                    if let postToDelete = model.postToDelete {
                        model.selectedPost = nil
                        DispatchQueue.main.async {
                            model.editor.clearLastDraft()
                            model.posts.remove(postToDelete)
                        }
                        model.postToDelete = nil
                    }
                })
            )
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
        DispatchQueue.main.async {
            if post == model.selectedPost {
                model.selectedPost = nil
                model.editor.clearLastDraft()
            }
            model.posts.remove(post)
        }
    }
}

struct PostListFilteredView_Previews: PreviewProvider {
    static var previews: some View {
        return PostListFilteredView(
            collection: nil,
            showAllPosts: false,
            postCount: .constant(999)
        )
        .environmentObject(WriteFreelyModel())
    }
}
