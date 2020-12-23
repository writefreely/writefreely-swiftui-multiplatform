import SwiftUI
import Sparkle

struct MacUpdatesView: View {
    @AppStorage("downloadUpdatesAutomatically") var downloadUpdatesAutomatically: Bool = false
    @AppStorage("subscribeToBetaUpdates") var subscribeToBetaUpdates: Bool = false
    @State private var lastUpdateCheck: Date?

    private let betaWarningString = """
Choose release versions to update to the next stable version of WriteFreely. \
Test versions may have bugs that can cause crashes and data loss.
"""

    static let lastUpdateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.doesRelativeDateFormatting = true
        return formatter
    }()

    var body: some View {
        VStack(spacing: 32) {
            VStack {
                Text(betaWarningString)
                    .frame(width: 400)
                    .foregroundColor(Color(NSColor.placeholderTextColor))

                Picker(selection: $subscribeToBetaUpdates, label: Text("Download:"), content: {
                    Text("Release versions").tag(false)
                    Text("Test versions").tag(true)
                })
                .pickerStyle(RadioGroupPickerStyle())
            }

            Button(action: {
                SUUpdater.shared()?.checkForUpdates(self)
                DispatchQueue.main.async {
                    lastUpdateCheck = SUUpdater.shared()?.lastUpdateCheckDate
                }
            }, label: {
                Text("Check For Updates")
            })

            VStack {
                Toggle(isOn: $downloadUpdatesAutomatically, label: {
                    Text("Check for updates automatically")
                })

            HStack {
                Text("Last check for updates:")
                    .font(.caption)
                if let lastUpdateCheck = lastUpdateCheck {
                    Text(lastUpdateCheck, formatter: Self.lastUpdateFormatter)
                        .font(.caption)
                } else {
                    Text("Never")
                        .font(.caption)
                }
            }
            }
        }
        .padding()
        .onAppear {
            lastUpdateCheck = SUUpdater.shared()?.lastUpdateCheckDate
        }
    }
}

struct MacUpdatesView_Previews: PreviewProvider {
    static var previews: some View {
        MacUpdatesView()
    }
}
