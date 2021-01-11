import SwiftUI

struct SettingsHeaderView: View {
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
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
                .accessibilityLabel(Text("Close"))
                .accessibilityHint(Text("Dismiss the Settings sheet"))
            }
            Text("WriteFreely v\(Bundle.main.appMarketingVersion) (build \(Bundle.main.appBuildVersion))")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top)
        }
        .padding()
    }
}

struct SettingsHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsHeaderView()
    }
}
