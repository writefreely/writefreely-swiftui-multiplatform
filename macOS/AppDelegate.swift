import Cocoa
import Sparkle

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        SUUpdater.shared()?.automaticallyChecksForUpdates = true
        /*
         Next line prints:
         ⚠️ You must specify the URL of the appcast as the SUFeedURL key in either the Info.plist or the user defaults!
         */
        SUUpdater.shared()?.checkForUpdates(self)
    }
}
