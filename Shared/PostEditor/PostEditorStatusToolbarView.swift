import SwiftUI

struct PostEditorStatusToolbarView: View {
    #if os(iOS)
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.presentationMode) var presentationMode
    #endif
    @EnvironmentObject var model: WriteFreelyModel

    @ObservedObject var post: WFAPost

    var body: some View {
        if post.hasNewerRemoteCopy {
            #if os(iOS)
            if horizontalSizeClass == .compact {
                VStack {
                    PostStatusBadgeView(post: post)
                    HStack {
                        Text("⚠️ Newer copy on server. Replace local copy?")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Button(action: {
                            model.updateFromServer(post: post)
                        }, label: {
                            Image(systemName: "square.and.arrow.down")
                        })
                    }
                    .padding(.bottom)
                }
                .padding(.top)
            } else {
                HStack {
                    PostStatusBadgeView(post: post)
                        .padding(.trailing)
                    Text("⚠️ Newer copy on server. Replace local copy?")
                        .font(.callout)
                        .foregroundColor(.secondary)
                    Button(action: {
                        model.updateFromServer(post: post)
                    }, label: {
                        Image(systemName: "square.and.arrow.down")
                    })
                }
            }
            #else
            HStack {
                PostStatusBadgeView(post: post)
                    .padding(.trailing)
                Text("⚠️ Newer copy on server. Replace local copy?")
                    .font(.callout)
                    .foregroundColor(.secondary)
                Button(action: {
                    model.updateFromServer(post: post)
                }, label: {
                    Image(systemName: "square.and.arrow.down")
                })
            }
            #endif
        } else if post.wasDeletedFromServer {
            #if os(iOS)
            if horizontalSizeClass == .compact {
                VStack {
                    PostStatusBadgeView(post: post)
                    HStack {
                        Text("‼️ Post deleted from server. Delete local copy?")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Button(action: {
                            self.presentationMode.wrappedValue.dismiss()
                            model.selectedPost = nil
                            model.posts.remove(post)
                        }, label: {
                            Image(systemName: "trash")
                        })
                    }
                    .padding(.bottom)
                }
                .padding(.top)
            } else {
                HStack {
                    PostStatusBadgeView(post: post)
                        .padding(.trailing)
                    Text("‼️ Post deleted from server. Delete local copy?")
                        .font(.callout)
                        .foregroundColor(.secondary)
                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                        model.selectedPost = nil
                        model.posts.remove(post)
                    }, label: {
                        Image(systemName: "trash")
                    })
                }
            }
            #else
            HStack {
                PostStatusBadgeView(post: post)
                    .padding(.trailing)
                Text("‼️ Post deleted from server. Delete local copy?")
                    .font(.callout)
                    .foregroundColor(.secondary)
                Button(action: {
                    model.selectedPost = nil
                    model.posts.remove(post)
                }, label: {
                    Image(systemName: "trash")
                })
            }
            #endif
        } else {
            PostStatusBadgeView(post: post)
        }
    }
}

struct PESTView_StandardPreviews: PreviewProvider {
    static var previews: some View {
        let context = LocalStorageManager.persistentContainer.viewContext
        let model = WriteFreelyModel()
        let testPost = WFAPost(context: context)
        testPost.status = PostStatus.published.rawValue

        return PostEditorStatusToolbarView(post: testPost)
            .environmentObject(model)
    }
}

struct PESTView_OutdatedLocalCopyPreviews: PreviewProvider {
    static var previews: some View {
        let context = LocalStorageManager.persistentContainer.viewContext
        let model = WriteFreelyModel()
        let testPost = WFAPost(context: context)
        testPost.status = PostStatus.published.rawValue
        testPost.hasNewerRemoteCopy = true

        return PostEditorStatusToolbarView(post: testPost)
            .environmentObject(model)
    }
}
