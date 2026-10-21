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

import FirebaseAuthUIComponents
import SwiftUI

private enum FocusableField: Hashable {
  case email
  case password
  case confirmPassword
}

/// The stock content of ``EmailAuthScreen``.
@MainActor
public struct DefaultEmailAuthContent: View {
  public init(state: EmailAuthContentState) {
    self.state = state
  }

  @Environment(AuthService.self) private var authService
  @FocusState private var focus: FocusableField?
  private let state: EmailAuthContentState

  public var body: some View {
    VStack(spacing: 16) {
      AuthTextField(
        text: state.email,
        label: authService.string.emailFieldLabel,
        prompt: authService.string.emailInputLabel,
        keyboardType: .emailAddress,
        contentType: .emailAddress,
        validations: [
          FormValidators.email,
        ],
        maintainsValidationMessage: state.flow == .signUp,
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
        text: state.password,
        label: authService.string.passwordFieldLabel,
        prompt: authService.string.passwordInputLabel,
        contentType: .password,
        isSecureTextField: true,
        validations: state.flow == .signUp ? [
          FormValidators.atLeast6Characters
        ] : [],
        maintainsValidationMessage: state.flow == .signUp,
        onSubmit: { _ in
          if state.flow == .signIn {
            state.signIn()
          } else {
            focus = .confirmPassword
          }
        },
        leading: {
          Image(systemName: "lock")
        }
      )
      .submitLabel(.go)
      .focused($focus, equals: .password)
      .accessibilityIdentifier("password-field")
      if state.flow == .signIn {
        Button(action: state.goToPasswordRecovery) {
          Text(authService.string.passwordButtonLabel)
            .authCustomFont(.body, weight: .medium)
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .accessibilityIdentifier("password-recovery-button")
      }

      if state.flow == .signUp {
        AuthTextField(
          text: state.confirmPassword,
          label: authService.string.confirmPasswordFieldLabel,
          prompt: authService.string.confirmPasswordInputLabel,
          contentType: .password,
          isSecureTextField: true,
          validations: [
            FormValidators.confirmPassword(password: state.password.wrappedValue),
          ],
          maintainsValidationMessage: true,
          onSubmit: { _ in
            state.signUp()
          },
          leading: {
            Image(systemName: "lock")
          }
        )
        .submitLabel(.go)
        .focused($focus, equals: .confirmPassword)
        .accessibilityIdentifier("confirm-password-field")
      }

      Button {
        if state.flow == .signIn {
          state.signIn()
        } else {
          state.signUp()
        }
      } label: {
        if !state.isLoading {
          Text(
            state.flow == .signIn
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
      .disabled(!state.isValid)
      .padding([.top, .bottom], 8)
      .frame(maxWidth: .infinity)
      .authCTAButtonStyle()
      .accessibilityIdentifier("sign-in-button")
    }
    Button(action: state.switchFlow) {
      HStack(spacing: 4) {
        Text(
          state.flow == .signIn
            ? authService.string.dontHaveAnAccountYetLabel
            : authService.string.alreadyHaveAnAccountLabel
        )
        .authCustomFont(.body)
        .foregroundStyle(Color(.label))
        Text(
          state.flow == .signUp
            ? authService.string.emailLoginFlowLabel
            : authService.string.emailSignUpFlowLabel
        )
        .authCustomFont(.body, weight: .medium)
      }
    }
    .accessibilityIdentifier("switch-auth-flow")
  }
}
