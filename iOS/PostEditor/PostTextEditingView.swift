import SwiftUI

enum PostAppearance: String {
    case sans = "OpenSans-Regular"
    case mono = "Hack"
    case serif = "Lora"
}

struct PostTextEditingView: View {
    @ObservedObject var post: WFAPost
    @Binding var updatingTitleFromServer: Bool
    @Binding var updatingBodyFromServer: Bool
    @State private var appearance: PostAppearance = .serif
    private let bodyLineSpacingMultiplier: CGFloat = 0.5

    init(
        post: ObservedObject<WFAPost>,
        updatingTitleFromServer: Binding<Bool>,
        updatingBodyFromServer: Binding<Bool>
    ) {
        self._post = post
        self._updatingTitleFromServer = updatingTitleFromServer
        self._updatingBodyFromServer = updatingBodyFromServer
        UITextView.appearance().backgroundColor = .clear
    }

    var body: some View {
        VStack {
            TextField("Title (optional)", text: $post.title)
                .font(.custom(appearance.rawValue, size: 26, relativeTo: .largeTitle))
                .padding(.horizontal, 4)
                .onChange(of: post.title) { _ in
                    if post.status == PostStatus.published.rawValue && !updatingTitleFromServer {
                        post.status = PostStatus.edited.rawValue
                    }
                }
            ZStack(alignment: .topLeading) {
                if post.body.count == 0 {
                    Text("Write…")
                        .font(.custom(appearance.rawValue, size: 17, relativeTo: .body))
                        .foregroundColor(Color(UIColor.placeholderText))
                        .padding(.horizontal, 4)
                        .padding(.vertical, 8)
                }
                TextEditor(text: $post.body)
                    .font(.custom(appearance.rawValue, size: 17, relativeTo: .body))
                    .lineSpacing(17 * bodyLineSpacingMultiplier)
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
        .onAppear(perform: {
            switch post.appearance {
            case "sans":
                self.appearance = .sans
            case "wrap", "mono", "code":
                self.appearance = .mono
            default:
                self.appearance = .serif
            }
        })
    }
}
