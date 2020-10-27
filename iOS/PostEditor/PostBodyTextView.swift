// Based on https://stackoverflow.com/a/56508132/1234545

import SwiftUI

struct PostBodyTextView: UIViewRepresentable {

    class Coordinator: NSObject, UITextViewDelegate {
        @Binding var text: String
        @Binding var isFirstResponder: Bool
        var didBecomeFirstResponder: Bool = false

        init(text: Binding<String>, isFirstResponder: Binding<Bool>) {
            _text = text
            _isFirstResponder = isFirstResponder
        }

        func textViewDidChangeSelection(_ textView: UITextView) {
            DispatchQueue.main.async {
                self.text = textView.text ?? ""
            }
        }
    }

    @Binding var text: String
    @Binding var textStyle: UIFont
    @Binding var isFirstResponder: Bool
    var lineSpacing: CGFloat

    func makeUIView(context: UIViewRepresentableContext<PostBodyTextView>) -> UITextView {
        let textView = UITextView(frame: .zero)
        textView.delegate = context.coordinator
        let font = textStyle
        let fontMetrics = UIFontMetrics(forTextStyle: .largeTitle)
        textView.font = fontMetrics.scaledFont(for: font)
        textView.backgroundColor = UIColor.clear
        return textView
    }

    func makeCoordinator() -> PostBodyTextView.Coordinator {
        return Coordinator(text: $text, isFirstResponder: $isFirstResponder)
    }

    func updateUIView(_ uiView: UITextView, context: UIViewRepresentableContext<PostBodyTextView>) {
        let attributedString = NSMutableAttributedString(string: text)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        attributedString.addAttribute(
            NSAttributedString.Key.paragraphStyle,
            value: paragraphStyle,
            range: NSMakeRange(0, attributedString.length) // swiftlint:disable:this legacy_constructor
        )

        uiView.attributedText = attributedString
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
