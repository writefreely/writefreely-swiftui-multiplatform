import SwiftUI

struct SidebarView: View {
    var body: some View {
        CollectionListView()
    }
}

struct SidebarView_Previews: PreviewProvider {
    static var previews: some View {
        let context = LocalStorageManager.persistentContainer.viewContext
        let model = WriteFreelyModel()

        return SidebarView()
            .environment(\.managedObjectContext, context)
            .environmentObject(model)
    }
}
