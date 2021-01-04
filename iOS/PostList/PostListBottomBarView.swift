import SwiftUI

struct PostListBottomBarView: View {
    @EnvironmentObject var model: WriteFreelyModel
    @Binding var postCount: Int

    private var frameHeight: CGFloat {
        var height: CGFloat = 50
        let bottom = UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0
        height += bottom
        return height
    }

    var body: some View {
        VStack {
            HStack(spacing: 0) {
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
                        DispatchQueue.main.async {
                            model.fetchUserCollections()
                            model.fetchUserPosts()
                        }
                    }, label: {
                        Image(systemName: "arrow.clockwise")
                    })
                    .disabled(!model.account.isLoggedIn)
                }
            }
            .padding()
            Spacer()
        }
        .frame(height: frameHeight)
        .background(Color(UIColor.systemGray5))
        .overlay(Divider(), alignment: .top)
    }
}

struct PostListBottomBarView_Previews: PreviewProvider {
    static var previews: some View {
        PostListBottomBarView(postCount: .constant(0)).environmentObject(WriteFreelyModel())
    }
}
