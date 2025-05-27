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
    return if authService.authenticationFlow == .login {
      !email.isEmpty && !password.isEmpty
    } else {
      !email.isEmpty && !password.isEmpty && password == confirmPassword
    }
  }

  private func signInWithEmailPassword() async {
    do {
      try await authService.signIn(withEmail: email, password: password)
    } catch {}
  }

  private func createUserWithEmailPassword() async {
    do {
      try await authService.createUser(withEmail: email, password: password)
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

      LabeledContent {
        SecureField(authService.string.passwordInputLabel, text: $password)
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
        Button(action: {
          authService.authView = .passwordRecovery
        }) {
          Text(authService.string.passwordButtonLabel)
        }
      }

      if authService.authenticationFlow == .signUp {
        LabeledContent {
          SecureField(authService.string.confirmPasswordInputLabel, text: $confirmPassword)
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
          Text(authService.authenticationFlow == .login ? authService.string
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
      .padding([.top, .bottom], 8)
      .frame(maxWidth: .infinity)
      .buttonStyle(.borderedProminent)
      Button(action: {
        authService.authView = .emailLink
      }) {
        Text(authService.string.signUpWithEmailLinkButtonLabel)
      }
    }
  }
}

#Preview {
  FirebaseOptions.dummyConfigurationForPreview()
  return EmailAuthView()
    .environment(AuthService())
}
