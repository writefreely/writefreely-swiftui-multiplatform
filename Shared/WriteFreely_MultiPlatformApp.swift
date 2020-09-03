import SwiftUI

@main
struct WriteFreely_MultiPlatformApp: App {
    @StateObject private var model = WriteFreelyModel()

    #if os(macOS)
    @State private var selectedTab = 0
    #endif

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(model)
                .environment(\.managedObjectContext, PersistenceManager.persistentContainer.viewContext)
//                .preferredColorScheme(preferences.selectedColorScheme)    // See PreferencesModel for info.
        }

        #if os(macOS)
        Settings {
            TabView(selection: $selectedTab) {
                MacAccountView()
                    .environmentObject(model)
                    .tabItem {
                        Image(systemName: "person.crop.circle")
                        Text("Account")
                    }
                    .tag(0)
                MacPreferencesView(preferences: model.preferences)
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
