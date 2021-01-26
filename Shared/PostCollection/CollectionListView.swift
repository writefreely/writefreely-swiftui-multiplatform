import SwiftUI

struct CollectionListView: View {
    @EnvironmentObject var model: WriteFreelyModel

    @FetchRequest(
        entity: WFACollection.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \WFACollection.title, ascending: true)]
    ) var collections: FetchedResults<WFACollection>

    var body: some View {
        List(selection: $model.selectedCollection) {
            if model.account.isLoggedIn {
                NavigationLink(
                    destination: PostListView(),
                    isActive: Binding<Bool>(
                        get: { () -> Bool in
                            model.selectedCollection == nil && model.showAllPosts
                        }, set: { newValue in
                            if newValue {
                                self.model.showAllPosts = true
                                self.model.selectedCollection = nil
                            } else {
                                // No-op
                            }
                        }
                    ),
                    label: {
                    Text("All Posts")
                })
                NavigationLink(
                    destination: PostListView(),
                    isActive: Binding<Bool>(
                        get: { () -> Bool in
                            model.selectedCollection == nil && !model.showAllPosts
                        }, set: { newValue in
                            if newValue {
                                self.model.showAllPosts = false
                                self.model.selectedCollection = nil
                            } else {
                                // No-op
                            }
                        }
                    ),
                    label: {
                    Text(model.account.server == "https://write.as" ? "Anonymous" : "Drafts")
                })
                Section(header: Text("Your Blogs")) {
                    ForEach(collections, id: \.self) { collection in
                        NavigationLink(
                            destination: PostListView(),
                            isActive: Binding<Bool>(
                                get: { () -> Bool in
                                    model.selectedCollection == collection && !model.showAllPosts
                                }, set: { newValue in
                                    if newValue {
                                        self.model.showAllPosts = false
                                        self.model.selectedCollection = collection
                                    } else {
                                        // No-op
                                    }
                                }
                            ),
                            label: { Text(collection.title) }
                        )
                    }
                }
            } else {
                NavigationLink(destination: PostListView()) {
                    Text("Drafts")
                }
            }
        }
        .navigationTitle(
            model.account.isLoggedIn ? "\(URL(string: model.account.server)?.host ?? "WriteFreely")" : "WriteFreely"
        )
        .listStyle(SidebarListStyle())
        .onChange(of: model.selectedCollection) { collection in
            if collection != model.editor.fetchSelectedCollectionFromAppStorage() {
                self.model.editor.selectedCollectionURL = collection?.objectID.uriRepresentation()
            }
        }
        .onChange(of: model.showAllPosts) { value in
            if value != model.editor.showAllPostsFlag {
                self.model.editor.showAllPostsFlag = model.showAllPosts
            }
        }
    }
}

struct CollectionListView_LoggedOutPreviews: PreviewProvider {
    static var previews: some View {
        let context = LocalStorageManager.persistentContainer.viewContext
        let model = WriteFreelyModel()

        return CollectionListView()
            .environment(\.managedObjectContext, context)
            .environmentObject(model)
    }
}
