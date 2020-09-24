import UIKit

extension UINavigationController {
    override open func viewDidLoad() {
        super.viewDidLoad()

        let standardAppearance = UINavigationBarAppearance()
        standardAppearance.configureWithTransparentBackground()

        navigationBar.standardAppearance = standardAppearance
    }
}
