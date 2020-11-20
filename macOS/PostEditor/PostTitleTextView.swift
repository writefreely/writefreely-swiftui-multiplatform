import SwiftUI

class PostTitleCoordinator: NSObject, NSTextViewDelegate {
    @Binding var text: String
    @Binding var isFirstResponder: Bool
    var didBecomeFirstResponder: Bool = false
    var postTitleTextView: PostTitleTextView

    init(
        _ textView: PostTitleTextView,
        text: Binding<String>,
        isFirstResponder: Binding<Bool>
    ) {
        self.postTitleTextView = textView
        _text = text
        _isFirstResponder = isFirstResponder
    }

    func textDidChange(_ notification: Notification) {
        guard let textView = notification.object as? NSTextView else { return }
        DispatchQueue.main.async {
            self.postTitleTextView.text = textView.string
        }
    }

    func textDidEndEditing(_ notification: Notification) {
        DispatchQueue.main.async {
            self.isFirstResponder = false
            self.didBecomeFirstResponder = false
        }
    }

    func textView(
        _ textView: NSTextView,
        shouldChangeTextIn affectedCharRange: NSRange,
        replacementString: String?
    ) -> Bool {
        if replacementString == "\n" {
            self.isFirstResponder.toggle()
            self.didBecomeFirstResponder = false
            return false
        }
        return true
    }
}

struct PostTitleTextView: NSViewRepresentable {
    @Binding var text: String
    @Binding var textStyle: NSFont
    @Binding var isFirstResponder: Bool

    func makeNSView(context: Context) -> NSTextView {
        let textView = NSTextView()

        textView.isEditable = true
        textView.isSelectable = true
        textView.font = textStyle
        textView.delegate = context.coordinator
        textView.backgroundColor = NSColor.clear

        return textView
    }

    func makeCoordinator() -> PostTitleCoordinator {
        return Coordinator(self, text: $text, isFirstResponder: $isFirstResponder)
    }

    func updateNSView(_ nsView: NSTextView, context: Context) {
        if nsView.string != text {
            nsView.string = text
        }

        nsView.font = textStyle

        if isFirstResponder && !context.coordinator.didBecomeFirstResponder {
            DispatchQueue.main.async {
                NSApplication.shared.keyWindow?.makeFirstResponder(nsView)
                context.coordinator.didBecomeFirstResponder = true
            }
        }
    }
}
