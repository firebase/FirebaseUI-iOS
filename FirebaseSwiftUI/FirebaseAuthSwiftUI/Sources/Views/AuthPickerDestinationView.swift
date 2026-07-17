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

/// The default content shown for each destination pushed inside the ``AuthPickerView`` sheet
/// (password recovery, email link, MFA, phone verification, etc.).
///
/// Use this together with ``AuthPickerView/pickerDestination(_:)`` to customize its appearance
/// (background, tint, etc.) with plain SwiftUI modifiers, without rebuilding the routing switch
/// from scratch:
///
/// ```swift
/// AuthPickerView { authenticatedApp }
///   .pickerDestination { screen in
///     AuthPickerDestinationView(screen: screen)
///       .background(theme.colors.background)
///   }
/// ```
@MainActor
public struct AuthPickerDestinationView: View {
  let screen: AuthView

  public init(screen: AuthView) {
    self.screen = screen
  }

  public var body: some View {
    switch screen {
    case AuthView.passwordRecovery:
      PasswordRecoveryView()
    case AuthView.emailLink:
      EmailLinkView()
    case AuthView.updatePassword:
      UpdatePasswordView()
    case AuthView.mfaEnrollment:
      MFAEnrolmentView()
    case AuthView.mfaManagement:
      MFAManagementView()
    case let .mfaResolution(mfaRequired):
      MFAResolutionView(mfaRequired: mfaRequired)
    case AuthView.enterPhoneNumber:
      EnterPhoneNumberView()
    case let .enterVerificationCode(verificationID, fullPhoneNumber):
      EnterVerificationCodeView(
        verificationID: verificationID,
        fullPhoneNumber: fullPhoneNumber
      )
    }
  }
}
