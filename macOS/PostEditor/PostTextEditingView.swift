import SwiftUI

struct PostTextEditingView: View {
    @ObservedObject var post: WFAPost
    @Binding var updatingFromServer: Bool
    @State private var appearance: PostAppearance = .serif
    @State private var combinedText = ""

    var body: some View {
//        VStack {
//            TextField("Title (optional)", text: $post.title)
//                .textFieldStyle(PlainTextFieldStyle())
//                .padding(.horizontal, 4)
//                .font(.custom(appearance.rawValue, size: 26, relativeTo: .largeTitle))
//                .onChange(of: post.title) { _ in
//                    if post.status == PostStatus.published.rawValue && !updatingTitleFromServer {
//                        post.status = PostStatus.edited.rawValue
//                    }
//                    if updatingTitleFromServer {
//                        updatingTitleFromServer = false
//                    }
//                }
//                .padding(4)
//                .background(Color(NSColor.controlBackgroundColor))
//                .padding(.bottom)
//            ZStack(alignment: .topLeading) {
//                if post.body.count == 0 {
//                    Text("Write…")
//                        .foregroundColor(Color(NSColor.placeholderTextColor))
//                        .padding(.horizontal, 4)
//                        .padding(.vertical, 2)
//                        .font(.custom(appearance.rawValue, size: 17, relativeTo: .body))
//                }
//                TextEditor(text: $post.body)
//                    .font(.custom(appearance.rawValue, size: 17, relativeTo: .body))
//                    .opacity(post.body.count == 0 && !isHovering ? 0.0 : 1.0)
//                    .onChange(of: post.body) { _ in
//                        if post.status == PostStatus.published.rawValue && !updatingBodyFromServer {
//                            post.status = PostStatus.edited.rawValue
//                        }
//                        if updatingBodyFromServer {
//                            updatingBodyFromServer = false
//                        }
//                    }
//                    .onHover(perform: { hovering in
//                        self.isHovering = hovering
//                    })
//            }
//            .padding(4)
//            .background(Color(NSColor.controlBackgroundColor))
//        }
        ZStack(alignment: .topLeading) {
            if combinedText.count == 0 {
                Text("Write…")
                    .foregroundColor(Color(NSColor.placeholderTextColor))
                    .padding(.horizontal, 5)
                    .font(.custom(appearance.rawValue, size: 17, relativeTo: .body))
            }
            if post.appearance == "sans" {
                MacEditorTextView(
                    text: $combinedText,
                    isFirstResponder: combinedText.isEmpty,
                    isEditable: true,
                    font: NSFont(name: "OpenSans-Regular", size: 17),
                    onEditingChanged: onEditingChanged,
                    onCommit: onCommit,
                    onTextChange: onTextChange
                )
            } else if post.appearance == "wrap" || post.appearance == "mono" || post.appearance == "code" {
                MacEditorTextView(
                    text: $combinedText,
                    isFirstResponder: combinedText.isEmpty,
                    isEditable: true,
                    font: NSFont(name: "Hack-Regular", size: 17),
                    onEditingChanged: onEditingChanged,
                    onCommit: onCommit,
                    onTextChange: onTextChange
                )
            } else {
                MacEditorTextView(
                    text: $combinedText,
                    isFirstResponder: combinedText.isEmpty,
                    isEditable: true,
                    font: NSFont(name: "Lora-Regular", size: 17),
                    onEditingChanged: onEditingChanged,
                    onCommit: onCommit,
                    onTextChange: onTextChange
                )
            }
        }
        .background(Color(NSColor.controlBackgroundColor))
        .onAppear(perform: {
            if post.title.isEmpty {
                self.combinedText = post.body
            } else {
                self.combinedText = "# \(post.title)\n\n\(post.body)"
            }
        })
    }

    private func onEditingChanged() {
        print("onEditingChanged fired")
    }

    private func onTextChange(_ text: String) {
        extractTitle(text)
    }

    private func onCommit() {
        print("onCommit fired")
    }

    private func extractTitle(_ text: String) {
        var detectedTitle: String

        if text.hasPrefix("# ") {
            let endOfTitleIndex = text.firstIndex(of: "\n") ?? text.endIndex
            detectedTitle = String(text[..<endOfTitleIndex])

            self.post.title = String(detectedTitle.dropFirst("# ".count))
            let remainingText = String(text.dropFirst(detectedTitle.count).dropFirst(1))
            if remainingText.hasPrefix("\n") {
                self.post.body = String(remainingText.dropFirst(1))
            } else {
                self.post.body = remainingText
            }
        } else {
            self.post.title = ""
            self.post.body = text
        }
    }

}
