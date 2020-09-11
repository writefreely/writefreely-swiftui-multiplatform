import SwiftUI

struct ContentView: View {
    @EnvironmentObject var model: WriteFreelyModel

    var body: some View {
        NavigationView {
            SidebarView()

            PostListView(selectedCollection: nil, showAllPosts: true)

            Text("Select a post, or create a new local draft.")
                .foregroundColor(.secondary)
        }
        .environmentObject(model)

        #if os(iOS)
        EmptyView()
            .sheet(
                isPresented: $model.isPresentingSettingsView,
                onDismiss: { model.isPresentingSettingsView = false },
                content: {
                    SettingsView()
                        .environmentObject(model)
                }
            )
        #endif
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let context = LocalStorageManager.persistentContainer.viewContext
        let model = WriteFreelyModel()

        return ContentView()
            .environment(\.managedObjectContext, context)
            .environmentObject(model)
    }
}
