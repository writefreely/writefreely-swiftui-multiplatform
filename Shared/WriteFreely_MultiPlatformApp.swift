import SwiftUI

@main
struct WriteFreely_MultiPlatformApp: App {
    @StateObject private var store = PostStore()
    var body: some Scene {
        WindowGroup {
            ContentView(postStore: store)
        }
    }
}
