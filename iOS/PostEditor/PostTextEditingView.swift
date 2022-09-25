import SwiftUI

struct PostTextEditingView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @ObservedObject var post: WFAPost
    @Binding var updatingTitleFromServer: Bool
    @Binding var updatingBodyFromServer: Bool
    @State private var appearance: PostAppearance = .serif
    @State private var titleTextStyle: UIFont = UIFont(name: "Lora-Regular", size: 26)!
    @State private var titleTextHeight: CGFloat = 50
    @State private var bodyTextHeight: CGFloat = 50
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

    var titleFieldHeight: CGFloat {
        let minHeight: CGFloat = textEditorHeight
        if titleTextHeight < minHeight {
            return minHeight
        }
        return titleTextHeight
    }
    var bodyFieldHeight: CGFloat {
        let minHeight: CGFloat = textEditorHeight
        if bodyTextHeight < minHeight {
            return minHeight
        }
        return bodyTextHeight
    }

    var body: some View {
        ScrollView(.vertical) {
            ZStack(alignment: .topLeading) {
                if post.title.count == 0 {
                    Text("Title (optional)")
                        .font(Font(titleTextStyle))
                        .foregroundColor(Color(UIColor.placeholderText))
                        .padding(.horizontal, 4)
                        .padding(.vertical, 8)
                        .accessibilityHidden(true)
                }
                PostTitleTextView(
                    text: $post.title,
                    textStyle: $titleTextStyle,
                    height: $titleTextHeight,
                    isFirstResponder: $titleIsFirstResponder,
                    lineSpacing: horizontalSizeClass == .compact ? lineSpacingMultiplier / 2 : lineSpacingMultiplier
                )
                .accessibilityLabel(Text("Title (optional)"))
                .accessibilityHint(Text("Add or edit the title for your post; use the Return key to skip to the body"))
                .frame(height: titleFieldHeight)
                .onChange(of: post.title) { _ in
                    if post.status == PostStatus.published.rawValue && !updatingTitleFromServer {
                        post.status = PostStatus.edited.rawValue
                    }
                    if updatingTitleFromServer {
                        updatingTitleFromServer = false
                    }
                }
            }
            ZStack(alignment: .topLeading) {
                if post.body.count == 0 {
                    Text("Write…")
                        .font(Font(bodyTextStyle))
                        .foregroundColor(Color(UIColor.placeholderText))
                        .padding(.horizontal, 4)
                        .padding(.vertical, 8)
                        .accessibilityHidden(true)
                }
                PostBodyTextView(
                    text: $post.body,
                    textStyle: $bodyTextStyle,
                    height: $bodyTextHeight,
                    isFirstResponder: $bodyIsFirstResponder,
                    lineSpacing: horizontalSizeClass == .compact ? lineSpacingMultiplier / 2 : lineSpacingMultiplier
                )
                .frame(height: bodyFieldHeight)
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
}
