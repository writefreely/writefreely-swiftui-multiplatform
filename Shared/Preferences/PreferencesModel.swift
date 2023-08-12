import SwiftUI

class PreferencesModel: ObservableObject {
    private let defaults = UserDefaults.shared

    @Published var selectedColorScheme: ColorScheme?
    @Published var appearance: Int = 0
    @Published var font: Int = 0 {
        didSet {
            defaults.set(font, forKey: WFDefaults.defaultFontIntegerKey)
        }
    }
}
