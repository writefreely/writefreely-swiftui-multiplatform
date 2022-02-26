import SwiftUI

struct AccountLoginView: View {
    @EnvironmentObject var model: WriteFreelyModel
    @EnvironmentObject var errorHandling: ErrorHandling

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
                    // If the server string is not prefixed with a scheme, prepend "https://" to it.
                    if !(server.hasPrefix("https://") || server.hasPrefix("http://")) {
                        server = "https://\(server)"
                    }
                    // We only need the protocol and host from the URL, so drop anything else.
                    let url = URLComponents(string: server)
                    if let validURL = url {
                        let scheme = validURL.scheme
                        let host = validURL.host
                        var hostURL = URLComponents()
                        hostURL.scheme = scheme
                        hostURL.host = host
                        server = hostURL.string ?? server
                        model.login(
                            to: URL(string: server)!,
                            as: username, password: password
                        )
                    } else {
                        self.errorHandling.handle(error: AccountError.invalidServerURL)
                    }
                }, label: {
                    Text("Log In")
                })
                .disabled(
                    model.account.isLoggedIn || (username.isEmpty || password.isEmpty || server.isEmpty)
                )
                .padding()
            }
        }
        .onChange(of: model.shouldHandleError) { _ in
            guard let error = model.currentError else { return }
            self.errorHandling.handle(error: error)
            model.currentError = nil
        }
    }
}

struct AccountLoginView_Previews: PreviewProvider {
    static var previews: some View {
        AccountLoginView()
            .environmentObject(WriteFreelyModel())
    }
}
