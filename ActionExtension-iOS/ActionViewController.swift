import SwiftUI

class ActionViewController: UIViewController {

    let moc = LocalStorageManager.standard.container.viewContext

    override var prefersStatusBarHidden: Bool { true }

    override func viewDidLoad() {
        super.viewDidLoad()

        let contentView = ContentView()
            .environment(\.extensionContext, extensionContext)
            .environment(\.managedObjectContext, moc)

        view = UIHostingView(rootView: contentView)
        view.isOpaque = true
        view.backgroundColor = .systemBackground
    }

}
