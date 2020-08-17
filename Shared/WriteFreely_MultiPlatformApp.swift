import SwiftUI

@main
struct WriteFreely_MultiPlatformApp: App {
    @StateObject private var preferences = PreferencesModel()
    @StateObject private var account = AccountModel()

    #if os(macOS)
    @State private var selectedTab = 0
    #endif

    #if DEBUG
    @StateObject private var store = testPostStore
    #else
    @StateObject private var store = PostStore()
    #endif

    var body: some Scene {
        WindowGroup {
            ContentView(postStore: store, preferences: preferences, account: account)
//                .preferredColorScheme(preferences.selectedColorScheme)    // See PreferencesModel for info.
        }

        #if os(macOS)
        Settings {
            TabView(selection: $selectedTab) {
                MacAccountView(account: account)
                    .tabItem {
                        Image(systemName: "person.crop.circle")
                        Text("Account")
                    }
                    .tag(0)
                MacPreferencesView(preferences: preferences)
                    .tabItem {
                        Image(systemName: "gear")
                        Text("Preferences")
                    }
                    .tag(1)
            }
            .frame(minWidth: 300, maxWidth: 300, minHeight: 200, maxHeight: 200)
            .padding()
//            .preferredColorScheme(preferences.selectedColorScheme)    // See PreferencesModel for info.
        }
        #endif
    }
}
