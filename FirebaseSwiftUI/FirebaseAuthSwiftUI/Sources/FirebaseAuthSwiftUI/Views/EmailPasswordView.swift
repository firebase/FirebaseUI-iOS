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
public struct EmailPasswordView {
  @Environment(AuthEnvironment.self) private var authEnvironment
  @Environment(\.dismiss) private var dismiss

  @State private var provider: EmailAuthProvider

  @State private var email = ""
  @State private var password = ""
  @State private var confirmPassword = ""

  @FocusState private var focus: FocusableField?

  public init(provider: EmailAuthProvider) {
    self.provider = provider
  }

  private var isValid: Bool {
    return if authEnvironment.authenticationFlow == .login {
      !email.isEmpty && !password.isEmpty
    } else {
      !email.isEmpty && !password.isEmpty && password == confirmPassword
    }
  }

  private func signInWithEmailPassword() async {
    do {
      try await provider.signIn(withEmail: email, password: password)
      dismiss()
    } catch {
      authEnvironment.errorMessage = error.localizedDescription
    }
  }

  private func signUpWithEmailPassword() async {
    do {
      try await provider.signUp(withEmail: email, password: password)
      dismiss()
    } catch {
      authEnvironment.errorMessage = error.localizedDescription
    }
  }
}

extension EmailPasswordView: View {
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

      if authEnvironment.authenticationFlow == .login {
        Button("Forgot password?") {}
          .frame(maxWidth: .infinity, alignment: .trailing)
      }

      if authEnvironment.authenticationFlow == .signUp {
        LabeledContent {
          SecureField("Confirm password", text: $confirmPassword)
            .focused($focus, equals: .confirmPassword)
            .submitLabel(.go)
            .onSubmit {
              Task { await signUpWithEmailPassword() }
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
          if authEnvironment.authenticationFlow == .login { await signInWithEmailPassword() }
          else { await signUpWithEmailPassword() }
        }
      }) {
        if authEnvironment.authenticationState != .authenticating {
          Text(authEnvironment.authenticationFlow == .login ? "Log in with password" : "Sign up")
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
    }
  }
}
