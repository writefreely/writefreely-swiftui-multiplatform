import SwiftUI

struct PostEditorView: View {
    @EnvironmentObject var model: WriteFreelyModel
    @Environment(\.managedObjectContext) var moc
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.presentationMode) var presentationMode

    @ObservedObject var post: WFAPost
    @State private var updatingTitleFromServer: Bool = false
    @State private var updatingBodyFromServer: Bool = false

    @State private var selectedCollection: WFACollection?

    @FetchRequest(
        entity: WFACollection.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \WFACollection.title, ascending: true)]
    ) var collections: FetchedResults<WFACollection>

    var body: some View {
        VStack {
            if post.hasNewerRemoteCopy {
                HStack {
                    Text("⚠️ Newer copy on server. Replace local copy?")
                        .font(horizontalSizeClass == .compact ? .caption : .body)
                        .foregroundColor(.secondary)
                    Button(action: {
                        model.updateFromServer(post: post)
                    }, label: {
                        Image(systemName: "square.and.arrow.down")
                    })
                }
                .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
                .background(Color(UIColor.secondarySystemBackground))
                .clipShape(Capsule())
                .padding(.bottom)
            } else if post.wasDeletedFromServer {
                HStack {
                    Text("⚠️ Post deleted from server. Delete local copy?")
                        .font(horizontalSizeClass == .compact ? .caption : .body)
                        .foregroundColor(.secondary)
                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                        DispatchQueue.main.async {
                            model.posts.remove(post)
                        }
                    }, label: {
                        Image(systemName: "trash")
                    })
                }
                .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
                .background(Color(UIColor.secondarySystemBackground))
                .clipShape(Capsule())
                .padding(.bottom)
            }
            switch post.appearance {
            case "sans":
                TextField("Title (optional)", text: $post.title)
                    .font(.custom("OpenSans-Regular", size: 26, relativeTo: Font.TextStyle.largeTitle))
                    .onChange(of: post.title) { _ in
                        if post.status == PostStatus.published.rawValue && !updatingTitleFromServer {
                            post.status = PostStatus.edited.rawValue
                        }
                        if updatingTitleFromServer {
                            updatingTitleFromServer = false
                        }
                    }
                ZStack(alignment: .topLeading) {
                    if post.body.count == 0 {
                        Text("Write...")
                            .foregroundColor(Color(UIColor.placeholderText))
                            .padding(.horizontal, 4)
                            .padding(.vertical, 8)
                            .font(.custom("OpenSans-Regular", size: 17, relativeTo: Font.TextStyle.body))
                    }
                    TextEditor(text: $post.body)
                        .font(.custom("OpenSans-Regular", size: 17, relativeTo: Font.TextStyle.body))
                        .onChange(of: post.body) { _ in
                            if post.status == PostStatus.published.rawValue && !updatingBodyFromServer {
                                post.status = PostStatus.edited.rawValue
                            }
                            if updatingBodyFromServer {
                                updatingBodyFromServer = false
                            }
                    }
                }
            case "wrap", "mono", "code":
                TextField("Title (optional)", text: $post.title)
                    .font(.custom("Hack", size: 26, relativeTo: Font.TextStyle.largeTitle))
                    .onChange(of: post.title) { _ in
                        if post.status == PostStatus.published.rawValue && !updatingTitleFromServer {
                            post.status = PostStatus.edited.rawValue
                        }
                        if updatingTitleFromServer {
                            updatingTitleFromServer = false
                        }
                    }
                ZStack(alignment: .topLeading) {
                    if post.body.count == 0 {
                        Text("Write...")
                            .foregroundColor(Color(UIColor.placeholderText))
                            .padding(.horizontal, 4)
                            .padding(.vertical, 8)
                            .font(.custom("Hack", size: 17, relativeTo: Font.TextStyle.body))
                    }
                    TextEditor(text: $post.body)
                        .font(.custom("Hack", size: 17, relativeTo: Font.TextStyle.body))
                        .onChange(of: post.body) { _ in
                            if post.status == PostStatus.published.rawValue && !updatingBodyFromServer {
                                post.status = PostStatus.edited.rawValue
                            }
                            if updatingBodyFromServer {
                                updatingBodyFromServer = false
                            }
                    }
                }
            default:
                TextField("Title (optional)", text: $post.title)
                    .font(.custom("Lora", size: 26, relativeTo: Font.TextStyle.largeTitle))
                    .onChange(of: post.title) { _ in
                        if post.status == PostStatus.published.rawValue && !updatingTitleFromServer {
                            post.status = PostStatus.edited.rawValue
                        }
                        if updatingTitleFromServer {
                            updatingTitleFromServer = false
                        }
                    }
                ZStack(alignment: .topLeading) {
                    if post.body.count == 0 {
                        Text("Write...")
                            .foregroundColor(Color(UIColor.placeholderText))
                            .padding(.horizontal, 4)
                            .padding(.vertical, 8)
                            .font(.custom("Lora", size: 17, relativeTo: Font.TextStyle.body))
                    }
                    TextEditor(text: $post.body)
                        .font(.custom("Lora", size: 17, relativeTo: Font.TextStyle.body))
                        .onChange(of: post.body) { _ in
                            if post.status == PostStatus.published.rawValue && !updatingBodyFromServer {
                                post.status = PostStatus.edited.rawValue
                            }
                            if updatingBodyFromServer {
                                updatingBodyFromServer = false
                            }
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .padding()
        .toolbar {
            ToolbarItem(placement: .principal) {
                PostEditorStatusToolbarView(post: post)
            }
            ToolbarItem(placement: .primaryAction) {
                Menu(content: {
                    if post.status == PostStatus.local.rawValue {
                        Menu(content: {
                            Label("Publish to…", systemImage: "paperplane")
                            Button(action: {
                                if model.account.isLoggedIn {
                                    post.collectionAlias = nil
                                    publishPost()
                                } else {
                                    self.model.isPresentingSettingsView = true
                                }
                            }, label: {
                                Text("  \(model.account.server == "https://write.as" ? "Anonymous" : "Drafts")")
                            })
                            ForEach(collections) { collection in
                                Button(action: {
                                    if model.account.isLoggedIn {
                                        post.collectionAlias = collection.alias
                                        publishPost()
                                    } else {
                                        self.model.isPresentingSettingsView = true
                                    }
                                }, label: {
                                    Text("  \(collection.title)")
                                })
                            }
                        }, label: {
                            Label("Publish…", systemImage: "paperplane")
                        })
                    } else {
                        Button(action: {
                            if model.account.isLoggedIn {
                                publishPost()
                            } else {
                                self.model.isPresentingSettingsView = true
                            }
                        }, label: {
                            Label("Publish", systemImage: "paperplane")
                        })
                        .disabled(
                            post.status ==
                                PostStatus.published.rawValue ||
                                !model.hasNetworkConnection ||
                                post.body.count == 0
                        )
                    }
                    Button(action: {
                        sharePost()
                    }, label: {
                        Label("Share", systemImage: "square.and.arrow.up")
                    })
                    .disabled(post.postId == nil)
//                    Button(action: {
//                        print("Tapped 'Delete...' button")
//                    }, label: {
//                        Label("Delete…", systemImage: "trash")
//                    })
                    if model.account.isLoggedIn && post.status != PostStatus.local.rawValue {
                        Section(header: Text("Move To Collection")) {
                            Label("Move to:", systemImage: "arrowshape.zigzag.right")
                            Picker(selection: $selectedCollection, label: Text("Move to…")) {
                                Text(
                                    "  \(model.account.server == "https://write.as" ? "Anonymous" : "Drafts")"
                                ).tag(nil as WFACollection?)
                                ForEach(collections) { collection in
                                    Text("  \(collection.title)").tag(collection as WFACollection?)
                                }
                            }
                        }
                    }
                }, label: {
                    Image(systemName: "ellipsis.circle")
                })
            }
        }
        .onChange(of: post.hasNewerRemoteCopy, perform: { _ in
            if !post.hasNewerRemoteCopy {
                updatingTitleFromServer = true
                updatingBodyFromServer = true
            }
        })
        .onChange(of: post.status, perform: { _ in
            if post.status != PostStatus.published.rawValue {
                DispatchQueue.main.async {
                    model.editor.setLastDraft(post)
                }
            } else {
                DispatchQueue.main.async {
                    model.editor.clearLastDraft()
                }
            }
        })
        .onChange(of: selectedCollection, perform: { [selectedCollection] newCollection in
            if post.collectionAlias == newCollection?.alias {
                return
            } else {
                post.collectionAlias = newCollection?.alias
                model.move(post: post, from: selectedCollection, to: newCollection)
            }
        })
        .onAppear(perform: {
            self.selectedCollection = collections.first { $0.alias == post.collectionAlias }
        })
        .onDisappear(perform: {
            if post.title.count == 0
                && post.body.count == 0
                && post.status == PostStatus.local.rawValue
                && post.updatedDate == nil
                && post.postId == nil {
                DispatchQueue.main.async {
                    model.posts.remove(post)
                    model.posts.loadCachedPosts()
                }
            } else if post.status != PostStatus.published.rawValue {
                DispatchQueue.main.async {
                    LocalStorageManager().saveContext()
                }
            }
        })
    }

    private func publishPost() {
        DispatchQueue.main.async {
            LocalStorageManager().saveContext()
            model.posts.loadCachedPosts()
            model.publish(post: post)
        }
        #if os(iOS)
        self.hideKeyboard()
        #endif
    }

    private func sharePost() {
        // If the post doesn't have a post ID, it isn't published, and therefore can't be shared, so return early.
        guard let postId = post.postId else { return }

        var urlString: String

        if let postSlug = post.slug,
           let postCollectionAlias = post.collectionAlias {
            // This post is in a collection, so share the URL as server/collectionAlias/postSlug.
            urlString = "\(model.account.server)/\((postCollectionAlias))/\((postSlug))"
        } else {
            // This is a draft post, so share the URL as server/postID
            urlString = "\(model.account.server)/\((postId))"
        }

        guard let data = URL(string: urlString) else { return }

        let activityView = UIActivityViewController(activityItems: [data], applicationActivities: nil)

        UIApplication.shared.windows.first?.rootViewController?.present(activityView, animated: true, completion: nil)
        if UIDevice.current.userInterfaceIdiom == .pad {
            activityView.popoverPresentationController?.permittedArrowDirections = .up
            activityView.popoverPresentationController?.sourceView = UIApplication.shared.windows.first
            activityView.popoverPresentationController?.sourceRect = CGRect(
                x: UIScreen.main.bounds.width,
                y: -125,
                width: 200,
                height: 200
            )
        }
    }
}

struct PostEditorView_EmptyPostPreviews: PreviewProvider {
    static var previews: some View {
        let context = LocalStorageManager.persistentContainer.viewContext
        let testPost = WFAPost(context: context)
        testPost.createdDate = Date()
        testPost.appearance = "norm"

        let model = WriteFreelyModel()

        return PostEditorView(post: testPost)
            .environment(\.managedObjectContext, context)
            .environmentObject(model)
    }
}

struct PostEditorView_ExistingPostPreviews: PreviewProvider {
    static var previews: some View {
        let context = LocalStorageManager.persistentContainer.viewContext
        let testPost = WFAPost(context: context)
        testPost.title = "Test Post Title"
        testPost.body = "Here's some cool sample body text."
        testPost.createdDate = Date()
        testPost.appearance = "code"
        testPost.hasNewerRemoteCopy = true

        let model = WriteFreelyModel()

        return PostEditorView(post: testPost)
            .environment(\.managedObjectContext, context)
            .environmentObject(model)
    }
}
