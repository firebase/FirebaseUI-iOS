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

/// The stock content of ``EnterVerificationCodeScreen``.
@MainActor
public struct DefaultEnterVerificationCodeContent: View {
  public init(state: VerificationCodeContentState) {
    self.state = state
  }

  @Environment(AuthService.self) private var authService
  private let state: VerificationCodeContentState

  public var body: some View {
    VStack(spacing: 32) {
      VStack(spacing: 16) {
        VStack(spacing: 8) {
          Text(authService.string.sentCodeMessage(phoneNumber: state.fullPhoneNumber))
            .authFont(.subheadline)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, alignment: .leading)

          Button(action: state.changeNumber) {
            Text(authService.string.changeNumberButtonLabel)
              .authFont(.caption)
              .frame(maxWidth: .infinity, alignment: .leading)
          }
        }
        .padding(.bottom)
        .frame(maxWidth: .infinity, alignment: .leading)

        VerificationCodeInputField(
          code: state.verificationCode,
          validations: [
            FormValidators.verificationCode,
          ],
          maintainsValidationMessage: true
        )

        Button(action: state.verify) {
          if state.isLoading {
            ProgressView()
              .frame(height: 32)
              .frame(maxWidth: .infinity)
          } else {
            Text(authService.string.verifyAndSignInButtonLabel)
              .frame(height: 32)
              .frame(maxWidth: .infinity)
          }
        }
        .authCTAButtonStyle()
        .disabled(state.isLoading || !state.isValid)

        Button(action: state.resendCode) {
          Text(resendLabel)
            .authFont(.body)
            .frame(maxWidth: .infinity)
        }
        .disabled(state.isLoading || state.resendCountdown > 0)
        .accessibilityIdentifier("resend-code-button")
      }

      Spacer()
    }
    .navigationTitle(authService.string.enterVerificationCodeTitle)
    .navigationBarTitleDisplayMode(.large)
    .padding(.horizontal)
  }

  private var resendLabel: String {
    guard state.resendCountdown > 0 else { return authService.string.resendCodeLabel }
    let remaining = Duration.seconds(state.resendCountdown)
      .formatted(.time(pattern: .minuteSecond))
    return "\(authService.string.resendCodeLabel) (\(remaining))"
  }
}
