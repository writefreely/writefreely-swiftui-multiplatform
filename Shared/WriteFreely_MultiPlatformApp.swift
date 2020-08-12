import SwiftUI

@main
struct WriteFreely_MultiPlatformApp: App {
    @StateObject private var preferences = PreferencesModel()
    @StateObject private var account = AccountModel()
    @State private var selectedTab = 0

    #if DEBUG
    @StateObject private var store = testPostStore
    #else
    @StateObject private var store = PostStore()
    #endif

    var body: some Scene {
        WindowGroup {
            ContentView(postStore: store, preferences: preferences, account: account)
                .preferredColorScheme(preferences.preferredColorScheme)
        }

        #if os(macOS)
        Settings {
            TabView(selection: $selectedTab) {
                Form {
                    Section(header: Text("Login Details")) {
                        AccountView(account: account)
                    }
                }
                .tabItem {
                    Image(systemName: "person.crop.circle")
                    Text("Account")
                }
                .tag(0)
                VStack {
                    PreferencesView(preferences: preferences)
                    Spacer()
                }
                .tabItem {
                    Image(systemName: "gear")
                    Text("Preferences")
                }
                .tag(1)
            }
            .frame(minWidth: 300, maxWidth: 300, minHeight: 200, maxHeight: 200)
            .padding()
            .preferredColorScheme(preferences.preferredColorScheme)
        }
        #endif
    }
}
