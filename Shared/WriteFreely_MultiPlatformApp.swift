import SwiftUI

#if os(macOS)
import Sparkle
#endif

@main
struct CheckForDebugModifier {
    static func main() {
        #if os(macOS)
            if NSEvent.modifierFlags.contains(.shift) {
                print("Debug launch detected")
                // Run debug-mode launch code here
            } else {
                print("Normal launch detected")
                // Don't do anything
            }
        #endif
        WriteFreely_MultiPlatformApp.main()
    }
}

struct WriteFreely_MultiPlatformApp: App {
    @StateObject private var model = WriteFreelyModel()
    @AppStorage("showAllPostsFlag") var showAllPostsFlag: Bool = false
    @AppStorage("selectedCollectionURL") var selectedCollectionURL: URL?
    @AppStorage("selectedPostURL") var selectedPostURL: URL?

    #if os(macOS)
    // swiftlint:disable:next weak_delegate
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var selectedTab = 0
    #endif

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear(perform: {
                    self.model.showAllPosts = showAllPostsFlag
                    self.model.selectedCollection = fetchSelectedCollectionFromAppStorage()
                    DispatchQueue.main.asyncAfter(deadline: .now()) {
                        self.model.selectedPost = fetchSelectedPostFromAppStorage()
                    }
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

            // Navigate to the Drafts list
            self.model.showAllPosts = false
            self.model.selectedCollection = nil
        }
        // Create the new-post managed object
        let managedPost = WFAPost(context: LocalStorageManager.persistentContainer.viewContext)
        managedPost.createdDate = Date()
        managedPost.title = ""
        managedPost.body = ""
        managedPost.status = PostStatus.local.rawValue
        managedPost.collectionAlias = nil
        switch model.preferences.font {
        case 1:
            managedPost.appearance = "sans"
        case 2:
            managedPost.appearance = "wrap"
        default:
            managedPost.appearance = "serif"
        }
        if let languageCode = Locale.current.languageCode {
            managedPost.language = languageCode
            managedPost.rtl = Locale.characterDirection(forLanguage: languageCode) == .rightToLeft
        }
        withAnimation {
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self.model.selectedPost = managedPost
            }
        }
    }

    private func fetchSelectedPostFromAppStorage() -> WFAPost? {
        guard let objectURL = selectedPostURL else { return nil }
        let coordinator = LocalStorageManager.persistentContainer.persistentStoreCoordinator
        guard let managedObjectID = coordinator.managedObjectID(forURIRepresentation: objectURL) else { return nil }
        guard let object = LocalStorageManager.persistentContainer.viewContext.object(
                with: managedObjectID
        ) as? WFAPost else { return nil }
        return object
    }

    private func fetchSelectedCollectionFromAppStorage() -> WFACollection? {
        guard let objectURL = selectedCollectionURL else { return nil }
        let coordinator = LocalStorageManager.persistentContainer.persistentStoreCoordinator
        guard let managedObjectID = coordinator.managedObjectID(forURIRepresentation: objectURL) else { return nil }
        guard let object = LocalStorageManager.persistentContainer.viewContext.object(
                with: managedObjectID
        ) as? WFACollection else { return nil }
        return object
    }
}
