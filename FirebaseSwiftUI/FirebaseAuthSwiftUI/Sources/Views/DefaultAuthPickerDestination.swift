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

/// The default screen for each route pushed inside the authentication sheet.
///
/// Return it from ``AuthPickerView/pickerDestination(_:)`` for the routes you don't customize:
///
/// ```swift
/// AuthPickerView { authenticatedApp }
///   .pickerDestination { screen in
///     switch screen {
///     case .enterPhoneNumber:
///       MyPhoneEntry()
///     default:
///       DefaultAuthPickerDestination(screen: screen)
///     }
///   }
/// ```
@MainActor
public struct DefaultAuthPickerDestination: View {
  public init(screen: AuthView) {
    self.screen = screen
  }

  private let screen: AuthView

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
