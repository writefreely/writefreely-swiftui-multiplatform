import SwiftUI

struct SidebarView: View {
    @State var isPresentingSettings = false

    var body: some View {
        CollectionListView()
    }
}

struct SidebarView_Previews: PreviewProvider {
    static var previews: some View {
        SidebarView()
    }
}
