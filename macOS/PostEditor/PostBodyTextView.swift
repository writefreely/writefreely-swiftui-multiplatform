import SwiftUI

class PostBodyCoordinator: NSObject, NSTextViewDelegate, NSLayoutManagerDelegate {
    @Binding var text: String
    @Binding var isFirstResponder: Bool
    var didBecomeFirstResponder: Bool = false
    var postBodyTextView: PostBodyTextView

    init(
        _ textView: PostBodyTextView,
        text: Binding<String>,
        isFirstResponder: Binding<Bool>
    ) {
        self.postBodyTextView = textView
        _text = text
        _isFirstResponder = isFirstResponder
    }

    func textDidChange(_ notification: Notification) {
        guard let textView = notification.object as? NSTextView else { return }
        DispatchQueue.main.async {
            self.postBodyTextView.text = textView.string
        }
    }

    func textDidEndEditing(_ notification: Notification) {
        DispatchQueue.main.async {
            self.isFirstResponder = false
            self.didBecomeFirstResponder = false
        }
    }
}

struct PostBodyTextView: NSViewRepresentable {
    @Binding var text: String
    @Binding var textStyle: NSFont
    @Binding var isFirstResponder: Bool

    private let defaultLineHeight: CGFloat = 33

    func makeNSView(context: Context) -> NSTextView {
        let textView = NSTextView()

        textView.isEditable = true
        textView.isSelectable = true
        textView.font = textStyle
        textView.delegate = context.coordinator
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.autoresizingMask = [.width, .height]
        textView.backgroundColor = NSColor.clear

        return textView
    }

    func makeCoordinator() -> PostBodyCoordinator {
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
