import SwiftUI

struct AccountLoginView: View {
    @EnvironmentObject var model: WriteFreelyModel

    @State private var alertMessage: String = ""
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var server: String = ""
    var body: some View {
        VStack {
            Text("Log in to publish and share your posts.")
                .font(.caption)
                .foregroundColor(.secondary)
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
                    #if os(iOS)
                    hideKeyboard()
                    #endif
                    // If logging in to Write.as, trim any path in the hostname.
                    if server.hasPrefix("https://write.as") ||
                        server.hasPrefix("http://write.as") ||
                        server.hasPrefix("write.as") {
                        server = "https://write.as"
                    }
                    // Trim any trailing slashes that would cause the request to fail.
                    if server.hasSuffix("/") {
                        server = String(server.dropLast(1))
                    }
                    model.login(
                        to: URL(string: server)!,
                        as: username, password: password
                    )
                }, label: {
                    Text("Log In")
                })
                .disabled(
                    model.account.isLoggedIn || (username.isEmpty || password.isEmpty || server.isEmpty)
                )
                .padding()
            }
        }
        .alert(isPresented: $model.isPresentingLoginErrorAlert) {
            Alert(
                title: Text("Error Logging In"),
                message: Text(model.loginErrorMessage ?? "An unknown error occurred while trying to login."),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

struct AccountLoginView_Previews: PreviewProvider {
    static var previews: some View {
        AccountLoginView()
            .environmentObject(WriteFreelyModel())
    }
}
