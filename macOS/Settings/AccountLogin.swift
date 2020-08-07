//
//  AccountLogin.swift
//  WriteFreely-MultiPlatform
//
//  Created by Angelo Stavrow on 2020-08-07.
//

import SwiftUI

struct AccountLogin: View {
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
                Spacer()
                HStack {
                    Text("Logged in as")
                    Text(accountModel.username ?? "UNKNOWN")
                        .font(.system(.body, design: .monospaced))
                    Text("on")
                    Text(accountModel.server ?? "UNKNOWN")
                        .font(.system(.body, design: .monospaced))
                }
                Spacer()
                Button(action: logoutHandler, label: {
                    Text("Logout")
                })
                Spacer()
            }
        } else {
            Form {
                Section(header: Text("Login to your account")) {
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: "person.circle")
                                .foregroundColor(.gray)
                            TextField("Username", text: $username)
                            Spacer()
                        }
                        HStack {
                            Spacer()
                            Image(systemName: "lock.circle")
                                .foregroundColor(.gray)
                            TextField("Password", text: $password)
                            Spacer()
                        }
                        HStack {
                            Spacer()
                            Image(systemName: "link.circle")
                                .foregroundColor(.gray)
                            TextField("Server URL", text: $server)
                            Spacer()
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
                        Spacer()
                    }
                }
                .padding()
                .alert(isPresented: $isShowingAlert) {
                    Alert(
                        title: Text("Error Logging In"),
                        message: Text(alertMessage),
                        dismissButton: .default(Text("OK"))
                    )
                }
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
        AccountLogin()
    }
}
