import SwiftUI

struct SettingsHeaderView: View {
    @Binding var isPresented: Bool

    var body: some View {
        HStack {
            Text("Settings")
                .font(.largeTitle)
                .fontWeight(.bold)
            Spacer()
            Button(action: {
                isPresented = false
            }, label: {
                Image(systemName: "xmark.circle")
            })
        }
        .padding()
    }
}

struct SettingsHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsHeaderView(isPresented: .constant(true))
    }
}
