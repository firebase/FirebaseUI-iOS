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
    Text("EmailPasswordView")
  }
}
