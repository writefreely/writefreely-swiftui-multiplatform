import SwiftUI
import Sparkle

struct MacUpdatesView: View {
    @EnvironmentObject var model: WriteFreelyModel
    @EnvironmentObject var errorHandling: ErrorHandling

    @ObservedObject var updaterViewModel: MacUpdatesViewModel

    @AppStorage(WFDefaults.automaticallyChecksForUpdates, store: UserDefaults.shared)
    var automaticallyChecksForUpdates: Bool = false
    @AppStorage(WFDefaults.subscribeToBetaUpdates, store: UserDefaults.shared)
    var subscribeToBetaUpdates: Bool = false

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
                    updaterViewModel.checkForUpdates()
                    // There's a delay between requesting an update, and the timestamp for that update request being
                    // written to user defaults; we therefore delay updating the "Last checked" UI for one second.
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        lastUpdateCheck = updaterViewModel.getLastUpdateCheckDate()
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
            lastUpdateCheck = updaterViewModel.getLastUpdateCheckDate()
        }
        .onChange(of: automaticallyChecksForUpdates) { value in
            updaterViewModel.automaticallyCheckForUpdates = value
        }
        .onChange(of: subscribeToBetaUpdates) { _ in
            updaterViewModel.toggleAllowedChannels()
        }
        .onChange(of: model.hasError) { value in
            if value {
                if let error = model.currentError {
                    self.errorHandling.handle(error: error)
                } else {
                    self.errorHandling.handle(error: AppError.genericError())
                }
                model.hasError = false
            }
        }
    }
}

struct MacUpdatesView_Previews: PreviewProvider {
    static var previews: some View {
        MacUpdatesView(updaterViewModel: MacUpdatesViewModel())
    }
}
