import SwiftUI

struct ActivePostToolbarView: View {
    @EnvironmentObject var model: WriteFreelyModel
    @ObservedObject var activePost: WFAPost
    @State private var isPresentingSharingServicePicker: Bool = false

    @State private var selectedCollection: WFACollection?

    @FetchRequest(
        entity: WFACollection.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \WFACollection.title, ascending: true)]
    ) var collections: FetchedResults<WFACollection>

    var body: some View {
        HStack {
            if model.account.isLoggedIn &&
                activePost.status != PostStatus.local.rawValue &&
                !(activePost.wasDeletedFromServer || activePost.hasNewerRemoteCopy) {
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
                .frame(minWidth: 50, alignment: .center)
                .layoutPriority(1)
                .padding(.horizontal)
            if activePost.status == PostStatus.local.rawValue {
                Menu(content: {
                    Label("Publish To:", systemImage: "paperplane")
                    Divider()
                    Button(action: {
                        if model.account.isLoggedIn {
                            withAnimation {
                                activePost.collectionAlias = nil
                                publishPost(activePost)
                            }
                        } else {
                            openSettingsWindow()
                        }
                    }, label: {
                        Text("\(model.account.server == "https://write.as" ? "Anonymous" : "Drafts")")
                    })
                    ForEach(collections) { collection in
                        Button(action: {
                            if model.account.isLoggedIn {
                                withAnimation {
                                    activePost.collectionAlias = collection.alias
                                    publishPost(activePost)
                                }
                            } else {
                                openSettingsWindow()
                            }
                        }, label: {
                            Text("\(collection.title)")
                        })
                    }
                }, label: {
                    Label("Publish…", systemImage: "paperplane")
                })
                .disabled(activePost.body.isEmpty)
            } else {
                HStack(spacing: 4) {
                    Button(
                        action: {
                            self.isPresentingSharingServicePicker = true
                        },
                        label: { Image(systemName: "square.and.arrow.up") }
                    )
                    .disabled(activePost.status == PostStatus.local.rawValue)
                    .popover(isPresented: $isPresentingSharingServicePicker) {
                        PostEditorSharingPicker(
                            isPresented: $isPresentingSharingServicePicker,
                            sharingItems: createPostUrl()
                        )
                        .frame(width: .zero, height: .zero)
                    }
                    Button(action: { publishPost(activePost) }, label: { Image(systemName: "paperplane") })
                        .disabled(activePost.body.isEmpty || activePost.status == PostStatus.published.rawValue)
                }
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

    private func createPostUrl() -> [Any] {
        guard let postId = activePost.postId else { return [] }
        guard let urlString = activePost.slug != nil ?
                "\(model.account.server)/\((activePost.collectionAlias)!)/\((activePost.slug)!)" :
                "\(model.account.server)/\((postId))" else { return [] }
        guard let data = URL(string: urlString) else { return [] }
        return [data as NSURL]
    }

    private func publishPost(_ post: WFAPost) {
        DispatchQueue.main.async {
            LocalStorageManager().saveContext()
            model.publish(post: post)
        }
    }

    private func openSettingsWindow() {
        guard let menuItem = NSApplication.shared.mainMenu?.item(at: 0)?.submenu?.item(at: 2) else { return }
        NSApplication.shared.sendAction(menuItem.action!, to: menuItem.target, from: nil)
    }
}
