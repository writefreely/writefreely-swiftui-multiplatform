import SwiftUI

struct AccountLoginView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var server: String = ""
    @State private var isShowingAlert: Bool = false
    @State private var alertMessage: String = ""

    @Binding var accountModel: AccountModel
    @Binding var isLoggedIn: Bool
    @Binding var isLoggingIn: Bool

    var body: some View {
        VStack {
            HStack {
                Image(systemName: "person.circle")
                    .foregroundColor(.gray)
                TextField("Username", text: $username)
            }
            HStack {
                Image(systemName: "lock.circle")
                    .foregroundColor(.gray)
                SecureField("Password", text: $password)
            }
            HStack {
                Image(systemName: "link.circle")
                    .foregroundColor(.gray)
                TextField("Server URL", text: $server)
            }
            Spacer()
            if isLoggingIn {
                ProgressView("Logging in...")
            } else {
                Button(action: {
                    accountModel.login(
                        to: server,
                        as: username, password: password,
                        completion: loginHandler
                    )
                    isLoggingIn = true
                }, label: {
                    Text("Login")
                }).disabled(isLoggedIn)
            }
        }
        .alert(isPresented: $isShowingAlert) {
            Alert(
                title: Text("Error Logging In"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    func loginHandler(result: Result<UUID, AccountError>) {
        do {
            _ = try result.get()
            isLoggedIn = true
            isLoggingIn = false
        } catch AccountError.serverNotFound {
            alertMessage = """
The server could not be found. Please check that you've entered the information correctly and try again.
"""
            isLoggedIn = false
            isLoggingIn = false
            isShowingAlert = true
        } catch AccountError.invalidCredentials {
            alertMessage = """
            Invalid username or password. Please check that you've entered the information correctly and try again.
            """
            isLoggedIn = false
            isLoggingIn = false
            isShowingAlert = true
        } catch {
            alertMessage = "An unknown error occurred. Please try again."
            isLoggedIn = false
            isLoggingIn = false
            isShowingAlert = true
        }
    }
}

struct AccountLoginView_LoggedOutPreviews: PreviewProvider {
    static var previews: some View {
        AccountLoginView(
            accountModel: .constant(AccountModel()),
            isLoggedIn: .constant(false),
            isLoggingIn: .constant(false)
        )
    }
}

struct AccountLoginView_LoggingInPreviews: PreviewProvider {
    static var previews: some View {
        AccountLoginView(
            accountModel: .constant(AccountModel()),
            isLoggedIn: .constant(false),
            isLoggingIn: .constant(true)
        )
    }
}
