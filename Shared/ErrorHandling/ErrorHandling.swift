// Based on https://www.ralfebert.com/swiftui/generic-error-handling/

import SwiftUI

struct ErrorAlert: Identifiable {
    var id = UUID()
    var message: String
    var dismissAction: (() -> Void)?
}

class ErrorHandling: ObservableObject {
    @Published var currentAlert: ErrorAlert?

    func handle(error: Error) {
        currentAlert = ErrorAlert(message: error.localizedDescription)
    }
}

struct HandleErrorByShowingAlertViewModifier: ViewModifier {
    @StateObject var errorHandling = ErrorHandling()

    func body(content: Content) -> some View {
        content
            .environmentObject(errorHandling)
            .background(
                EmptyView()
                    .alert(item: $errorHandling.currentAlert) { currentAlert in
                        Alert(title: Text("Error"),
                              message: Text(currentAlert.message),
                              dismissButton: .default(Text("OK")) {
                            currentAlert.dismissAction?()
                        })
                    }
            )
    }
}

extension View {
    func withErrorHandling() -> some View {
        modifier(HandleErrorByShowingAlertViewModifier())
    }
}
