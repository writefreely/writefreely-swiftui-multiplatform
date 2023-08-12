import SwiftUI

struct PreferencesView: View {
    @ObservedObject var preferences: PreferencesModel

    /* We're stuck dropping into AppKit/UIKit to set light/dark schemes for now,
     * because setting the .preferredColorScheme modifier on views in SwiftUI is
     * currently unreliable.
     *
     * Feedback submitted to Apple:
     *
     * FB8382883: "On macOS 11β4, preferredColorScheme modifier does not respect .light ColorScheme"
     * FB8383053: "On iOS 14β4/macOS 11β4, it is not possible to unset preferredColorScheme after setting
     *              it to either .light or .dark"
     */

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

    var body: some View {
        VStack {
            VStack {
                Text("Choose the preferred appearance for the app.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Picker(selection: $preferences.appearance, label: Text("Appearance")) {
                    Text("System").tag(0)
                    Text("Light").tag(1)
                    Text("Dark").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            .padding(.bottom)

            VStack {
                Text("Choose the default font for new posts.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Picker(selection: $preferences.font, label: Text("Default Font")) {
                    Text("Serif").tag(0)
                    Text("Sans-Serif").tag(1)
                    Text("Monospace").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.bottom)
                switch preferences.font {
                case 1:
                    Text("Sample Text")
                        .frame(width: 240, height: 50, alignment: .center)
                        .font(.custom("OpenSans-Regular", size: 20))
                case 2:
                    Text("Sample Text")
                        .frame(width: 240, height: 50, alignment: .center)
                        .font(.custom("Hack-Regular", size: 20))
                default:
                    Text("Sample Text")
                        .frame(width: 240, height: 50, alignment: .center)
                        .font(.custom("Lora", size: 20))
                }
            }
            .padding(.bottom)
        }
        .onChange(of: preferences.appearance) { value in
            preferences.updateAppearance(to: Appearance(rawValue: value) ?? .system)
            UserDefaults.shared.set(value, forKey: WFDefaults.colorSchemeIntegerKey)
        }
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesView(preferences: PreferencesModel())
    }
}
