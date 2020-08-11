import SwiftUI

@main
struct WriteFreely_MultiPlatformApp: App {
    @StateObject private var preferences = PreferencesModel()

    #if DEBUG
    @StateObject private var store = testPostStore
    #else
    @StateObject private var store = PostStore()
    #endif

    var body: some Scene {
        WindowGroup {
            ContentView(postStore: store, preferences: preferences)
                .preferredColorScheme(preferences.preferredColorScheme)
        }

        #if os(macOS)
        Settings {
            SettingsView(preferences: preferences)
                .frame(minWidth: 300, maxWidth: 300, minHeight: 200, maxHeight: 200)
                .padding()
        }
        #endif
    }
}
