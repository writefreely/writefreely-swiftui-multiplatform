import SwiftUI

struct ActivePostToolbarView: View {
    @EnvironmentObject var model: WriteFreelyModel
    @ObservedObject var activePost: WFAPost

    @State private var selectedCollection: WFACollection?

    @FetchRequest(
        entity: WFACollection.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \WFACollection.title, ascending: true)]
    ) var collections: FetchedResults<WFACollection>

    var body: some View {
        HStack {
            if model.account.isLoggedIn && activePost.status != PostStatus.local.rawValue {
                Section(header: Text("Move To:")) {
                    Picker(selection: $selectedCollection, label: Text("Move To…"), content: {
                        Text("\(model.account.server == "https://write.as" ? "Anonymous" : "Drafts")")
                            .tag(nil as WFACollection?)
                        Divider()
                        ForEach(collections) { collection in
                            Text("\(collection.title)").tag(collection as WFACollection?)
                        }
                    })
                }
            }
            PostEditorStatusToolbarView(post: activePost)
                .layoutPriority(1)
            HStack(spacing: 4) {
                Button(action: {}, label: { Image(systemName: "square.and.arrow.up") })
                    .disabled(activePost.status == PostStatus.local.rawValue)
                Button(action: { publishPost(activePost) }, label: { Image(systemName: "paperplane") })
                    .disabled(activePost.body.isEmpty || activePost.status == PostStatus.published.rawValue)
            }
        }
        .onAppear(perform: {
            self.selectedCollection = collections.first { $0.alias == activePost.collectionAlias }
        })
        .onChange(of: selectedCollection, perform: { [selectedCollection] newCollection in
            if activePost.collectionAlias == newCollection?.alias {
                return
            } else {
                withAnimation {
                    activePost.collectionAlias = newCollection?.alias
                    model.move(post: activePost, from: selectedCollection, to: newCollection)
                }
            }
        })
    }

    private func publishPost(_ post: WFAPost) {
        DispatchQueue.main.async {
            LocalStorageManager().saveContext()
            model.publish(post: post)
        }
    }
}
