import SwiftUI

class PreferencesModel: ObservableObject {
    @Environment(\.colorScheme) var currentColorScheme
    @Published var preferredColorScheme: ColorScheme = .light
    @Published var appearance: Int = 0 {
        didSet {
            switch appearance {
            case 0:
                preferredColorScheme = currentColorScheme
            case 1:
                preferredColorScheme = .light
            case 2:
                preferredColorScheme = .dark
            default:
                print("Unknown option selected, failing gracefully...")
            }
        }
    }
}
