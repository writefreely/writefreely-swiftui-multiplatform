import SwiftUI

struct PostEditorStatusToolbarView: View {
    #if os(iOS)
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    #endif
    @EnvironmentObject var model: WriteFreelyModel

    @ObservedObject var post: Post

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
        } else {
            PostStatusBadgeView(post: post)
        }
    }
}

struct ToolbarView_LocalPreviews: PreviewProvider {
    static var previews: some View {
        let model = WriteFreelyModel()
        let post = testPost
        return PostEditorStatusToolbarView(post: post)
            .environmentObject(model)
    }
}

struct ToolbarView_RemotePreviews: PreviewProvider {
    static var previews: some View {
        let model = WriteFreelyModel()
        let newerRemotePost = Post(
            title: testPost.wfPost.title ?? "",
            body: testPost.wfPost.body,
            createdDate: testPost.wfPost.createdDate ?? Date(),
            status: testPost.status,
            collection: testPost.collection
        )
        newerRemotePost.hasNewerRemoteCopy = true
        return PostEditorStatusToolbarView(post: newerRemotePost)
            .environmentObject(model)
    }
}

#if os(iOS)
struct ToolbarView_CompactLocalPreviews: PreviewProvider {
    static var previews: some View {
        let model = WriteFreelyModel()
        let post = testPost
        return PostEditorStatusToolbarView(post: post)
            .environmentObject(model)
            .environment(\.horizontalSizeClass, .compact)
    }
}
#endif

#if os(iOS)
struct ToolbarView_CompactRemotePreviews: PreviewProvider {
    static var previews: some View {
        let model = WriteFreelyModel()
        let newerRemotePost = Post(
            title: testPost.wfPost.title ?? "",
            body: testPost.wfPost.body,
            createdDate: testPost.wfPost.createdDate ?? Date(),
            status: testPost.status,
            collection: testPost.collection
        )
        newerRemotePost.hasNewerRemoteCopy = true
        return PostEditorStatusToolbarView(post: newerRemotePost)
            .environmentObject(model)
            .environment(\.horizontalSizeClass, .compact)
    }
}
#endif
