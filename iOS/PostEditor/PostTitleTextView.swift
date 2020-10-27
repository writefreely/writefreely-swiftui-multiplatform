// Based on https://lostmoa.com/blog/DynamicHeightForTextFieldInSwiftUI/
// and https://stackoverflow.com/a/56508132/1234545

import SwiftUI

class Coordinator: NSObject, UITextViewDelegate, NSLayoutManagerDelegate {
    @Binding var text: String
    @Binding var isFirstResponder: Bool
    var didBecomeFirstResponder: Bool = false
    var postTitleTextView: PostTitleTextView

    weak var textView: UITextView?

    init(_ textView: PostTitleTextView, text: Binding<String>, isFirstResponder: Binding<Bool>) {
        self.postTitleTextView = textView
        _text = text
        _isFirstResponder = isFirstResponder
    }

    func textViewDidChangeSelection(_ textView: UITextView) {
        DispatchQueue.main.async {
            self.postTitleTextView.text = textView.text ?? ""
        }
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            self.isFirstResponder.toggle()
            return false
        }
        return true
    }

    func layoutManager(
        _ layoutManager: NSLayoutManager,
        didCompleteLayoutFor textContainer: NSTextContainer?,
        atEnd layoutFinishedFlag: Bool
    ) {
        DispatchQueue.main.async {
            guard let view = self.textView else {
                return
            }
            let size = view.sizeThatFits(view.bounds.size)
            if self.postTitleTextView.height != size.height {
                self.postTitleTextView.height = size.height
            }
        }
    }
}

struct PostTitleTextView: UIViewRepresentable {
    @Binding var text: String
    @Binding var textStyle: UIFont
    @Binding var height: CGFloat
    @Binding var isFirstResponder: Bool

    func makeUIView(context: UIViewRepresentableContext<PostTitleTextView>) -> UITextView {
        let textView = UITextView()

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

    func makeCoordinator() -> Coordinator {
        return Coordinator(self, text: $text, isFirstResponder: $isFirstResponder)
    }

    func updateUIView(_ uiView: UITextView, context: UIViewRepresentableContext<PostTitleTextView>) {
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
