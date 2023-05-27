import SwiftUI

struct PostEditorView: View {
    @EnvironmentObject var model: WriteFreelyModel
    @EnvironmentObject var errorHandling: ErrorHandling
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.managedObjectContext) var moc
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
                RemoteChangePromptView(
                    remoteChangeType: .remoteCopyUpdated,
                    buttonHandler: { model.updateFromServer(post: post) }
                )
            } else if post.wasDeletedFromServer {
                RemoteChangePromptView(
                    remoteChangeType: .remoteCopyDeleted,
                    buttonHandler: {
                        self.presentationMode.wrappedValue.dismiss()
                        DispatchQueue.main.async {
                            model.posts.remove(post)
                        }
                    }
                )
            }
            PostTextEditingView(
                post: _post,
                updatingTitleFromServer: $updatingTitleFromServer,
                updatingBodyFromServer: $updatingBodyFromServer
            )
            .withErrorHandling()
        }
        .navigationBarTitleDisplayMode(.inline)
        .padding()
        .toolbar {
            ToolbarItem(placement: .principal) {
                PostEditorStatusToolbarView(post: post)
            }
            ToolbarItem(placement: .primaryAction) {
                if model.isProcessingRequest {
                    ProgressView()
                } else {
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
                        .accessibilityHint(Text("Choose the blog you want to publish this post to"))
                        .disabled(post.body.count == 0)
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
                        .disabled(post.status == PostStatus.published.rawValue || post.body.count == 0)
                    }
                    Button(action: {
                        sharePost()
                    }, label: {
                        Label("Share", systemImage: "square.and.arrow.up")
                    })
                    .accessibilityHint(Text("Open the system share sheet to share a link to this post"))
                    .disabled(post.postId == nil)
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
                    ZStack {
                        Image("does.not.exist")
                            .accessibilityHidden(true)
                        Image(systemName: "ellipsis.circle")
                            .imageScale(.large)
                            .accessibilityHidden(true)
                    }
                })
                    .accessibilityLabel(Text("Menu"))
                    .accessibilityHint(Text("Opens a context menu to publish, share, or move the post"))
                    .onTapGesture {
                        hideKeyboard()
                    }
                    .disabled(post.body.count == 0)
                }
            }
        }
        .onChange(of: post.hasNewerRemoteCopy, perform: { _ in
            if !post.hasNewerRemoteCopy {
                updatingTitleFromServer = true
                updatingBodyFromServer = true
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
        .onChange(of: post.status, perform: { value in
            if value != PostStatus.published.rawValue {
                self.model.editor.saveLastDraft(post)
            } else {
                self.model.editor.clearLastDraft()
            }
            DispatchQueue.main.async {
                LocalStorageManager.standard.saveContext()
            }
        })
        .onAppear(perform: {
            self.selectedCollection = collections.first { $0.alias == post.collectionAlias }
            model.editor.setInitialValues(for: post)
            if post.status != PostStatus.published.rawValue {
                DispatchQueue.main.async {
                    self.model.editor.saveLastDraft(post)
                }
            } else {
                self.model.editor.clearLastDraft()
            }
        })
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
        .onDisappear(perform: {
            self.model.editor.clearLastDraft()
            if post.title.count == 0
                && post.body.count == 0
                && post.status == PostStatus.local.rawValue
                && post.updatedDate == nil
                && post.postId == nil {
                DispatchQueue.main.async {
                    model.posts.remove(post)
                }
            } else if post.status != PostStatus.published.rawValue {
                DispatchQueue.main.async {
                    LocalStorageManager.standard.saveContext()
                }
            }
        })
    }

    private func publishPost() {
        DispatchQueue.main.async {
            LocalStorageManager.standard.saveContext()
            model.publish(post: post)
        }
        model.editor.setInitialValues(for: post)
        self.hideKeyboard()
    }

    private func sharePost() {
        // If the post doesn't have a post ID, it isn't published, and therefore can't be shared, so return early.
        guard let postId = post.postId else { return }

        var urlString: String

        if let postSlug = post.slug,
           let postCollectionAlias = post.collectionAlias {
            // This post is in a collection, so share the URL as baseURL/postSlug.
            let urls = collections.filter { $0.alias == postCollectionAlias }
            let baseURL = urls.first?.url ?? "\(model.account.server)/\(postCollectionAlias)/"
            urlString = "\(baseURL)\(postSlug)"
        } else {
            // This is a draft post, so share the URL as server/postID
            urlString = "\(model.account.server)/\(postId)"
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
        let context = LocalStorageManager.standard.container.viewContext
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
        let context = LocalStorageManager.standard.container.viewContext
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
