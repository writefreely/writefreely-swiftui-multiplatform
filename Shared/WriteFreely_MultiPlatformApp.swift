import SwiftUI

#if os(macOS)
import Sparkle
#endif

@main
struct CheckForDebugModifier {
    static func main() {
        #if os(macOS)
            if NSEvent.modifierFlags.contains(.shift) {
                // Clear the launch-to-last-draft values to load a new draft.
                UserDefaults.standard.setValue(false, forKey: "showAllPostsFlag")
                UserDefaults.standard.setValue(nil, forKey: "selectedCollectionURL")
                UserDefaults.standard.setValue(nil, forKey: "lastDraftURL")
            } else {
                // No-op
            }
        #endif
        WriteFreely_MultiPlatformApp.main()
    }
}

struct WriteFreely_MultiPlatformApp: App {
    @StateObject private var model = WriteFreelyModel.shared

    #if os(macOS)
    // swiftlint:disable:next weak_delegate
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var selectedTab = 0
    #endif

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear(perform: {
//                    if model.editor.showAllPostsFlag {
//                        DispatchQueue.main.async {
//                            self.model.selectedCollection = nil
//                            self.model.showAllPosts = true
//                        }
//                    } else {
//                        DispatchQueue.main.async {
//                            self.model.selectedCollection = model.editor.fetchSelectedCollectionFromAppStorage()
//                            self.model.showAllPosts = false
//                        }
//                    }
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                        if model.editor.lastDraftURL != nil {
//                            self.model.selectedPost = model.editor.fetchLastDraftFromAppStorage()
//                        } else {
//                            createNewLocalPost()
//                        }
//                    }
                })
                .environmentObject(model)
                .environment(\.managedObjectContext, LocalStorageManager.persistentContainer.viewContext)
//                .preferredColorScheme(preferences.selectedColorScheme)    // See PreferencesModel for info.
        }
        .commands {
            #if os(macOS)
            CommandGroup(after: .appInfo, addition: {
                Button("Check For Updates") {
                    SUUpdater.shared()?.checkForUpdates(self)
                }
            })
            #endif
            CommandGroup(replacing: .newItem, addition: {
                Button("New Post") {
                    createNewLocalPost()
                }
                .keyboardShortcut("n", modifiers: [.command])
            })
            CommandGroup(after: .newItem) {
                Button("Refresh Posts") {
                    DispatchQueue.main.async {
                        model.fetchUserCollections()
                        model.fetchUserPosts()
                    }
                }
                .disabled(!model.account.isLoggedIn)
                .keyboardShortcut("r", modifiers: [.command])
            }
            SidebarCommands()
            #if os(macOS)
            PostCommands(model: model)
            #endif
            CommandGroup(after: .help) {
                Button("Visit Support Forum") {
                    #if os(macOS)
                    NSWorkspace().open(model.helpURL)
                    #else
                    UIApplication.shared.open(model.helpURL)
                    #endif
                }
            }
            ToolbarCommands()
            TextEditingCommands()
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
                MacUpdatesView()
                    .tabItem {
                        Image(systemName: "arrow.down.circle")
                        Text("Updates")
                    }
                    .tag(2)
            }
            .frame(minWidth: 500, maxWidth: 500, minHeight: 200)
            .padding()
//            .preferredColorScheme(preferences.selectedColorScheme)    // See PreferencesModel for info.
        }
        #endif
    }

    private func createNewLocalPost() {
        withAnimation {
            // Un-set the currently selected post
            self.model.selectedPost = nil
        }
        // Create the new-post managed object
        let managedPost = model.editor.generateNewLocalPost(withFont: model.preferences.font)
        withAnimation {
            // Set it as the selectedPost
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self.model.selectedPost = managedPost
            }
        }
    }
}
