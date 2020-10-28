// Based on https://stackoverflow.com/a/56508132/1234545 and https://stackoverflow.com/a/48360549/1234545

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
    }

    func textViewDidChange(_ textView: UITextView) {
        DispatchQueue.main.async {
            self.postBodyTextView.text = textView.text ?? ""
        }
    }

    func layoutManager(
        _ layoutManager: NSLayoutManager,
        lineSpacingAfterGlyphAt glyphIndex: Int,
        withProposedLineFragmentRect rect: CGRect
    ) -> CGFloat {
        return 17 * lineSpacingMultiplier
    }
}

struct PostBodyTextView: UIViewRepresentable {
    @Binding var text: String
    @Binding var textStyle: UIFont
    @Binding var isFirstResponder: Bool
    var lineSpacing: CGFloat

    func makeUIView(context: UIViewRepresentableContext<PostBodyTextView>) -> UITextView {
        let textView = UITextView(frame: .zero)

        textView.isEditable = true
        textView.isUserInteractionEnabled = true
        textView.isScrollEnabled = true
        textView.alwaysBounceVertical = false

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
        uiView.text = text

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
