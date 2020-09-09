import SwiftUI

struct PostListFilteredView: View {
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
        List(fetchRequest.wrappedValue, id: \.self) { post in
            NavigationLink(destination: PostEditorView(post: post)) {
                PostCellView(post: post)
            }
        }
    }
}

struct PostListFilteredView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceManager.persistentContainer.viewContext

        return PostListFilteredView(filter: nil, showAllPosts: false)
            .environment(\.managedObjectContext, context)
    }
}
