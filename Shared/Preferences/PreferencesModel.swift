import SwiftUI

enum Appearance: Int {
    case system = 0
    case light = 1
    case dark = 2
}

class PreferencesModel: ObservableObject {
    private let defaults = UserDefaults.shared

    @Published var selectedColorScheme: ColorScheme?
    @Published var appearance: Int = 0
    @Published var font: Int = 0 {
        didSet {
            defaults.set(font, forKey: WFDefaults.defaultFontIntegerKey)
        }
    }

    @available(iOSApplicationExtension, unavailable)
    func updateAppearance(to appearance: Appearance) {
        #if os(iOS)
        var window: UIWindow? {
            guard let scene = UIApplication.shared.connectedScenes.first,
                  let windowSceneDelegate = scene.delegate as? UIWindowSceneDelegate,
                  let window = windowSceneDelegate.window else {
                return nil
            }
            return window
        }
        #endif

        switch appearance {
        case .light:
            #if os(macOS)
            NSApp.appearance = NSAppearance(named: .aqua)
            #else
            window?.overrideUserInterfaceStyle = .light
            #endif
        case .dark:
            #if os(macOS)
            NSApp.appearance = NSAppearance(named: .darkAqua)
            #else
            window?.overrideUserInterfaceStyle = .dark
            #endif
        default:
            #if os(macOS)
            NSApp.appearance = nil
            #else
            window?.overrideUserInterfaceStyle = .unspecified
            #endif
        }
    }
}
