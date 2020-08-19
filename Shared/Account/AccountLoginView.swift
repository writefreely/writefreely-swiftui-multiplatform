import SwiftUI

struct AccountLoginView: View {
    @EnvironmentObject var model: WriteFreelyModel

    @State private var isShowingAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var server: String = ""
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "person.circle")
                    .foregroundColor(.gray)
                #if os(iOS)
                TextField("Username", text: $username)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                #else
                TextField("Username", text: $username)
                #endif
            }
            HStack {
                Image(systemName: "lock.circle")
                    .foregroundColor(.gray)
                #if os(iOS)
                SecureField("Password", text: $password)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                #else
                SecureField("Password", text: $password)
                #endif
            }
            HStack {
                Image(systemName: "link.circle")
                    .foregroundColor(.gray)
                #if os(iOS)
                TextField("Server URL", text: $server)
                    .keyboardType(.URL)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                #else
                TextField("Server URL", text: $server)
                #endif
            }
            Spacer()
            if model.isLoggingIn {
                ProgressView("Logging in...")
                    .padding()
            } else {
                Button(action: {
                    model.login(
                        to: URL(string: server)!,
                        as: username, password: password
                    )
                }, label: {
                    Text("Login")
                })
                .disabled(
                    model.account.isLoggedIn || (username.isEmpty || password.isEmpty || server.isEmpty)
                )
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
            isShowingAlert = true
        } catch {
            alertMessage = "An unknown error occurred. Please try again."
            isShowingAlert = true
        }
    }
}

struct AccountLoginView_Previews: PreviewProvider {
    static var previews: some View {
        AccountLoginView()
            .environmentObject(WriteFreelyModel())
    }
}
