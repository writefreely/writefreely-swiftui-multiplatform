/// See https://sparkle-project.org/documentation/programmatic-setup#create-an-updater-in-swiftui

import SwiftUI
import Sparkle

/// This view model class manages Sparkle's updater and publishes when new updates are allowed to be checked.
final class MacUpdatesViewModel: ObservableObject {

    @Published var canCheckForUpdates = false
    private let updaterController: SPUStandardUpdaterController
    private let updaterDelegate = MacUpdatesViewModelDelegate()

    var automaticallyCheckForUpdates: Bool {
        get {
            return updaterController.updater.automaticallyChecksForUpdates
        }
        set(newValue) {
            updaterController.updater.automaticallyChecksForUpdates = newValue
        }
    }

    init() {
        updaterController = SPUStandardUpdaterController(startingUpdater: true,
                                                         updaterDelegate: updaterDelegate,
                                                         userDriverDelegate: nil)

        updaterController.updater.publisher(for: \.canCheckForUpdates)
            .assign(to: &$canCheckForUpdates)

        if automaticallyCheckForUpdates {
            updaterController.updater.checkForUpdatesInBackground()
        }
    }

    func checkForUpdates() {
        updaterController.checkForUpdates(nil)
    }

    func getLastUpdateCheckDate() -> Date? {
        return updaterController.updater.lastUpdateCheckDate
    }

    @discardableResult
    func toggleAllowedChannels() -> Set<String> {
        return updaterDelegate.allowedChannels(for: updaterController.updater)
    }

}

final class MacUpdatesViewModelDelegate: NSObject, SPUUpdaterDelegate {

    @AppStorage(WFDefaults.subscribeToBetaUpdates, store: UserDefaults.shared)
    var subscribeToBetaUpdates: Bool = false

    func allowedChannels(for updater: SPUUpdater) -> Set<String> {
        let allowedChannels = Set(subscribeToBetaUpdates ? ["beta"] : [])
        return allowedChannels
    }

}

// This additional view is needed for the disabled state on the menu item to work properly before Monterey.
// See https://stackoverflow.com/questions/68553092/menu-not-updating-swiftui-bug for more information
struct CheckForUpdatesView: View {

    @ObservedObject var updaterViewModel: MacUpdatesViewModel

    var body: some View {
        Button("Check for Updates…", action: updaterViewModel.checkForUpdates)
            .disabled(!updaterViewModel.canCheckForUpdates)
    }

}
