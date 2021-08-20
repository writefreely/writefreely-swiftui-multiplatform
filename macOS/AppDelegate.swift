import Cocoa
import Sparkle

class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationWillFinishLaunching(_ notification: Notification) {
        // Check UserDefaults for values; if the key doesn't exist (e.g., if MacUpdatesView hasn't ever been shown),
        // bool(forKey:) returns false, so set SUUpdater.shared() appropriately.
        let automaticallyChecksForUpdates = UserDefaults.standard.bool(forKey: "automaticallyChecksForUpdates")
        let subscribeToBetaUpdates = UserDefaults.standard.bool(forKey: "subscribeToBetaUpdates")

        // Set Sparkle properties.
        SUUpdater.shared()?.automaticallyChecksForUpdates = automaticallyChecksForUpdates
        if subscribeToBetaUpdates {
            SUUpdater.shared()?.feedURL = URL(string: AppcastFeedUrl.beta.rawValue)
        } else {
            SUUpdater.shared()?.feedURL = URL(string: AppcastFeedUrl.release.rawValue)
        }

        // If enabled, check for updates.
        if automaticallyChecksForUpdates {
            SUUpdater.shared()?.checkForUpdatesInBackground()
        }
    }

    // MARK: - Window handling when miniaturized into app icon on the Dock
    // Credit to Henry Cooper (pillboxer) on GitHub:
    // https://github.com/tact/beta-bugs/issues/31#issuecomment-855914705

    // If the window is currently minimized into the Dock, de-miniaturize it (note that if it's minimized
    // and the user uses OPT+TAB to switch to it, it will be de-miniaturized and brought to the foreground).
    func applicationDidBecomeActive(_ notification: Notification) {
        print("💬 Fired:", #function)
        if let window = NSApp.windows.first {
            window.deminiaturize(nil)
        }
    }

    // If we're miniaturizing the window, deactivate it as well by activating Finder.app (note that
    // this will bring any Finder windows that are behind other apps to the foreground).
    func applicationDidChangeOcclusionState(_ notification: Notification) {
        print("💬 Fired:", #function)
        if let window = NSApp.windows.first, window.isMiniaturized {
            NSWorkspace.shared.runningApplications.first(where: {
                $0.activationPolicy == .regular
            })?.activate(options: .activateAllWindows)
        }
    }

    lazy var windows = NSWindow()
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        print("💬 Fired:", #function)
        if !flag {
            for window in sender.windows {
                window.makeKeyAndOrderFront(self)
            }
        }
        return true
    }

}
