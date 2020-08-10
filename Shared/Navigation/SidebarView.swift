import SwiftUI

struct SidebarView: View {
    @State var isPresentingSettings = false

    var body: some View {
        #if os(iOS)
        VStack {
            CollectionListView()
            Spacer()
            Button(action: {
                isPresentingSettings = true
            }, label: {
                Text("Settings")
            }).sheet(
                isPresented: $isPresentingSettings,
                onDismiss: {
                    isPresentingSettings = false
                },
                content: {
                    SettingsView(isPresented: $isPresentingSettings)
                }
            )
        }
        #else
        CollectionListView()
        #endif
    }
}

struct SidebarView_Previews: PreviewProvider {
    static var previews: some View {
        SidebarView()
    }
}
