// Based on:
//
// MacEditorTextView
// Copyright (c) Thiago Holanda 2020
// https://twitter.com/tholanda
//
// MIT license
//
// See: https://gist.github.com/unnamedd/6e8c3fbc806b8deb60fa65d6b9affab0

import Combine
import SwiftUI

struct MacEditorTextView: NSViewRepresentable {
    @Binding var text: String
    var isFirstResponder: Bool = false
    var isEditable: Bool = true
    var font: NSFont? = NSFont(name: PostAppearance.serif.rawValue, size: 17)

    var onEditingChanged: () -> Void = {}
    var onCommit: () -> Void = {}
    var onTextChange: (String) -> Void = { _ in }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeNSView(context: Context) -> CustomTextView {
        let textView = CustomTextView(
            text: text,
            isEditable: isEditable,
            isFirstResponder: isFirstResponder,
            font: font
        )
        textView.delegate = context.coordinator

        return textView
    }

    func updateNSView(_ view: CustomTextView, context: Context) {
        view.text = text
        view.selectedRanges = context.coordinator.selectedRanges
    }
}

// MARK: - Coordinator

extension MacEditorTextView {

    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: MacEditorTextView
        var selectedRanges: [NSValue] = []
        var didBecomeFirstResponder: Bool = false

        init(_ parent: MacEditorTextView) {
            self.parent = parent
        }

        func textDidBeginEditing(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else {
                return
            }

            self.parent.text = textView.string
            self.parent.onEditingChanged()
        }

        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else {
                return
            }

            self.parent.text = textView.string
            self.selectedRanges = textView.selectedRanges
            self.parent.onTextChange(textView.string)
        }

        func textDidEndEditing(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else {
                return
            }

            self.parent.text = textView.string
            self.parent.onCommit()
        }
    }
}

// MARK: - CustomTextView

final class CustomTextView: NSView {
    private var isFirstResponder: Bool
    private var isEditable: Bool
    private var font: NSFont?

    weak var delegate: NSTextViewDelegate?

    var text: String {
        didSet {
            textView.string = text
        }
    }

    var selectedRanges: [NSValue] = [] {
        didSet {
            guard selectedRanges.count > 0 else {
                return
            }

            textView.selectedRanges = selectedRanges
        }
    }

    private lazy var scrollView: NSScrollView = {
        let scrollView = NSScrollView()
        scrollView.drawsBackground = false
        scrollView.borderType = .noBorder
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalRuler = false
        scrollView.autoresizingMask = [.width, .height]
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        return scrollView
    }()

    private lazy var textView: NSTextView = {
        let contentSize = scrollView.contentSize
        let textStorage = NSTextStorage()

        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)

        let textContainer = NSTextContainer(containerSize: scrollView.frame.size)
        textContainer.widthTracksTextView = true
        textContainer.containerSize = NSSize(
            width: contentSize.width,
            height: CGFloat.greatestFiniteMagnitude
        )

        layoutManager.addTextContainer(textContainer)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8.5

        let textView = NSTextView(frame: .zero, textContainer: textContainer)
        textView.autoresizingMask = .width
        textView.delegate = self.delegate
        textView.drawsBackground = false
        textView.font = self.font
        textView.defaultParagraphStyle = paragraphStyle
        textView.isEditable = self.isEditable
        textView.isHorizontallyResizable = false
        textView.isVerticallyResizable = true
        textView.maxSize = NSSize(
            width: CGFloat.greatestFiniteMagnitude,
            height: CGFloat.greatestFiniteMagnitude
        )
        textView.minSize = NSSize(width: 0, height: contentSize.height)
        textView.textColor = NSColor.labelColor

        return textView
    }()

    // MARK: - Init
    init(text: String, isEditable: Bool, isFirstResponder: Bool, font: NSFont?) {
        self.font = font
        self.isFirstResponder = isFirstResponder
        self.isEditable = isEditable
        self.text = text

        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life cycle

    override func viewWillDraw() {
        super.viewWillDraw()

        setupScrollViewConstraints()
        setupTextView()

        if isFirstResponder {
            self.window?.makeFirstResponder(self.textView)
        }
    }

    func setupScrollViewConstraints() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor)
        ])
    }

    func setupTextView() {
        scrollView.documentView = textView
    }
}
