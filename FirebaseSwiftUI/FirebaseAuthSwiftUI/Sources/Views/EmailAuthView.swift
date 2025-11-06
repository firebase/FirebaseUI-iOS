// Copyright 2025 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//
//  EmailPasswordView.swift
//  FirebaseUI
//
//  Created by Russell Wheatley on 20/03/2025.
//
import FirebaseAuth
import FirebaseAuthUIComponents
import FirebaseCore
import SwiftUI

private enum FocusableField: Hashable {
  case email
  case password
  case confirmPassword
}

@MainActor
public struct EmailAuthView {
  @Environment(AuthService.self) private var authService
  @Environment(\.accountConflictHandler) private var accountConflictHandler
  @Environment(\.reportError) private var reportError

  @State private var email = ""
  @State private var password = ""
  @State private var confirmPassword = ""

  @FocusState private var focus: FocusableField?

  public init() {}

  private var isValid: Bool {
    return if authService.authenticationFlow == .signIn {
      !email.isEmpty && !password.isEmpty
    } else {
      !email.isEmpty && !password.isEmpty && password == confirmPassword
    }
  }

  private func signInWithEmailPassword() async throws {
    do {
      _ = try await authService.signIn(email: email, password: password)
    } catch {
      // 1) Always report first, if a reporter exists
      reportError?(error)

      // 2) If it's a conflict and we have a handler, handle it and stop
      if case let AuthServiceError.accountConflict(ctx) = error,
         let onConflict = accountConflictHandler {
        onConflict(ctx)
        return
      }

      throw error
    }
  }

  private func createUserWithEmailPassword() async throws {
    do {
      _ = try await authService.createUser(email: email, password: password)
    } catch {
      // 1) Always report first, if a reporter exists
      reportError?(error)

      // 2) If it's a conflict and we have a handler, handle it and stop
      if case let AuthServiceError.accountConflict(ctx) = error,
         let onConflict = accountConflictHandler {
        onConflict(ctx)
        return
      }

      throw error
    }
  }
}

extension EmailAuthView: View {
  public var body: some View {
    VStack(spacing: 16) {
      AuthTextField(
        text: $email,
        label: authService.string.emailFieldLabel,
        prompt: authService.string.emailInputLabel,
        keyboardType: .emailAddress,
        contentType: .emailAddress,
        onSubmit: { _ in
          self.focus = .password
        },
        leading: {
          Image(systemName: "at")
        }
      )
      .focused($focus, equals: .email)
      .accessibilityIdentifier("email-field")
      AuthTextField(
        text: $password,
        label: authService.string.passwordFieldLabel,
        prompt: authService.string.passwordInputLabel,
        contentType: .password,
        sensitive: true,
        onSubmit: { _ in
          Task { try await signInWithEmailPassword() }
        },
        leading: {
          Image(systemName: "lock")
        }
      )
      .submitLabel(.go)
      .focused($focus, equals: .password)
      .accessibilityIdentifier("password-field")
      if authService.authenticationFlow == .signIn {
        Button {
          authService.navigator.push(.passwordRecovery)
        } label: {
          Text(authService.string.passwordButtonLabel)
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .accessibilityIdentifier("password-recovery-button")
      }

      if authService.authenticationFlow == .signUp {
        AuthTextField(
          text: $confirmPassword,
          label: authService.string.confirmPasswordFieldLabel,
          prompt: authService.string.confirmPasswordInputLabel,
          contentType: .password,
          sensitive: true,
          onSubmit: { _ in
            Task { try await createUserWithEmailPassword() }
          },
          leading: {
            Image(systemName: "lock")
          }
        )
        .submitLabel(.go)
        .focused($focus, equals: .confirmPassword)
        .accessibilityIdentifier("confirm-password-field")
      }

      Button(action: {
        Task {
          if authService.authenticationFlow == .signIn {
            try await signInWithEmailPassword()
          } else {
            try await createUserWithEmailPassword()
          }
        }
      }) {
        if authService.authenticationState != .authenticating {
          Text(
            authService.authenticationFlow == .signIn
              ? authService.string.signInWithEmailButtonLabel
              : authService.string.signUpWithEmailButtonLabel
          )
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
      .accessibilityIdentifier("sign-in-button")
    }
    Button(action: {
      withAnimation {
        authService.authenticationFlow =
          authService
            .authenticationFlow == .signIn ? .signUp : .signIn
      }
    }) {
      HStack(spacing: 4) {
        Text(
          authService
            .authenticationFlow == .signIn
            ? authService.string.dontHaveAnAccountYetLabel
            : authService.string.alreadyHaveAnAccountLabel
        )
        .foregroundStyle(Color(.label))
        Text(
          authService.authenticationFlow == .signUp
            ? authService.string.emailLoginFlowLabel
            : authService.string.emailSignUpFlowLabel
        )
        .fontWeight(.semibold)
        .foregroundColor(.blue)
      }
    }
    .accessibilityIdentifier("switch-auth-flow")
  }
}

#Preview {
  FirebaseOptions.dummyConfigurationForPreview()
  return EmailAuthView()
    .environment(AuthService())
}
