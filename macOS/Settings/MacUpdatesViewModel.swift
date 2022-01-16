/// See https://sparkle-project.org/documentation/programmatic-setup#create-an-updater-in-swiftui

import SwiftUI
import Sparkle

/// This view model class manages Sparkle's updater and publishes when new updates are allowed to be checked.
final class MacUpdatesViewModel: ObservableObject {

    @Published var canCheckForUpdates = false
    private let updaterController: SPUStandardUpdaterController

    init() {
        updaterController = SPUStandardUpdaterController(startingUpdater: true,
                                                         updaterDelegate: nil,
                                                         userDriverDelegate: nil)

        updaterController.updater.publisher(for: \.canCheckForUpdates)
            .assign(to: &$canCheckForUpdates)
    }

    func checkForUpdates() {
        updaterController.checkForUpdates(nil)
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
