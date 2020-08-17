import SwiftUI

struct MacPreferencesView: View {
    @ObservedObject var preferences: PreferencesModel

    var body: some View {
        VStack {
            PreferencesView(preferences: preferences)
            Spacer()
        }
    }
}

struct MacPreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        MacPreferencesView(preferences: PreferencesModel())
    }
}
