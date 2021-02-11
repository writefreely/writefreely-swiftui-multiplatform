import SwiftUI

struct PostTextEditingView: View {
    @ObservedObject var post: WFAPost
    @Binding var updatingFromServer: Bool
    @State private var appearance: PostAppearance = .serif
    @State private var combinedText = ""
    @State private var hasBeenEdited: Bool = false

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
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
                    font: NSFont(name: PostAppearance.sans.rawValue, size: 17),
                    onEditingChanged: onEditingChanged,
                    onCommit: onCommit,
                    onTextChange: onTextChange
                )
            } else if post.appearance == "wrap" || post.appearance == "mono" || post.appearance == "code" {
                MacEditorTextView(
                    text: $combinedText,
                    isFirstResponder: combinedText.isEmpty,
                    isEditable: true,
                    font: NSFont(name: PostAppearance.mono.rawValue, size: 17),
                    onEditingChanged: onEditingChanged,
                    onCommit: onCommit,
                    onTextChange: onTextChange
                )
            } else {
                MacEditorTextView(
                    text: $combinedText,
                    isFirstResponder: combinedText.isEmpty,
                    isEditable: true,
                    font: NSFont(name: PostAppearance.serif.rawValue, size: 17),
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
        .onReceive(timer) { _ in
            if !post.body.isEmpty && hasBeenEdited {
                DispatchQueue.main.async {
                    LocalStorageManager().saveContext()
                    hasBeenEdited = false
                }
            }
        }
    }

    private func onEditingChanged() {
        hasBeenEdited = true
    }

    private func onTextChange(_ text: String) {
        extractTitle(text)

        if post.status == PostStatus.published.rawValue && !updatingFromServer {
            post.status = PostStatus.edited.rawValue
        }

        if updatingFromServer {
            self.updatingFromServer = false
        }
        hasBeenEdited = true
    }

    private func onCommit() {
        if !post.body.isEmpty && hasBeenEdited {
            DispatchQueue.main.async {
                LocalStorageManager().saveContext()
            }
        }
        hasBeenEdited = false
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
