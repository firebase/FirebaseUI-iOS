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

/// The stock content of ``EmailReauthScreen``.
@MainActor
public struct DefaultEmailReauthContent: View {
  public init(state: EmailReauthContentState) {
    self.state = state
  }

  @Environment(AuthService.self) private var authService
  private let state: EmailReauthContentState

  public var body: some View {
    VStack(spacing: 24) {
      // Header
      VStack(spacing: 12) {
        Image(systemName: "lock.circle.fill")
          .font(.system(size: 60))
          .foregroundColor(.blue)

        Text(authService.string.confirmPasswordTitle)
          .authFont(.title)
          .fontWeight(.bold)

        Text(authService.string.forSecurityEnterPasswordMessage)
          .authFont(.body)
          .foregroundColor(.secondary)
          .multilineTextAlignment(.center)
      }
      .padding()

      VStack(spacing: 20) {
        Text(authService.string.emailPrefix(email: state.email))
          .authFont(.caption)
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(.bottom, 8)

        AuthTextField(
          text: state.password,
          label: authService.string.passwordFieldLabel,
          prompt: authService.string.passwordInputLabel,
          contentType: .password,
          isSecureTextField: true,
          onSubmit: { _ in
            state.verify()
          },
          leading: {
            Image(systemName: "lock")
          }
        )
        .submitLabel(.done)
        .accessibilityIdentifier("email-reauth-password-field")

        Button(action: state.verify) {
          if state.isLoading {
            ProgressView()
              .frame(height: 32)
              .frame(maxWidth: .infinity)
          } else {
            Text(authService.string.confirmButtonLabel)
              .frame(height: 32)
              .frame(maxWidth: .infinity)
          }
        }
        .authCTAButtonStyle()
        .disabled(!state.isValid || state.isLoading)
        .accessibilityIdentifier("confirm-password-button")

        Button(authService.string.cancelButtonLabel, action: state.cancel)
      }
      .padding(.horizontal)

      Spacer()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    .navigationBarTitleDisplayMode(.inline)
  }
}
