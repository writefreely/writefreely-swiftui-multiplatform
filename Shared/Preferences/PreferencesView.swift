import SwiftUI

struct PreferencesView: View {
    @ObservedObject var preferences: PreferencesModel

    var body: some View {
        VStack {
            VStack {
                Text("Choose the preferred appearance for the app.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Picker(selection: $preferences.appearance, label: Text("Appearance")) {
                    Text("System").tag(0)
                    Text("Light").tag(1)
                    Text("Dark").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            .padding(.bottom)

            VStack {
                Text("Choose the default font for new posts.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Picker(selection: $preferences.font, label: Text("Default Font")) {
                    Text("Serif").tag(0)
                    Text("Sans-Serif").tag(1)
                    Text("Monospace").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.bottom)
                switch preferences.font {
                case 1:
                    Text("Sample Text")
                        .frame(width: 240, height: 50, alignment: .center)
                        .font(.custom("OpenSans-Regular", size: 20))
                case 2:
                    Text("Sample Text")
                        .frame(width: 240, height: 50, alignment: .center)
                        .font(.custom("Hack-Regular", size: 20))
                default:
                    Text("Sample Text")
                        .frame(width: 240, height: 50, alignment: .center)
                        .font(.custom("Lora", size: 20))
                }
            }
            .padding(.bottom)
        }
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesView(preferences: PreferencesModel())
    }
}
