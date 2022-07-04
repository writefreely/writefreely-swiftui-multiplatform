import Cocoa
import Sparkle

class AppDelegate: NSObject, NSApplicationDelegate {

    // MARK: - Window handling when miniaturized into app icon on the Dock
    // Credit to Henry Cooper (pillboxer) on GitHub:
    // https://github.com/tact/beta-bugs/issues/31#issuecomment-855914705

    // If the window is currently minimized into the Dock, de-miniaturize it (note that if it's minimized
    // and the user uses OPT+TAB to switch to it, it will be de-miniaturized and brought to the foreground).
    func applicationDidBecomeActive(_ notification: Notification) {
        if let window = NSApp.windows.first {
            window.deminiaturize(nil)
        }
    }

    // If we're miniaturizing the window, deactivate it as well.
    // Credit to KHKnobl on GitHub:
    // https://github.com/writefreely/writefreely-swiftui-multiplatform/issues/135#issuecomment-1101713817
    func applicationDidChangeOcclusionState(_ notification: Notification) {
        if let window = NSApp.windows.first, window.isMiniaturized {
            NSApp.hide(self)
        }
    }

    lazy var windows = NSWindow()
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            for window in sender.windows {
                window.makeKeyAndOrderFront(self)
            }
        }
        return true
    }

}
