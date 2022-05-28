import SwiftUI

struct CollectionListView: View {
    @EnvironmentObject var model: WriteFreelyModel
    @EnvironmentObject var errorHandling: ErrorHandling
//    @ObservedObject var collections = CollectionListModel(
//        managedObjectContext: LocalStorageManager.standard.container.viewContext
//    )
    @FetchRequest(sortDescriptors: []) var collections: FetchedResults<WFACollection>
    @State var selectedCollection: WFACollection?

    var body: some View {
        List(selection: $selectedCollection) {
            if model.account.isLoggedIn {
                NavigationLink("All Posts", destination: PostListView(selectedCollection: nil, showAllPosts: true))
                NavigationLink("Drafts", destination: PostListView(selectedCollection: nil, showAllPosts: false))
                Section(header: Text("Your Blogs")) {
                    ForEach(collections, id: \.self) { collection in
                        NavigationLink(destination: PostListView(selectedCollection: collection, showAllPosts: false),
                                       tag: collection,
                                       selection: $selectedCollection,
                                       label: { Text("\(collection.title)") })
                    }
                }
            } else {
                NavigationLink(destination: PostListView(selectedCollection: nil, showAllPosts: false)) {
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
        .onChange(of: model.hasError) { value in
            if value {
                if let error = model.currentError {
                    self.errorHandling.handle(error: error)
                } else {
                    self.errorHandling.handle(error: AppError.genericError())
                }
                model.hasError = false
            }
        }
    }
}

struct CollectionListView_LoggedOutPreviews: PreviewProvider {
    static var previews: some View {
        let context = LocalStorageManager.standard.container.viewContext
        let model = WriteFreelyModel()

        return CollectionListView()
            .environment(\.managedObjectContext, context)
            .environmentObject(model)
    }
}
