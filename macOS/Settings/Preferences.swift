import SwiftUI

struct Preferences: View {
    @State private var appearance: Int = 0

    var body: some View {
        Form {
            Picker(selection: $appearance, label: Text("Appearance")) {
                Text("System").tag(0)
                Text("Light Mode").tag(1)
                Text("Dark Mode").tag(2)
            }
            .frame(width: 200, height: 100, alignment: .topLeading)
            .pickerStyle(RadioGroupPickerStyle())
        }
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        Preferences()
    }
}
