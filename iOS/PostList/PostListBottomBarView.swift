import SwiftUI

struct PostListBottomBarView: View {
    @EnvironmentObject var model: WriteFreelyModel
    @Binding var postCount: Int

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
        .frame(height: 100)
        .background(Color(UIColor.systemGray5))
        .overlay(Divider(), alignment: .top)
    }
}

struct PostListBottomBarView_Previews: PreviewProvider {
    static var previews: some View {
        PostListBottomBarView(postCount: .constant(0)).environmentObject(WriteFreelyModel())
    }
}
