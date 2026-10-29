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

import FirebaseAuthSwiftUI
import FirebaseOAuthSwiftUI
import SwiftUI

/// The whole signed-out first screen, from the Figma Landing frames. `EmailAuthScreen` drives the
/// email form, and the provider buttons start sign-in through `AuthMethodPickerState`, so MFA,
/// account conflicts and errors are routed the same as with the stock screen.
struct DemoLanding: View {
  let pickerState: AuthMethodPickerState

  @AppStorage(DemoThemeID.storageKey) private var themeID: DemoThemeID = .doggo

  var body: some View {
    EmailAuthScreen { state in
      DemoPage(title: title(for: state.flow)) {
        emailForm(state)
      } footer: {
        DemoOtherSignInMethods(
          pickerState: pickerState,
          flow: state.flow,
          switchFlow: state.switchFlow
        )
      }
    }
  }

  private func title(for flow: AuthenticationFlow) -> String? {
    guard themeID.theme.showsTitle else { return nil }
    return flow == .signIn ? "Login" : "Sign up"
  }

  @ViewBuilder
  private func emailForm(_ state: EmailAuthContentState) -> some View {
    DemoTextField(
      icon: "at",
      placeholder: "Email address",
      text: state.email,
      keyboard: .emailAddress,
      contentType: .emailAddress,
      identifier: "email-field"
    )
    DemoTextField(
      icon: "ellipsis.rectangle",
      placeholder: "Password",
      text: state.password,
      isSecure: true,
      contentType: state.flow == .signIn ? .password : .newPassword,
      identifier: "password-field"
    )
    if state.flow == .signUp {
      DemoTextField(
        icon: "ellipsis.rectangle",
        placeholder: "Confirm password",
        text: state.confirmPassword,
        isSecure: true,
        contentType: .newPassword,
        identifier: "confirm-password-field"
      )
    }
    DemoErrorText(message: state.errorMessage)
    if state.flow == .signIn {
      DemoLink(
        title: "Forgot password?",
        identifier: "forgot-password",
        action: state.goToPasswordRecovery
      )
    }
    DemoButton(
      title: state.flow == .signIn ? "Login" : "Create account",
      isLoading: state.isLoading,
      identifier: "sign-in-button",
      action: state.flow == .signIn ? state.signIn : state.signUp
    )
    .disabled(!state.isValid)
    if pickerState.isEmailLinkEnabled {
      DemoButton(
        title: "Email link sign-in",
        kind: .secondary,
        identifier: "email-link-button",
        action: state.goToEmailLink
      )
    }
  }
}

/// Figma "Content": the other sign-in methods, the flow switch and the terms. Google and phone
/// get the buttons drawn in Figma; any other registered provider is listed in a sheet.
private struct DemoOtherSignInMethods: View {
  let pickerState: AuthMethodPickerState
  let flow: AuthenticationFlow
  let switchFlow: () -> Void

  @Environment(AuthService.self) private var authService
  @AppStorage(DemoThemeID.storageKey) private var themeID: DemoThemeID = .doggo
  @State private var isShowingOtherProviders = false
  @State private var pendingProvider: AuthProviderUI?

  private var google: AuthProviderUI? {
    pickerState.providers.first { $0.id == "google.com" }
  }

  private var phone: AuthProviderUI? {
    pickerState.providers.first { $0.id == "phone" }
  }

  private var otherProviders: [AuthProviderUI] {
    pickerState.providers.filter { $0.id != "google.com" && $0.id != "phone" }
  }

  var body: some View {
    let theme = themeID.theme
    VStack(spacing: 0) {
      // Not where Figma has it: the sign-in / sign-up switch belongs to the email form, so it
      // sits right below the form, above the other sign-in methods.
      Button(action: switchFlow) {
        flowSwitchText(theme)
          .frame(minHeight: 44)
          .contentShape(Rectangle())
      }
      .buttonStyle(.plain)
      .accessibilityIdentifier("login")

      VStack(spacing: 12) {
        // Like the Figma text layer, the label spans the frame's padding so it doesn't wrap.
        Text("Other sign in methods")
          .demoText(theme.otherLabel)
          .lineLimit(1)
          .padding(.horizontal, -theme.otherPadding.leading)
          .accessibilityIdentifier("other-sign-in-methods")
        if let google {
          DemoProviderButton(
            title: "Continue with Google",
            fill: theme.pillFill,
            label: theme.googleLabel,
            stroke: theme.pillStroke,
            cornerRadius: theme.pillCornerRadius,
            identifier: "google-button"
          ) {
            Image("FullCustomization/google-g")
          } action: {
            pickerState.select(google)
          }
        }
        if let phone {
          DemoProviderButton(
            title: "Sign in with phone",
            fill: theme.phoneProvider.fill,
            label: theme.phoneProvider.label,
            cornerRadius: theme.phoneProvider.cornerRadius,
            identifier: "phone-button"
          ) {
            // Material Symbols "phone".
            Image(systemName: "phone")
              .font(.system(size: 18, weight: .medium))
          } action: {
            pickerState.select(phone)
          }
        }
        if !otherProviders.isEmpty {
          // Not in Figma: the remaining providers, behind a pill styled like Google's.
          DemoProviderButton(
            title: "More sign-in options",
            fill: theme.pillFill,
            label: theme.googleLabel,
            stroke: theme.pillStroke,
            cornerRadius: theme.pillCornerRadius,
            identifier: "other-providers-button"
          ) {
            Image(systemName: "ellipsis.circle")
              .font(.system(size: 18, weight: .medium))
          } action: {
            isShowingOtherProviders = true
          }
        }
      }
      .padding(theme.otherPadding)
      .overlay(alignment: .top) {
        // A 4-point top stroke centred on the frame edge, so the inner 2 points show.
        Rectangle()
          .fill(theme.dividerColor)
          .frame(height: 2)
      }
      .accessibilityElement(children: .contain)
      .accessibilityIdentifier("other")
      // With the switch row's 12-point inset, the divider sits 24 points below the switch text,
      // the same as the gap above it.
      .padding(.top, 12)

      termsText(theme)
        .padding(.top, 24)
    }
    .demoContentWidth()
    // Sign-in starts once the sheet is gone, so a provider that presents its own screen
    // (such as an OAuth web view) isn't presented from a sheet that is animating away.
    .sheet(isPresented: $isShowingOtherProviders, onDismiss: {
      if let provider = pendingProvider {
        pendingProvider = nil
        pickerState.select(provider)
      }
    }) {
      DemoOtherProvidersSheet(providers: otherProviders) { provider in
        pendingProvider = provider
        isShowingOtherProviders = false
      }
      .presentationDetents([.medium, .large])
    }
  }

