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

  private func signInWithEmailPassword() async {
    do {
      try await authService.signIn(email: email, password: password)
    } catch {}
  }

  private func createUserWithEmailPassword() async {
    do {
      try await authService.createUser(email: email, password: password)
    } catch {}
  }
}

extension EmailAuthView: View {
  public var body: some View {
    VStack {
      LabeledContent {
        TextField(authService.string.emailInputLabel, text: $email)
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
      .accessibilityIdentifier("email-field")

      LabeledContent {
        SecureField(authService.string.passwordInputLabel, text: $password)
          .focused($focus, equals: .password)
          .textInputAutocapitalization(.never)
          .disableAutocorrection(true)
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
      .accessibilityIdentifier("password-field")

      if authService.authenticationFlow == .signIn {
        Button(action: {
          authService.authView = .passwordRecovery
        }) {
          Text(authService.string.passwordButtonLabel)
        }.accessibilityIdentifier("password-recovery-button")
      }

      if authService.authenticationFlow == .signUp {
        LabeledContent {
          SecureField(authService.string.confirmPasswordInputLabel, text: $confirmPassword)
            .focused($focus, equals: .confirmPassword)
            .textInputAutocapitalization(.never)
            .disableAutocorrection(true)
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
        .accessibilityIdentifier("confirm-password-field")
      }

      Button(action: {
        Task {
          if authService.authenticationFlow == .signIn { await signInWithEmailPassword() }
          else { await createUserWithEmailPassword() }
        }
      }) {
        if authService.authenticationState != .authenticating {
          Text(authService.authenticationFlow == .signIn ? authService.string
            .signInWithEmailButtonLabel : authService.string.signUpWithEmailButtonLabel)
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
      .padding([.top, .bottom, .horizontal], 8)
      .frame(maxWidth: .infinity)
      .buttonStyle(.borderedProminent)
      .accessibilityIdentifier("sign-in-button")
      Button(action: {
        authService.authView = .emailLink
      }) {
        Text(authService.string.signUpWithEmailLinkButtonLabel)
      }.accessibilityIdentifier("sign-in-with-email-link-button")
    }
  }
}

#Preview {
  FirebaseOptions.dummyConfigurationForPreview()
  return EmailAuthView()
    .environment(AuthService())
}
