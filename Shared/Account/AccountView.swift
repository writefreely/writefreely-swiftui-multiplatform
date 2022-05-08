import SwiftUI

struct AccountView: View {
    @EnvironmentObject var model: WriteFreelyModel
    @EnvironmentObject var errorHandling: ErrorHandling

    var body: some View {
        if model.account.isLoggedIn {
            HStack {
                Spacer()
                AccountLogoutView()
                Spacer()
            }
            .padding()
        } else {
            AccountLoginView()
                .withErrorHandling()
                .padding(.top)
        }
        EmptyView()
            .onChange(of: model.hasError) { value in
                if value {
                    if let error = model.currentError {
                        self.errorHandling.handle(error: error)
                    } else {
                        self.errorHandling.handle(error: AppError.genericError)
                    }
                    model.hasError = false
                }
            }
    }
}

struct AccountLogin_Previews: PreviewProvider {
    static var previews: some View {
        AccountView()
            .environmentObject(WriteFreelyModel())
    }
}