  private func flowSwitchText(_ theme: DemoTheme) -> Text {
    let prompt = flow == .signIn ? "Don't have an account? " : "Already have an account? "
    let action = flow == .signIn ? "Sign up" : "Login"
    return Text(prompt)
      .font(theme.footerText.font())
      .foregroundColor(theme.footerText.color)
      + Text(action)
      .font(theme.footerAccent.font())
      .foregroundColor(theme.footerAccent.color)
      .underline(theme.footerAccent.underline)
  }

  /// The library's `PrivacyTOCsView` is internal, so a whole custom first screen draws its own
  /// terms copy from the configured URLs.
  @ViewBuilder
  private func termsText(_ theme: DemoTheme) -> some View {
    let configuration = authService.configuration
    if let tosUrl = configuration.tosUrl, let privacyPolicyUrl = configuration.privacyPolicyUrl,
       let terms = try? AttributedString(markdown: """
       By continuing, you agree to the [Terms of Service](\(tosUrl.absoluteString)) \
       and [Privacy Policy](\(privacyPolicyUrl.absoluteString)).
       """) {
      Text(terms)
        .font(theme.footerText.font(relativeTo: .footnote))
        .foregroundStyle(theme.footerText.color)
        .tint(theme.footerAccent.color)
        .multilineTextAlignment(.center)
        .accessibilityIdentifier("terms")
    }
  }
}

/// Figma "android_light_rd_SI": a 52-point pill with a 20-point icon and a label.
private struct DemoProviderButton<Icon: View>: View {
  let title: String
  let fill: Color
  let label: DemoTheme.TextToken
  var stroke: Color?
  let cornerRadius: CGFloat
  var identifier: String
  @ViewBuilder let icon: () -> Icon
  let action: () -> Void

  var body: some View {
    let shape = RoundedRectangle(cornerRadius: cornerRadius)
    Button(action: action) {
      HStack(spacing: 12) {
        icon()
          .frame(width: 20, height: 20)
        Text(title)
          .font(label.font(relativeTo: .subheadline))
          .tracking(0.1)
          .lineLimit(1)
          .minimumScaleFactor(0.8)
      }
      .foregroundStyle(label.color)
      .padding(16)
      .frame(maxWidth: .infinity, minHeight: 52, alignment: .leading)
      .background(fill, in: shape)
      .overlay {
        if let stroke {
          shape.strokeBorder(stroke, lineWidth: 1)
        }
      }
    }
    .buttonStyle(.plain)
    .accessibilityIdentifier(identifier)
  }
}

/// The registered providers the Figma frames don't draw, as the library's own brand buttons.
/// `AuthProviderButton` takes the demo's action, so sign-in still goes through
/// `AuthMethodPickerState.select` once the sheet has closed.
private struct DemoOtherProvidersSheet: View {
  let providers: [AuthProviderUI]
  let select: (AuthProviderUI) -> Void

  @Environment(AuthService.self) private var authService
  @AppStorage(DemoThemeID.storageKey) private var themeID: DemoThemeID = .doggo

  var body: some View {
    let theme = themeID.theme
    ScrollView {
      VStack(spacing: 16) {
        Text("Other sign in methods")
          .demoText(theme.otherLabel)
          .padding(.bottom, 4)
        ForEach(providers, id: \.id) { provider in
          let button = stockButton(for: provider)
          AuthProviderButton(
            label: button.label,
            style: button.style,
            accessibilityId: "\(provider.id)-button"
          ) {
            select(provider)
          }
        }
      }
      .demoContentWidth()
      .padding(.vertical, 32)
      .frame(maxWidth: .infinity)
    }
    .background { DemoThemeBackground(theme: theme) }
  }

  /// The label and style the provider's stock button uses.
  private func stockButton(for provider: AuthProviderUI) -> (label: String, style: ProviderStyle) {
    if let oauth = provider.provider as? OAuthProviderSwift {
      return (oauth.buttonLabel, ProviderStyle(
        icon: oauth.buttonIcon,
        backgroundColor: oauth.buttonBackgroundColor,
        contentColor: oauth.buttonForegroundColor
      ))
    }
    if provider.id == "apple.com" {
      return (authService.string.appleLoginButtonLabel, .apple)
    }
    return ("Sign in with \(provider.displayName)", .empty)
  }
}
