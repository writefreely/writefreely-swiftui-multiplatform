import UIKit

extension UINavigationController {
    override open func viewDidLoad() {
        super.viewDidLoad()

        let standardAppearance = UINavigationBarAppearance()
        standardAppearance.configureWithOpaqueBackground()
        navigationBar.standardAppearance = standardAppearance
    }
}
