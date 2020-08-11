import SwiftUI

struct PreferencesView: View {
    @ObservedObject var preferences: PreferencesModel

    var body: some View {
        #if os(iOS)
        Picker(selection: $preferences.appearance, label: Text("Appearance")) {
            Text("System").tag(0)
            Text("Light").tag(1)
            Text("Dark").tag(2)
        }
        .pickerStyle(SegmentedPickerStyle())
        #elseif os(macOS)
        Picker(selection: $preferences.appearance, label: Text("Appearance")) {
            Text("System").tag(0)
            Text("Light").tag(1)
            Text("Dark").tag(2)
        }
        #endif
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesView(preferences: PreferencesModel())
    }
}
