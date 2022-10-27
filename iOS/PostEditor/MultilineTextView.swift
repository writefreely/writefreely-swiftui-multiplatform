// Credit: https://stackoverflow.com/a/58639072

import SwiftUI
import UIKit

private struct UITextViewWrapper: UIViewRepresentable {
    typealias UIViewType = UITextView

    @Binding var text: String
    @Binding var calculatedHeight: CGFloat
    @Binding var isEditing: Bool
    var textStyle: UIFont
    var onDone: (() -> Void)?

    func makeUIView(context: UIViewRepresentableContext<UITextViewWrapper>) -> UITextView {
        let textField = UITextView()
        textField.delegate = context.coordinator

        textField.isEditable = true
        textField.font = UIFont.preferredFont(forTextStyle: .body)
        textField.isSelectable = true
        textField.isUserInteractionEnabled = true
        textField.isScrollEnabled = false
        textField.backgroundColor = UIColor.clear

        let font = textStyle
        let fontMetrics = UIFontMetrics(forTextStyle: .largeTitle)
        textField.font = fontMetrics.scaledFont(for: font)

        if nil != onDone {
            textField.returnKeyType = .next
        }

        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return textField
    }

    func updateUIView(_ uiView: UITextView, context: UIViewRepresentableContext<UITextViewWrapper>) {
        if uiView.text != self.text {
            uiView.text = self.text
        }

        if uiView.window != nil, isEditing {
            uiView.becomeFirstResponder()
        }

        UITextViewWrapper.recalculateHeight(view: uiView, result: $calculatedHeight)
    }

    fileprivate static func recalculateHeight(view: UIView, result: Binding<CGFloat>) {
        let newSize = view.sizeThatFits(CGSize(width: view.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
        if result.wrappedValue != newSize.height {
            DispatchQueue.main.async {
                result.wrappedValue = newSize.height // !! must be called asynchronously
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(text: $text, height: $calculatedHeight, isFirstResponder: $isEditing, onDone: onDone)
    }

    final class Coordinator: NSObject, UITextViewDelegate {
        @Binding var isFirstResponder: Bool
        var text: Binding<String>
        var calculatedHeight: Binding<CGFloat>
        var onDone: (() -> Void)?

        init(
            text: Binding<String>,
            height: Binding<CGFloat>,
            isFirstResponder: Binding<Bool>,
            onDone: (() -> Void)? = nil
        ) {
            self.text = text
            self.calculatedHeight = height
            self._isFirstResponder = isFirstResponder
            self.onDone = onDone
        }

        func textViewDidChange(_ uiView: UITextView) {
            text.wrappedValue = uiView.text
            UITextViewWrapper.recalculateHeight(view: uiView, result: calculatedHeight)
        }

        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            if let onDone = self.onDone, text == "\n" {
                textView.resignFirstResponder()
                onDone()
                return false
            }
            return true
        }

        func textViewDidEndEditing(_ textView: UITextView) {
            self.isFirstResponder = false
        }
    }

}

struct MultilineTextField: View {

    private var placeholder: String
    private var textStyle: UIFont
    private var onCommit: (() -> Void)?

    @Binding var isFirstResponder: Bool
    @Binding private var text: String
    private var internalText: Binding<String> {
        Binding<String>(get: { self.text }) {   // swiftlint:disable:this multiple_closures_with_trailing_closure
            self.text = $0
            self.showingPlaceholder = $0.isEmpty
        }
    }

    @State private var dynamicHeight: CGFloat = 100
    @State private var showingPlaceholder = false

    init (
        _ placeholder: String = "",
        text: Binding<String>,
        font: UIFont,
        isFirstResponder: Binding<Bool>,
        onCommit: (() -> Void)? = nil
    ) {
        self.placeholder = placeholder
        self.onCommit = onCommit
        self.textStyle = font
        self._isFirstResponder = isFirstResponder
        self._text = text
        self._showingPlaceholder = State<Bool>(initialValue: self.text.isEmpty)
    }

    var body: some View {
        UITextViewWrapper(
            text: self.internalText,
            calculatedHeight: $dynamicHeight,
            isEditing: $isFirstResponder,
            textStyle: textStyle,
            onDone: onCommit
        )
        .frame(minHeight: dynamicHeight, maxHeight: dynamicHeight)
        .background(placeholderView, alignment: .topLeading)
    }

    var placeholderView: some View {
        Group {
            if showingPlaceholder {
                let font = Font(textStyle)
                Text(placeholder).foregroundColor(.gray)
                    .padding(.leading, 4)
                    .padding(.top, 8)
                    .font(font)
            }
        }
    }
}
