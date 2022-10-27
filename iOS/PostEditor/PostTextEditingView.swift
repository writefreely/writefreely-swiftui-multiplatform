import SwiftUI

struct PostTextEditingView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @ObservedObject var post: WFAPost
    @Binding var updatingTitleFromServer: Bool
    @Binding var updatingBodyFromServer: Bool
    @State private var appearance: PostAppearance = .serif
    @State private var titleTextStyle: UIFont = UIFont(name: "Lora-Regular", size: 26)!
    @State private var titleIsFirstResponder: Bool = true
    @State private var bodyTextStyle: UIFont = UIFont(name: "Lora-Regular", size: 17)!
    @State private var bodyIsFirstResponder: Bool = false
    private let lineSpacingMultiplier: CGFloat = 0.5
    private let textEditorHeight: CGFloat = 50

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
        ScrollView(.vertical) {
            MultilineTextField(
                "Title (optional)",
                text: $post.title,
                font: titleTextStyle,
                isFirstResponder: $titleIsFirstResponder,
                onCommit: didFinishEditingTitle
            )
            .accessibilityLabel(Text("Title (optional)"))
            .accessibilityHint(Text("Add or edit the title for your post; use the Return key to skip to the body"))
            .onChange(of: post.title) { _ in
                if post.status == PostStatus.published.rawValue && !updatingTitleFromServer {
                    post.status = PostStatus.edited.rawValue
                }
                if updatingTitleFromServer {
                    updatingTitleFromServer = false
                }
            }
            MultilineTextField(
                "Write...",
                text: $post.body,
                font: bodyTextStyle,
                isFirstResponder: $bodyIsFirstResponder
            )
            .accessibilityLabel(Text("Body"))
            .accessibilityHint(Text("Add or edit the body of your post"))
            .onChange(of: post.body) { _ in
                if post.status == PostStatus.published.rawValue && !updatingBodyFromServer {
                    post.status = PostStatus.edited.rawValue
                }
                if updatingBodyFromServer {
                    updatingBodyFromServer = false
                }
            }
        }
        .onChange(of: titleIsFirstResponder, perform: { _ in
            self.bodyIsFirstResponder.toggle()
        })
        .onAppear(perform: {
            switch post.appearance {
            case "sans":
                self.appearance = .sans
            case "wrap", "mono", "code":
                self.appearance = .mono
            default:
                self.appearance = .serif
            }
            self.titleTextStyle = UIFont(name: appearance.rawValue, size: 26)!
            self.bodyTextStyle = UIFont(name: appearance.rawValue, size: 17)!
        })
    }

    private func didFinishEditingTitle() {
        self.titleIsFirstResponder = false
        self.bodyIsFirstResponder = true
    }
}
