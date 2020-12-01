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
                .onAppear(perform: {
                    if let lastDraft = model.editor.fetchLastDraftFromUserDefaults() {
                        self.model.selectedPost = lastDraft
                    } else {
                        createNewLocalPost()
                    }
                })
                .environmentObject(model)
                .environment(\.managedObjectContext, LocalStorageManager.persistentContainer.viewContext)
//                .preferredColorScheme(preferences.selectedColorScheme)    // See PreferencesModel for info.
        }
        .commands {
            CommandGroup(replacing: .newItem, addition: {
                Button("New Post") {
                    createNewLocalPost()
                }
                .keyboardShortcut("n", modifiers: [.command])
            })
            CommandGroup(after: .newItem) {
                Button("Reload From Server") {
                    DispatchQueue.main.async {
                        model.fetchUserCollections()
                        model.fetchUserPosts()
                    }
                }
                .disabled(!model.account.isLoggedIn)
                .keyboardShortcut("r", modifiers: [.command])
            }
            #if os(macOS)
            CommandGroup(after: .sidebar) {
                Button("Toggle Sidebar") {
                    NSApp.keyWindow?.contentViewController?.tryToPerform(
                        #selector(NSSplitViewController.toggleSidebar(_:)), with: nil
                    )
                    withAnimation { self.sidebarIsHidden.toggle() }
                }
                .keyboardShortcut("s", modifiers: [.command, .option])
            }
            #endif
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

    private func createNewLocalPost() {
        withAnimation {
            self.model.selectedPost = nil
        }
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
            self.model.selectedPost = managedPost
        }
    }
}
