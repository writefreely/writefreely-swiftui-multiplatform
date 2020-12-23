import SwiftUI
import Sparkle

private enum AppcastFeedUrl: String {
    case release = "https://files.writefreely.org/apps/mac/appcast.xml"
    case beta = "https://files.writefreely.org/apps/mac/appcast-beta.xml"
}

struct MacUpdatesView: View {
    @AppStorage("automaticallyChecksForUpdates") var automaticallyChecksForUpdates: Bool = false
    @AppStorage("subscribeToBetaUpdates") var subscribeToBetaUpdates: Bool = false
    @State private var lastUpdateCheck: Date?

    private let betaWarningString = """
To get brand new features before each official release, choose "Test versions." Note that test versions may have bugs \
that can cause crashes and data loss.
"""

    static let lastUpdateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.doesRelativeDateFormatting = true
        return formatter
    }()

    var body: some View {
        VStack(spacing: 24) {
            Toggle(isOn: $automaticallyChecksForUpdates, label: {
                Text("Check for updates automatically")
            })

            VStack {
                Button(action: {
                    SUUpdater.shared()?.checkForUpdates(self)
                    DispatchQueue.main.async {
                        lastUpdateCheck = SUUpdater.shared()?.lastUpdateCheckDate
                    }
                }, label: {
                    Text("Check For Updates")
                })

                HStack {
                    Text("Last checked:")
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

            VStack(spacing: 16) {
                HStack(alignment: .top) {
                    Text("Download:")
                    Picker(selection: $subscribeToBetaUpdates, label: Text("Download:"), content: {
                        Text("Release versions").tag(false)
                        Text("Test versions").tag(true)
                    })
                    .pickerStyle(RadioGroupPickerStyle())
                    .labelsHidden()
                }

                Text(betaWarningString)
                    .frame(width: 350)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .onAppear {
            lastUpdateCheck = SUUpdater.shared()?.lastUpdateCheckDate
        }
        .onChange(of: automaticallyChecksForUpdates) { value in
            SUUpdater.shared()?.automaticallyChecksForUpdates = value
        }
        .onChange(of: subscribeToBetaUpdates) { value in
            if value {
                SUUpdater.shared()?.feedURL = URL(string: AppcastFeedUrl.beta.rawValue)
            } else {
                SUUpdater.shared()?.feedURL = URL(string: AppcastFeedUrl.release.rawValue)
            }
        }
    }
}

struct MacUpdatesView_Previews: PreviewProvider {
    static var previews: some View {
        MacUpdatesView()
    }
}
