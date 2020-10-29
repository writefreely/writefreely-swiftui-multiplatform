import SwiftUI
import Combine

struct PostListView: View {
    @EnvironmentObject var model: WriteFreelyModel
    @Environment(\.managedObjectContext) var managedObjectContext

    @State var selectedCollection: WFACollection?
    @State var showAllPosts: Bool = false
    @State private var postCount: Int = 0

    var body: some View {
        #if os(iOS)
        GeometryReader { geometry in
            PostListFilteredView(filter: selectedCollection?.alias, showAllPosts: showAllPosts, postCount: $postCount)
            .navigationTitle(
                showAllPosts ? "All Posts" : selectedCollection?.title ?? (
                    model.account.server == "https://write.as" ? "Anonymous" : "Drafts"
                )
            )
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        createNewLocalDraft()
                    }, label: {
                        Image(systemName: "square.and.pencil")
                    })
                }
                ToolbarItem(placement: .bottomBar) {
                    HStack {
                        Button(action: {
                            model.isPresentingSettingsView = true
                        }, label: {
                            Image(systemName: "gear")
                        })
                        Spacer()
                        Text(postCount == 1 ? "\(postCount) post" : "\(postCount) posts")
                            .foregroundColor(.secondary)
                        Spacer()
                        if model.isProcessingRequest {
                            ProgressView()
                        } else {
                            Button(action: {
                                reloadFromServer()
                            }, label: {
                                Image(systemName: "arrow.clockwise")
                            })
                            .disabled(!model.account.isLoggedIn)
                        }
                    }
                    .padding()
                    .frame(width: geometry.size.width)
                }
            }
        }
        #else //if os(macOS)
        PostListFilteredView(filter: selectedCollection?.alias, showAllPosts: showAllPosts, postCount: $postCount)
            .navigationTitle(
                showAllPosts ? "All Posts" : selectedCollection?.title ?? (
                    model.account.server == "https://write.as" ? "Anonymous" : "Drafts"
                )
            )
            .navigationSubtitle(postCount == 1 ? "\(postCount) post" : "\(postCount) posts")
            .toolbar {
                Button(action: {
                    createNewLocalDraft()
                }, label: {
                    Image(systemName: "square.and.pencil")
                })
                Button(action: {
                    reloadFromServer()
                }, label: {
                    Image(systemName: "arrow.clockwise")
                })
                .disabled(!model.account.isLoggedIn)
            }
        #endif
    }

    private func reloadFromServer() {
        DispatchQueue.main.async {
            model.fetchUserCollections()
            model.fetchUserPosts()
        }
    }

    private func createNewLocalDraft() {
        let managedPost = WFAPost(context: self.managedObjectContext)
        managedPost.createdDate = Date()
        managedPost.title = ""
        managedPost.body = ""
        managedPost.status = PostStatus.local.rawValue
        managedPost.collectionAlias = nil
        switch model.preferences.font {
        case 1:
            managedPost.appearance = "sans"
        case 2:
            managedPost.appearance = "wrap"
        default:
            managedPost.appearance = "serif"
        }
        if let languageCode = Locale.current.languageCode {
            managedPost.language = languageCode
            managedPost.rtl = Locale.characterDirection(forLanguage: languageCode) == .rightToLeft
        }
        DispatchQueue.main.async {
            self.selectedCollection = nil
            self.showAllPosts = false
            withAnimation {
                self.model.selectedPost = managedPost
            }
        }
    }
}

struct PostListView_Previews: PreviewProvider {
    static var previews: some View {
        let context = LocalStorageManager.persistentContainer.viewContext
        let model = WriteFreelyModel()

        return PostListView()
            .environment(\.managedObjectContext, context)
            .environmentObject(model)
    }
}
