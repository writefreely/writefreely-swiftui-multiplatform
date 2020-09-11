import SwiftUI

struct SettingsHeaderView: View {
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        HStack {
            Text("Settings")
                .font(.largeTitle)
                .fontWeight(.bold)
            Spacer()
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }, label: {
                Image(systemName: "xmark.circle")
            })
        }
        .padding()
    }
}

struct SettingsHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsHeaderView()
    }
}
