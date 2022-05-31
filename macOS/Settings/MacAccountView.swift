import SwiftUI

struct MacAccountView: View {
    @EnvironmentObject var model: WriteFreelyModel
    @EnvironmentObject var errorHandling: ErrorHandling

    var body: some View {
        Form {
            AccountView()
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

struct MacAccountView_Previews: PreviewProvider {
    static var previews: some View {
        MacAccountView()
            .environmentObject(WriteFreelyModel())
    }
}
