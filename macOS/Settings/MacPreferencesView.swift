import SwiftUI

struct MacPreferencesView: View {
    @EnvironmentObject var model: WriteFreelyModel
    @EnvironmentObject var errorHandling: ErrorHandling

    @ObservedObject var preferences: PreferencesModel

    var body: some View {
        VStack {
            PreferencesView(preferences: preferences)
            Spacer()
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

struct MacPreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        MacPreferencesView(preferences: PreferencesModel())
    }
}
