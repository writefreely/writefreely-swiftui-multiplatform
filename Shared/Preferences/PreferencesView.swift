import SwiftUI

struct PreferencesView: View {
    @State private var appearance: Int = 0

    var body: some View {
        #if os(iOS)
        Picker(selection: $appearance, label: Text("Appearance")) {
            Text("System").tag(0)
            Text("Light Mode").tag(1)
            Text("Dark Mode").tag(2)
        }
        .pickerStyle(SegmentedPickerStyle())
        #elseif os(macOS)
        Picker(selection: $appearance, label: EmptyView()) {
            Text("System").tag(0)
            Text("Light Mode").tag(1)
            Text("Dark Mode").tag(2)
        }
        .pickerStyle(RadioGroupPickerStyle())
        #endif
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesView()
    }
}
