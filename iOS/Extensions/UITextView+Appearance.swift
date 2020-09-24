import UIKit

extension UITextView {
    override open func draw(_ rect: CGRect) {
        super.draw(rect)
        let appearance = UITextView.appearance()
        appearance.backgroundColor = .clear
    }
}
