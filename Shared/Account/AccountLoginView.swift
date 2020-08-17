import SwiftUI

struct AccountLoginView: View {
    @ObservedObject var account: AccountModel

    @State private var isShowingAlert: Bool = false
    @State private var alertMessage: String = ""

    var body: some View {
        VStack {
            HStack {
                Image(systemName: "person.circle")
                    .foregroundColor(.gray)
                #if os(iOS)
                TextField("Username", text: $account.username)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                #else
                TextField("Username", text: $account.username)
                #endif
            }
            HStack {
                Image(systemName: "lock.circle")
                    .foregroundColor(.gray)
                #if os(iOS)
                SecureField("Password", text: $account.password)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                #else
                SecureField("Password", text: $account.password)
                #endif
            }
            HStack {
                Image(systemName: "link.circle")
                    .foregroundColor(.gray)
                #if os(iOS)
                TextField("Server URL", text: $account.server)
                    .keyboardType(.URL)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                #else
                TextField("Server URL", text: $account.server)
                #endif
            }
            Spacer()
            if account.isLoggingIn {
                ProgressView("Logging in...")
                    .padding()
            } else {
                Button(action: {
                    account.login(
                        to: account.server,
                        as: account.username, password: account.password,
                        completion: loginHandler
                    )
                }, label: {
                    Text("Login")
                })
                .disabled(account.isLoggedIn)
                .padding()
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
        } catch AccountError.serverNotFound {
            alertMessage = """
The server could not be found. Please check that you've entered the information correctly and try again.
"""
            isShowingAlert = true
        } catch AccountError.invalidPassword {
            alertMessage = """
            Invalid password. Please check that you've entered your password correctly and try logging in again.
            """
            isShowingAlert = true
        } catch AccountError.usernameNotFound {
            alertMessage = """
            Username not found. Did you use your email address by mistake?
            """
        } catch {
            alertMessage = "An unknown error occurred. Please try again."
            isShowingAlert = true
        }
    }
}

struct AccountLoginView_LoggedOutPreviews: PreviewProvider {
    static var previews: some View {
        AccountLoginView(account: AccountModel())
    }
}

struct AccountLoginView_LoggingInPreviews: PreviewProvider {
    static var previews: some View {
        AccountLoginView(account: AccountModel())
    }
}
