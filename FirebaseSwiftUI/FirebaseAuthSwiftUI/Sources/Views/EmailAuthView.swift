//
//  EmailPasswordView.swift
//  FirebaseUI
//
//  Created by Russell Wheatley on 20/03/2025.
//
import SwiftUI

private enum FocusableField: Hashable {
  case email
  case password
  case confirmPassword
}

@MainActor
public struct EmailAuthView {
  @Environment(AuthService.self) private var authService

  @State private var email = ""
  @State private var password = ""
  @State private var confirmPassword = ""
  @State private var errorMessage = ""

  @FocusState private var focus: FocusableField?

  public init() {}

  private var isValid: Bool {
    return if authService.authenticationFlow == .login {
      !email.isEmpty && !password.isEmpty
    } else {
      !email.isEmpty && !password.isEmpty && password == confirmPassword
    }
  }

  private func signInWithEmailPassword() async {
    do {
      try await authService.signIn(withEmail: email, password: password)
    } catch {
      errorMessage = StringUtils.localizedErrorMessage(
        for: error,
        configuration: authService.configuration
      )
    }
  }

  private func createUserWithEmailPassword() async {
    do {
      try await authService.createUser(withEmail: email, password: password)
    } catch {
      errorMessage = StringUtils.localizedErrorMessage(
        for: error,
        configuration: authService.configuration
      )
    }
  }
}

extension EmailAuthView: View {
  public var body: some View {
    VStack {
      LabeledContent {
        TextField("Email", text: $email)
          .textInputAutocapitalization(.never)
          .disableAutocorrection(true)
          .focused($focus, equals: .email)
          .submitLabel(.next)
          .onSubmit {
            self.focus = .password
          }
      } label: {
        Image(systemName: "at")
      }
      .padding(.vertical, 6)
      .background(Divider(), alignment: .bottom)
      .padding(.bottom, 4)

      LabeledContent {
        SecureField("Password", text: $password)
          .focused($focus, equals: .password)
          .submitLabel(.go)
          .onSubmit {
            Task { await signInWithEmailPassword() }
          }
      } label: {
        Image(systemName: "lock")
      }
      .padding(.vertical, 6)
      .background(Divider(), alignment: .bottom)
      .padding(.bottom, 8)

      if authService.authenticationFlow == .login {
        NavigationLink(destination: PasswordRecoveryView()
          .environment(authService)) {
            Text("Forgotten Password?")
          }
      }

      if authService.authenticationFlow == .signUp {
        LabeledContent {
          SecureField("Confirm password", text: $confirmPassword)
            .focused($focus, equals: .confirmPassword)
            .submitLabel(.go)
            .onSubmit {
              Task { await createUserWithEmailPassword() }
            }
        } label: {
          Image(systemName: "lock")
        }
        .padding(.vertical, 6)
        .background(Divider(), alignment: .bottom)
        .padding(.bottom, 8)
      }

      Button(action: {
        Task {
          if authService.authenticationFlow == .login { await signInWithEmailPassword() }
          else { await createUserWithEmailPassword() }
        }
      }) {
        if authService.authenticationState != .authenticating {
          Text(authService.authenticationFlow == .login ? "Log in with password" : "Sign up")
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
        } else {
          ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: .white))
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
        }
      }
      .disabled(!isValid)
      .padding([.top, .bottom], 8)
      .frame(maxWidth: .infinity)
      .buttonStyle(.borderedProminent)
      NavigationLink(destination: EmailLinkView().environment(authService)
        .environment(authService)) {
          Text("Prefer Email link sign-in?")
        }
      Text(errorMessage).foregroundColor(.red)
    }
  }
}
