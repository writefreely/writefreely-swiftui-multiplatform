// Credit:
// https://github.com/sindresorhus/Blear/blob/9ce7cd6ad8d6a88f8d0be12b1ef9152baeeacf96/Blear/Utilities.swift#L1052-L1064

import SwiftUI

extension EnvironmentValues {

    private struct ExtensionContext: EnvironmentKey {
        static var defaultValue: NSExtensionContext?
    }

    /// The `.extensionContext` of an app extension view controller.
    var extensionContext: NSExtensionContext? {
        get { self[ExtensionContext.self] }
        set {
            self[ExtensionContext.self] = newValue
        }
    }

}
