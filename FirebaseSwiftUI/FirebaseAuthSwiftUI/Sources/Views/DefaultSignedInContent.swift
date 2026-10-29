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

import SwiftUI

/// The stock signed-in screen, the default content of ``AuthPickerView/signedInContent(_:)``.
/// Wrap it to keep the stock markup.
@MainActor
public struct DefaultSignedInContent: View {
  public init(state: SignedInContentState) {
    self.state = state
  }

  @Environment(AuthService.self) private var authService
  private let state: SignedInContentState

  public var body: some View {
    VStack {
      Text(authService.string.signedInTitle)
        .authFont(.largeTitle)
        .fontWeight(.bold)
        .padding()
        .accessibilityIdentifier("signed-in-text")
      Text(
        "\(state.user?.email ?? state.user?.displayName ?? state.user?.phoneNumber ?? "")"
      )
      .authCustomFont(.body)
      if !state.isEmailVerified {
        Button(action: state.verifyEmail) {
          Text(authService.string.sendEmailVerificationButtonLabel)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
        }
        .authCTAButtonStyle()
        .padding([.top, .bottom], 8)
        .frame(maxWidth: .infinity)
        .accessibilityIdentifier("verify-email-button")
      }
      Button(action: state.updatePassword) {
        Text(authService.string.updatePasswordButtonLabel)
          .padding(.vertical, 8)
          .frame(maxWidth: .infinity)
      }
      .authCTAButtonStyle()
      .padding([.top, .bottom], 8)
      .frame(maxWidth: .infinity)
      .accessibilityIdentifier("update-password-button")

      if state.isMFAEnabled {
        Button(action: state.goToMFAManagement) {
          Text(authService.string.manageTwoFactorAuthenticationLabel)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
        }
        .authCTAButtonStyle()
        .padding([.top, .bottom], 8)
        .frame(maxWidth: .infinity)
        .accessibilityIdentifier("mfa-management-button")
      }

      Button(action: state.deleteAccount) {
        Text(authService.string.deleteAccountButtonLabel)
          .padding(.vertical, 8)
          .frame(maxWidth: .infinity)
      }
      .authCTAButtonStyle()
      .padding([.top, .bottom], 8)
      .frame(maxWidth: .infinity)
      .accessibilityIdentifier("delete-account-button")

      Button(action: state.signOut) {
        Text(authService.string.signOutButtonLabel)
          .padding(.vertical, 8)
          .frame(maxWidth: .infinity)
      }
      .authCTAButtonStyle()
      .padding([.top, .bottom], 8)
      .frame(maxWidth: .infinity)
      .accessibilityIdentifier("sign-out-button")
    }
    .safeAreaPadding()
  }
}
