import SwiftUI

struct PostTextEditingView: View {
    @ObservedObject var post: WFAPost
    @Binding var updatingTitleFromServer: Bool
    @Binding var updatingBodyFromServer: Bool
    @State private var appearance: PostAppearance = .serif
    @State private var titleTextStyle: NSFont = NSFont(name: "Lora-Regular", size: 26)!
    @State private var titleTextHeight: CGFloat = 33
    @State private var titleIsFirstResponder: Bool = true
    @State private var bodyTextStyle: NSFont = NSFont(name: "Lora-Regular", size: 17)!
    @State private var bodyIsFirstResponder: Bool = false
    private let bodyLineSpacingMultiplier: CGFloat = 0.5

    init(
        post: ObservedObject<WFAPost>,
        updatingTitleFromServer: Binding<Bool>,
        updatingBodyFromServer: Binding<Bool>
    ) {
        self._post = post
        self._updatingTitleFromServer = updatingTitleFromServer
        self._updatingBodyFromServer = updatingBodyFromServer
    }

    var body: some View {
        VStack {
            ZStack(alignment: .topLeading) {
                if post.title.count == 0 {
                    Text("Title (optional)")
                        .font(Font(titleTextStyle))
                        .foregroundColor(Color(NSColor.placeholderTextColor))
                        .padding(.horizontal, 4)
                }
                PostTitleTextView(
                    text: $post.title,
                    textStyle: $titleTextStyle,
                    isFirstResponder: $titleIsFirstResponder
                )
                .frame(height: titleTextHeight)
                .onChange(of: post.title) { _ in
                    if post.status == PostStatus.published.rawValue && !updatingTitleFromServer {
                        post.status = PostStatus.edited.rawValue
                    }
                    if updatingTitleFromServer {
                        updatingTitleFromServer = false
                    }
                }
            }
            .padding(4)
            ZStack(alignment: .topLeading) {
                if post.body.count == 0 {
                    Text("Write…")
                        .font(Font(bodyTextStyle))
                        .foregroundColor(Color(NSColor.placeholderTextColor))
                        .padding(.horizontal, 4)
                }
                PostBodyTextView(text: $post.body, textStyle: $bodyTextStyle, isFirstResponder: $bodyIsFirstResponder)
                    .onChange(of: post.body) { _ in
                        if post.status == PostStatus.published.rawValue && !updatingBodyFromServer {
                            post.status = PostStatus.edited.rawValue
                        }
                        if updatingBodyFromServer {
                            updatingBodyFromServer = false
                        }
                    }
            }
            .padding(4)
        }
        .onChange(of: titleIsFirstResponder, perform: { value in
            if !value {
                self.bodyIsFirstResponder = true
            }
        })
        .onChange(of: bodyIsFirstResponder, perform: { value in
            if !value {
                self.titleIsFirstResponder = true
            }
        })
        .onAppear(perform: {
            let fontName = getFontNameFromPost(post)
            DispatchQueue.main.async {
                self.titleTextStyle = NSFont(name: fontName, size: 26)!
                self.bodyTextStyle = NSFont(name: fontName, size: 17)!
            }
        })
        .onDisappear(perform: {
            DispatchQueue.main.async {
                self.titleIsFirstResponder = true
            }
        })
    }

    private func getFontNameFromPost(_ post: WFAPost) -> String {
        switch post.appearance {
        case "sans":
            self.appearance = .sans
        case "wrap", "mono", "code":
            self.appearance = .mono
        default:
            self.appearance = .serif
        }
        return appearance.rawValue
    }
}
