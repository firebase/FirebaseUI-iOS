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

import FirebaseAppleSwiftUI
import FirebaseAuth
import FirebaseAuthSwiftUI
import FirebaseGoogleSwiftUI
import FirebaseOAuthSwiftUI
import FirebasePhoneAuthSwiftUI
import SwiftUI

/// Every screen of the authentication sheet drawn by the app, while the library keeps the auth
/// logic, navigation, MFA, account conflicts and reauthentication.
///
/// - `.pickerContent { state in ... }` replaces the whole first screen.
/// - `.pickerDestination` replaces each pushed screen through its content slot; update password
///   has no slot and stays stock, falling through to `DefaultAuthPickerDestination`.
/// - `.signedInContent` replaces the signed-in screen.
/// - The theming modifiers restyle the stock screens left in the flow (update password,
///   reauthentication, delete confirmation) and the library components the demo reuses.
struct FullCustomizationExample: View {
  /// Its own service, so it can turn on email-link sign-in (drawn in the Figma frames) without
  /// changing the other examples.
  @State private var authService = AuthService(configuration: Self.configuration)
    .withEmailSignIn()
    .withEmailLinkSignIn()
    .withGoogleSignIn()
    .withPhoneSignIn()
    .withAppleSignIn()
    .withOAuthSignIn(OAuthProviderSwift.github())

  var body: some View {
    FullCustomizationFlow()
      .environment(authService)
  }

  private static var configuration: AuthConfiguration {
    let actionCodeSettings = ActionCodeSettings()
    actionCodeSettings.handleCodeInApp = true
    actionCodeSettings.url = URL(string: "https://flutterfire-e2e-tests.firebaseapp.com")
    actionCodeSettings.setIOSBundleID(Bundle.main.bundleIdentifier!)
    actionCodeSettings.linkDomain = "flutterfire-e2e-tests.firebaseapp.com"
    return AuthConfiguration(
      tosUrl: URL(string: "https://example.com/tos"),
      privacyPolicyUrl: URL(string: "https://example.com/privacy"),
      emailLinkSignInActionCodeSettings: actionCodeSettings,
      mfaEnabled: true
    )
  }
}

private struct FullCustomizationFlow: View {
  @Environment(AuthService.self) private var authService
  @AppStorage(DemoThemeID.storageKey) private var themeID: DemoThemeID = .doggo

  var body: some View {
    let theme = themeID.theme
    AuthPickerView {
      home
    }
    .pickerContent { state in
      DemoLanding(pickerState: state)
    }
    .pickerDestination { screen in
      switch screen {
      case .passwordRecovery:
        DemoPasswordRecovery()
      case .emailLink:
        DemoEmailLink()
      case .enterPhoneNumber:
        DemoEnterPhoneNumber()
      case let .enterVerificationCode(verificationID, fullPhoneNumber):
        DemoEnterVerificationCode(verificationID: verificationID, fullPhoneNumber: fullPhoneNumber)
      case .mfaEnrollment:
        DemoMFAEnrolment()
      case .mfaManagement:
        DemoMFAManagement()
      case let .mfaResolution(mfaRequired):
        DemoMFAResolution(mfaRequired: mfaRequired)
      default:
        DefaultAuthPickerDestination(screen: screen)
      }
    }
    .signedInContent { state in
      DemoSignedIn(state: state)
    }
    .authTypography(theme.typography)
    .authTextFieldStyle(theme.textFieldStyle)
    .authCTAButtonStyle(theme.ctaButtonStyle)
  }

  private var home: some View {
    VStack(spacing: 24) {
      Picker("Theme", selection: $themeID) {
        ForEach(DemoThemeID.allCases) { theme in
          Text(theme.label).tag(theme)
        }
      }
      .pickerStyle(.segmented)
      .accessibilityIdentifier("theme-picker")

      if authService.authenticationState == .authenticated {
        let user = authService.currentUser
        Text("Signed in as \(user?.email ?? user?.phoneNumber ?? "")")
          .authFont(.body)
        DemoButton(title: "Manage account", identifier: "manage-account-button") {
          authService.isPresented = true
        }
      } else {
        Text("Not signed in")
          .authFont(.body)
        DemoButton(title: "Sign in", identifier: "sign-in-sheet-button") {
          authService.isPresented = true
        }
      }
    }
    .padding(24)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background { DemoThemeBackground(theme: themeID.theme) }
    .authTypography(themeID.theme.typography)
  }
}
