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
/// - `.reauthContent` replaces the password, phone and email-link reauthentication prompts.
/// - The theming modifiers restyle the stock screens left in the flow (update password, delete
///   confirmation) and the library components the demo reuses.
///
/// Doggo, Grid and Coffee Spark share one layout and differ only in ``DemoTheme`` values.
/// Professional brings its own layout, the `Pro…` screens, through the same slots, and pushes a
/// separate sign-up screen on the `.signUp` route.
///
/// Its sign-in links are tagged (``isEmailLink(_:)``), so the app can open this example with a
/// link that arrives while another screen is showing, including after a cold launch, like the
/// FirebaseUI-Android demo does.
struct FullCustomizationExample: View {
  /// A sign-in link the app opened while this example wasn't showing. While it is showing,
  /// `AuthPickerView` handles links itself.
  @Binding var incomingLink: URL?

  /// Its own service, so it can turn on email-link sign-in (part of the themes' designs) without
  /// changing the other examples. Created when the example appears.
  @State private var authService: AuthService?
  @State private var linkError: String?

  var body: some View {
    if let authService {
      FullCustomizationFlow()
        .environment(authService)
        .task(id: incomingLink) { await handleIncomingLink(with: authService) }
        .alert(
          "This sign-in link didn't work",
          isPresented: Binding(get: { linkError != nil }, set: { _ in linkError = nil })
        ) {} message: {
          Text(linkError ?? "")
        }
    } else {
      Color.clear.onAppear {
        authService = AuthService(configuration: Self.configuration)
          .withEmailSignIn(requireDisplayName: true)
          .withEmailLinkSignIn()
          .withGoogleSignIn()
          .withPhoneSignIn()
          .withAppleSignIn()
          .withOAuthSignIn(OAuthProviderSwift.github())
      }
    }
  }

  /// Whether `url` is a sign-in link this example sent: the email link (the URL itself, or
  /// wrapped in its `link` parameter) has a continue URL carrying ``linkTag``.
  static func isEmailLink(_ url: URL) -> Bool {
    func queryValue(_ name: String, in url: URL) -> String? {
      URLComponents(url: url, resolvingAgainstBaseURL: false)?
        .queryItems?.first { $0.name == name }?.value
    }
    let emailLink = queryValue("link", in: url).flatMap(URL.init(string:)) ?? url
    guard let continueURL = queryValue("continueUrl", in: emailLink).flatMap(URL.init(string:))
    else { return false }
    return queryValue(linkTag.name, in: continueURL) == linkTag.value
  }

  /// Added to the continue URL, which the library keeps when it adds its own parameters.
  private static let linkTag = URLQueryItem(name: "demo", value: "fullcustomization")

  /// Signs in with a link handed over by the app, then shows the sheet: signed in, or on the
  /// email-link screen when the link was opened on a device that didn't request it.
  private func handleIncomingLink(with authService: AuthService) async {
    guard let url = incomingLink else { return }
    incomingLink = nil
    do {
      try await authService.handleSignInLink(url: url)
      authService.isPresented = true
    } catch where authService.pendingEmailLink != nil {
      authService.isPresented = true
      authService.navigator.push(.emailLink)
    } catch {
      linkError = authService.string.localizedErrorMessage(for: error)
    }
  }

  private static var configuration: AuthConfiguration {
    var continueURL = URLComponents(string: "https://flutterfire-e2e-tests.firebaseapp.com")!
    continueURL.queryItems = [linkTag]
    let actionCodeSettings = ActionCodeSettings()
    actionCodeSettings.handleCodeInApp = true
    actionCodeSettings.url = continueURL.url
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
    .reauthContent { prompt in
      ThemedReauth(prompt: prompt)
    }
    .authTypography(theme.typography)
    .authTextFieldStyle(theme.textFieldStyle)
    .authCTAButtonStyle(theme.ctaButtonStyle)
    .modifier(DemoColorScheme(fixed: themeID.colorScheme))
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

/// Pins the colour scheme for themes that have one, and otherwise passes the system's on.
/// Unlike `preferredColorScheme`, it takes effect in an open sheet when the theme changes.
private struct DemoColorScheme: ViewModifier {
  let fixed: ColorScheme?

  @Environment(\.colorScheme) private var system

  func body(content: Content) -> some View {
    content.environment(\.colorScheme, fixed ?? system)
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
      sharedLayout
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

  /// The shared-layout themes switch sign-in and sign-up in place on the first screen.
  /// `.signUp` only arrives when the theme changes on Professional's pushed sign-up screen.
  @ViewBuilder
  private var sharedLayout: some View {
    switch screen {
    case .signUp:
      DemoSignUp()
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
