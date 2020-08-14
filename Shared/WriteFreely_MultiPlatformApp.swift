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
    }
}
