import SwiftUI

@main
struct WriteFreely_MultiPlatformApp: App {
    #if DEBUG
    @StateObject private var store = testPostStore
    #else
    @StateObject private var store = PostStore()
    #endif

    var body: some Scene {
        WindowGroup {
            ContentView(postStore: store)
        }

        #if os(macOS)
        Settings {
            SettingsView()
                .frame(minWidth: 300, maxWidth: 300, minHeight: 200, maxHeight: 200)
                .padding()
        }
        #endif
    }
}
