// Based on https://stackoverflow.com/a/56508132 and https://stackoverflow.com/a/48360549

import SwiftUI

class PostBodyCoordinator: NSObject, UITextViewDelegate, NSLayoutManagerDelegate {
    @Binding var text: String
    @Binding var isFirstResponder: Bool
    var lineSpacingMultiplier: CGFloat
    var didBecomeFirstResponder: Bool = false
    var postBodyTextView: PostBodyTextView

    weak var textView: UITextView?

    init(
        _ textView: PostBodyTextView,
        text: Binding<String>,
        isFirstResponder: Binding<Bool>,
        lineSpacingMultiplier: CGFloat
    ) {
        self.postBodyTextView = textView
        _text = text
        _isFirstResponder = isFirstResponder
        self.lineSpacingMultiplier = lineSpacingMultiplier

        super.init()

        updateSize()
    }

    func updateSize() {
        DispatchQueue.main.async {
            guard let view = self.textView else { return }
            let size = view.sizeThatFits(view.bounds.size)
            if self.postBodyTextView.height != size.height {
                self.postBodyTextView.height = size.height
            }
        }
    }

    func textViewDidChange(_ textView: UITextView) {
        DispatchQueue.main.async {
            self.postBodyTextView.text = textView.text ?? ""
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        self.isFirstResponder = false
        self.didBecomeFirstResponder = false
    }

    func layoutManager(
        _ layoutManager: NSLayoutManager,
        didCompleteLayoutFor textContainer: NSTextContainer?,
        atEnd layoutFinishedFlag: Bool
    ) {
        updateSize()
    }

    func layoutManager(
        _ layoutManager: NSLayoutManager,
        lineSpacingAfterGlyphAt glyphIndex: Int,
        withProposedLineFragmentRect rect: CGRect
    ) -> CGFloat {
        // HACK: - This seems to be the only way to get line spacing to update dynamically on iPad
        //         when switching between full-screen, split-screen, and slide-over views.
        if let window = UIApplication.shared.windows.filter({ $0.isKeyWindow }).first {
            // Get the width of the window to determine the size class
            if window.frame.width < 600 {
                // Use 0.25 multiplier for compact size class
                return 17 * 0.25
            } else {
                // Use 0.5 multiplier otherwise
                return 17 * 0.5
            }
        } else {
            return 17 * lineSpacingMultiplier
        }
    }
}

struct PostBodyTextView: UIViewRepresentable {
    @Binding var text: String
    @Binding var textStyle: UIFont
    @Binding var height: CGFloat
    @Binding var isFirstResponder: Bool
    @State var lineSpacing: CGFloat

    func makeUIView(context: UIViewRepresentableContext<PostBodyTextView>) -> UITextView {
        let textView = UITextView()

        textView.isEditable = true
        textView.isUserInteractionEnabled = true
        textView.isScrollEnabled = true
        textView.alwaysBounceVertical = false
        textView.smartDashesType = .no

        context.coordinator.textView = textView
        textView.delegate = context.coordinator
        textView.layoutManager.delegate = context.coordinator

        let font = textStyle
        let fontMetrics = UIFontMetrics(forTextStyle: .largeTitle)
        textView.font = fontMetrics.scaledFont(for: font)

        textView.backgroundColor = UIColor.clear

        return textView
    }

    func makeCoordinator() -> PostBodyCoordinator {
        return Coordinator(
            self,
            text: $text,
            isFirstResponder: $isFirstResponder,
            lineSpacingMultiplier: lineSpacing
        )
    }

    func updateUIView(_ uiView: UITextView, context: UIViewRepresentableContext<PostBodyTextView>) {
        if uiView.text != text {
            uiView.text = text
        }

        let font = textStyle
        let fontMetrics = UIFontMetrics(forTextStyle: .largeTitle)
        uiView.font = fontMetrics.scaledFont(for: font)

        // We don't want the text field to become first responder every time SwiftUI refreshes the view.
        if isFirstResponder && !context.coordinator.didBecomeFirstResponder {
            uiView.becomeFirstResponder()
            context.coordinator.didBecomeFirstResponder = true
        }
    }
}
