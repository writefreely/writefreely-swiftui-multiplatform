import SwiftUI

struct AccountView: View {
    @State var accountModel = AccountModel()

    @State private var username: String = ""
    @State private var password: String = ""
    @State private var server: String = ""
    @State private var isLoggingIn: Bool = false
    @State private var isLoggedIn: Bool = false
    @State private var isShowingAlert: Bool = false
    @State private var alertMessage: String = ""

    var body: some View {
        if isLoggedIn {
            VStack {
                HStack {
                    Text("Logged in as \(accountModel.username ?? "UNKNOWN") on \(accountModel.server ?? "UNKNOWN")")
                }
                Spacer()
                Button(action: logoutHandler, label: {
                    Text("Logout")
                })
            }
        } else {
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

    func logoutHandler() {
        isLoggedIn = false
        isLoggingIn = false
    }
}
struct AccountLogin_Previews: PreviewProvider {
    static var previews: some View {
        AccountView()
    }
}
