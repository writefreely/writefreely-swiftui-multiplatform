import SwiftUI

struct SidebarView: View {
    var body: some View {
        CollectionListView()
    }
}

struct SidebarView_Previews: PreviewProvider {
    static var previews: some View {
        let model = WriteFreelyModel()
        model.collections = CollectionListModel(with: [userCollection1, userCollection2, userCollection3])
        return SidebarView()
            .environmentObject(model)
    }
}
