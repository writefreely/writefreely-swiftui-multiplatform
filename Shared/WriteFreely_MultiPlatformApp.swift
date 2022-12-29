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
                UserDefaults.shared.setValue(false, forKey: WFDefaults.showAllPostsFlag)
                UserDefaults.shared.setValue(nil, forKey: WFDefaults.selectedCollectionURL)
                UserDefaults.shared.setValue(nil, forKey: WFDefaults.lastDraftURL)
            } else {
                // No-op
            }
        #endif
        WriteFreely_MultiPlatformApp.main()
    }
}

struct WriteFreely_MultiPlatformApp: App {
    @StateObject private var model = WriteFreelyModel.shared

    private let logger = Logging(for: String(describing: WriteFreely_MultiPlatformApp.self))

    #if os(macOS)
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var updaterViewModel = MacUpdatesViewModel()
    @State private var selectedTab = 0
    #endif

    @State private var didCrash = UserDefaults.shared.bool(forKey: WFDefaults.didHaveFatalError)

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear(perform: {
                    if model.editor.showAllPostsFlag {
                        DispatchQueue.main.async {
                            self.model.selectedCollection = nil
                            self.model.showAllPosts = true
                            showLastDraftOrCreateNewLocalPost()
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.model.selectedCollection = model.editor.fetchSelectedCollectionFromAppStorage()
                            self.model.showAllPosts = false
                            showLastDraftOrCreateNewLocalPost()
                        }
                    }
                })
                .alert(isPresented: $didCrash) {
                    var helpMsg = "Alert the humans by sharing what happened on the help forum."
                    if let errorMsg = UserDefaults.shared.object(forKey: WFDefaults.fatalErrorDescription) as? String {
                        helpMsg.append("\n\n\(errorMsg)")
                    }

                    return Alert(
                        title: Text("Crash Detected"),
                        message: Text(helpMsg),
                        primaryButton: .default(
                            Text("Let us know"), action: didPressCrashAlertButton
                        ),
                        secondaryButton: .cancel(
                            Text("Dismiss"),
                            action: resetCrashFlags
                        )
                    )
                }
                .onAppear {
                    if #available(iOS 15, *) {
                        if didCrash { generateCrashLogPost() }
                    }
                }
                .withErrorHandling()
                .environmentObject(model)
                .environment(\.managedObjectContext, LocalStorageManager.standard.container.viewContext)
//                .preferredColorScheme(preferences.selectedColorScheme)    // See PreferencesModel for info.
        }
        .commands {
            #if os(macOS)
            CommandGroup(after: .appInfo) {
                CheckForUpdatesView(updaterViewModel: updaterViewModel)
            }
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
                MacUpdatesView(updaterViewModel: updaterViewModel)
                    .tabItem {
                        Image(systemName: "arrow.down.circle")
                        Text("Updates")
                    }
                    .tag(2)
            }
            .environmentObject(model)
            .withErrorHandling()
            .frame(minWidth: 500, maxWidth: 500, minHeight: 200)
            .padding()
//            .preferredColorScheme(preferences.selectedColorScheme)    // See PreferencesModel for info.
        }
        #endif
    }

    private func showLastDraftOrCreateNewLocalPost() {
        if model.editor.lastDraftURL != nil {
            self.model.selectedPost = model.editor.fetchLastDraftFromAppStorage()
        } else {
            createNewLocalPost()
        }
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                self.model.selectedPost = managedPost
            }
        }
    }

    @available(iOS 15, *)
    private func generateCrashLogPost() {
        logger.log("Generating local log post...")

        DispatchQueue.main.asyncAfter(deadline: .now()) {
            // Unset selected post and collection and navigate to local drafts.
            self.model.selectedPost = nil
            self.model.selectedCollection = nil
            self.model.showAllPosts = false

            // Create the new log post.
            let newLogPost = model.editor.generateNewLocalPost(withFont: 2)
            newLogPost.title = "Logs For Support"
            var postBody: [String] = [
                "WriteFreely-Multiplatform v\(Bundle.main.appMarketingVersion) (\(Bundle.main.appBuildVersion))",
                "Generated \(Date())",
                ""
            ]
            postBody.append(contentsOf: logger.fetchLogs())
            newLogPost.body = postBody.joined(separator: "\n")

            self.model.selectedPost = newLogPost
        }

        logger.log("Generated local log post.")
    }

    private func resetCrashFlags() {
        UserDefaults.shared.set(false, forKey: WFDefaults.didHaveFatalError)
        UserDefaults.shared.removeObject(forKey: WFDefaults.fatalErrorDescription)
    }

    private func didPressCrashAlertButton() {
        resetCrashFlags()
        #if os(macOS)
        NSWorkspace().open(model.helpURL)
        #else
        UIApplication.shared.open(model.helpURL)
        #endif
    }

}
