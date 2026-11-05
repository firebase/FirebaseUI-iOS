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

/// The stock content of ``PhoneReauthScreen``.
@MainActor
public struct DefaultPhoneReauthContent: View {
  public init(state: PhoneReauthContentState) {
    self.state = state
  }

  @Environment(AuthService.self) private var authService
  private let state: PhoneReauthContentState

  public var body: some View {
    VStack(spacing: 24) {
      // Header
      VStack(spacing: 12) {
        Image(systemName: "phone.circle.fill")
          .font(.system(size: 60))
          .foregroundColor(.blue)

        Text(authService.string.verifyPhoneNumberTitle)
          .authFont(.title)
          .fontWeight(.bold)

        Text(authService.string.forSecurityVerifyPhoneMessage)
          .authFont(.body)
          .foregroundColor(.secondary)
          .multilineTextAlignment(.center)
      }
      .padding()

      if !state.codeSent {
        // Initial state - sending SMS
        VStack(spacing: 20) {
          Text(authService.string.sendVerificationCodeToPhonePrefix)
            .authFont(.subheadline)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)

          Text(state.phoneNumber)
            .authFont(.headline)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 8)

          Button(action: state.sendCode) {
            if state.isLoading {
              ProgressView()
                .frame(height: 32)
                .frame(maxWidth: .infinity)
            } else {
              Text(authService.string.sendVerificationCodeButtonLabel)
                .frame(height: 32)
                .frame(maxWidth: .infinity)
            }
          }
          .authCTAButtonStyle()
          .disabled(state.isLoading)
          .accessibilityIdentifier("send-verification-code-button")
          Button(authService.string.cancelButtonLabel, action: state.cancel)
        }
        .padding(.horizontal)
      } else {
        // Enter verification code
        VStack(spacing: 20) {
          Text(authService.string.enterSixDigitCodeSentToPrefix)
            .authFont(.subheadline)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)

          Text(state.phoneNumber)
            .authFont(.caption)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 8)

          VerificationCodeInputField(
            code: state.verificationCode,
            validations: [
              FormValidators.verificationCode,
            ],
            maintainsValidationMessage: true
          )
          .accessibilityIdentifier("verification-code-field")

          Button(action: state.verify) {
            if state.isLoading {
              ProgressView()
                .frame(height: 32)
                .frame(maxWidth: .infinity)
            } else {
              Text(authService.string.verifyButtonLabel)
                .frame(height: 32)
                .frame(maxWidth: .infinity)
            }
          }
          .authCTAButtonStyle()
          .disabled(!state.isValid || state.isLoading)
          .accessibilityIdentifier("verify-button")

          Button(action: state.sendCode) {
            Text("Resend Code")
              .frame(height: 32)
              .frame(maxWidth: .infinity)
          }
          .buttonStyle(.bordered)
          .disabled(state.isLoading)
          .accessibilityIdentifier("resend-code-button")

          Button(authService.string.cancelButtonLabel, action: state.cancel)
        }
        .padding(.horizontal)
      }

      Spacer()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    .navigationBarTitleDisplayMode(.inline)
  }
}
