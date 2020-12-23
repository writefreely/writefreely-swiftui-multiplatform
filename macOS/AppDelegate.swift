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
            SUUpdater.shared()?.checkForUpdates(self)
        }
    }
}
