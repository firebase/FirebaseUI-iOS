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
///
/// The Figma themes share one layout and differ only in ``DemoTheme`` values. Professional also
/// brings its own layout, the `Pro…` screens, through the same slots, and pushes a separate
/// sign-up screen on the `.signUp` route.
struct FullCustomizationExample: View {
  /// Its own service, so it can turn on email-link sign-in (drawn in the Figma frames) without
  /// changing the other examples.
  /// Created when the example appears: `NavigationLink` builds its destination eagerly.
  @State private var authService: AuthService?

  var body: some View {
    if let authService {
      FullCustomizationFlow()
        .environment(authService)
    } else {
      Color.clear.onAppear {
        authService = AuthService(configuration: Self.configuration)
          .withEmailSignIn()
          .withEmailLinkSignIn()
          .withGoogleSignIn()
          .withPhoneSignIn()
          .withAppleSignIn()
          .withOAuthSignIn(OAuthProviderSwift.github())
      }
    }
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
      ThemedLanding(pickerState: state)
    }
    .pickerDestination { screen in
      ThemedDestination(screen: screen)
    }
    .signedInContent { state in
      ThemedSignedIn(state: state)
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
  }
}

/// The first screen for the selected theme.
private struct ThemedLanding: View {
  let pickerState: AuthMethodPickerState

  @AppStorage(DemoThemeID.storageKey) private var themeID: DemoThemeID = .doggo

  var body: some View {
    if themeID == .professional {
      ProLanding(pickerState: pickerState)
    } else {
      DemoLanding(pickerState: pickerState)
    }
  }
}

/// The pushed screens for the selected theme. Update password has no content slot, so it stays
/// stock in every theme.
private struct ThemedDestination: View {
  let screen: AuthView

  @AppStorage(DemoThemeID.storageKey) private var themeID: DemoThemeID = .doggo

  var body: some View {
    if themeID == .professional {
      professional
    } else {
      figma
    }
  }

  @ViewBuilder
  private var professional: some View {
    switch screen {
    case .signUp:
      ProSignUp()
    case .passwordRecovery:
      ProPasswordRecovery()
    case .emailLink:
      ProEmailLink()
    case .enterPhoneNumber:
      ProEnterPhoneNumber()
    case let .enterVerificationCode(verificationID, fullPhoneNumber):
      ProEnterVerificationCode(verificationID: verificationID, fullPhoneNumber: fullPhoneNumber)
    case .mfaEnrollment:
      ProMFAEnrolment()
    case .mfaManagement:
      ProMFAManagement()
    case let .mfaResolution(mfaRequired):
      ProMFAResolution(mfaRequired: mfaRequired)
    default:
      DefaultAuthPickerDestination(screen: screen)
    }
  }

  /// The Figma themes switch sign-in and sign-up in place on the first screen, so they never
  /// push `.signUp`.
  @ViewBuilder
  private var figma: some View {
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
}

/// The signed-in screen for the selected theme.
private struct ThemedSignedIn: View {
  let state: SignedInContentState

  @AppStorage(DemoThemeID.storageKey) private var themeID: DemoThemeID = .doggo

  var body: some View {
    if themeID == .professional {
      ProAccount(state: state)
    } else {
      DemoSignedIn(state: state)
    }
  }
}
