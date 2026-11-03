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
import SwiftUI

/// The Professional first screen: the sign-in providers first, then the email form. Creating an
/// account is its own pushed screen (``ProSignUp``), reached through `goToSignUp`.
struct ProLanding: View {
  let pickerState: AuthMethodPickerState

  @Environment(AuthService.self) private var authService
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
    EmailAuthScreen(flow: .signIn) { state in
      ProPage {
        VStack(alignment: .leading, spacing: 28) {
          HStack(spacing: 10) {
            ProIconTile(symbol: "shield", size: 32, fill: ProPalette.accentFill, tint: .white)
            Text("FirebaseUI Demo")
              .font(.system(size: 15, weight: .semibold))
          }
          ProHeader(
            title: "Sign in to your account",
            subtitle: "Welcome back. Choose how you'd like to continue."
          )
        }
      } content: {
        VStack(alignment: .leading, spacing: 0) {
          providers
          if authService.emailPasswordSignInEnabled {
            if !pickerState.providers.isEmpty {
              ProDivider(label: "or continue with email")
                .padding(.vertical, 22)
            }
            emailForm(state)
          }
        }
      } footer: {
        ProLegalText()
      }
    }
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

  private var providers: some View {
    VStack(spacing: 10) {
      if let google {
        ProOutlineButton(title: "Continue with Google", identifier: "google-button") {
          Image("FullCustomization/google-g")
        } action: {
          pickerState.select(google)
        }
      }
      if let phone {
        ProOutlineButton(title: "Continue with phone", identifier: "phone-button") {
          Image(systemName: "phone")
        } action: {
          pickerState.select(phone)
        }
      }
      if !otherProviders.isEmpty {
        ProOutlineButton(title: "More sign-in options", identifier: "other-providers-button") {
          Image(systemName: "ellipsis.circle")
        } action: {
          isShowingOtherProviders = true
        }
      }
    }
  }

  @ViewBuilder
  private func emailForm(_ state: EmailAuthContentState) -> some View {
    VStack(alignment: .leading, spacing: 16) {
      ProField(
        label: "Email",
        placeholder: "name@company.com",
        text: state.email,
        keyboard: .emailAddress,
        contentType: .emailAddress,
        identifier: "email-field"
      )
      ProField(
        label: "Password",
        placeholder: "Enter your password",
        text: state.password,
        isSecure: true,
        contentType: .password,
        identifier: "password-field"
      ) {
        Button("Forgot password?", action: state.goToPasswordRecovery)
          .font(.system(size: 14, weight: .medium))
          .foregroundStyle(ProPalette.accent)
          .buttonStyle(.plain)
          .accessibilityIdentifier("forgot-password")
      }
      ProErrorText(message: state.errorMessage)
      ProPrimaryButton(
        title: "Sign in",
        isLoading: state.isLoading,
        identifier: "sign-in-button",
        action: state.signIn
      )
      .disabled(!state.isValid)
      .padding(.top, 4)
    }
    if pickerState.isEmailLinkEnabled {
      ProTextButton(
        title: "Email me a sign-in link",
        identifier: "email-link-button",
        action: state.goToEmailLink
      )
      .padding(.top, 4)
    }
    ProPromptLink(
      prompt: "Don't have an account?",
      action: "Create account",
      identifier: "create-account-button",
      perform: state.goToSignUp
    )
    .padding(.top, 4)
  }
}

/// The pushed sign-up screen, on the `.signUp` route.
struct ProSignUp: View {
  var body: some View {
    EmailAuthScreen(flow: .signUp) { state in
      ProPage {
        ProHeader(
          symbol: "person.badge.plus",
          title: "Create your account",
          subtitle: "Sign up with your email. It takes less than a minute."
        )
      } content: {
        VStack(alignment: .leading, spacing: 16) {
          ProField(
            label: "Email",
            placeholder: "name@company.com",
            text: state.email,
            keyboard: .emailAddress,
            contentType: .emailAddress,
            identifier: "email-field"
          )
          ProField(
            label: "Password",
            placeholder: "At least 6 characters",
            text: state.password,
            isSecure: true,
            contentType: .newPassword,
            identifier: "password-field"
          )
          ProField(
            label: "Confirm password",
            placeholder: "Repeat your password",
            text: state.confirmPassword,
            isSecure: true,
            contentType: .newPassword,
            identifier: "confirm-password-field"
          )
          ProErrorText(message: state.errorMessage)
          ProPrimaryButton(
            title: "Create account",
            isLoading: state.isLoading,
            identifier: "create-account-submit",
            action: state.signUp
          )
          .disabled(!state.isValid)
          .padding(.top, 4)
        }
        // With a fixed sign-up flow, switchFlow goes back to the sign-in screen.
        ProPromptLink(
          prompt: "Already have an account?",
          action: "Sign in",
          identifier: "sign-in-instead-button",
          perform: state.switchFlow
        )
        .padding(.top, 8)
      } footer: {
        ProLegalText(prefix: "By creating an account, you agree to the")
      }
    }
  }
}

struct ProPasswordRecovery: View {
  var body: some View {
    PasswordRecoveryScreen { state in
      if state.didSend {
        ProPage {
          ProHeader(
            symbol: "envelope.badge",
            title: "Check your inbox",
            subtitle: "We sent a link to reset your password to \(state.sentEmail)."
          )
        } content: {
          ProPrimaryButton(
            title: "Back to sign in",
            identifier: "back-to-sign-in-button",
            action: state.dismissSuccess
          )
        }
      } else {
        ProPage {
          ProHeader(
            symbol: "lock",
            title: "Reset your password",
            subtitle: "Enter the email you sign in with and we'll send you a link to choose a new password."
          )
        } content: {
          VStack(alignment: .leading, spacing: 16) {
            ProField(
              label: "Email",
              placeholder: "name@company.com",
              text: state.email,
              keyboard: .emailAddress,
              contentType: .emailAddress,
              identifier: "email-field"
            )
            ProErrorText(message: state.errorMessage)
            ProPrimaryButton(
              title: "Send reset link",
              isLoading: state.isLoading,
              identifier: "send-reset-link-button",
              action: state.sendResetLink
            )
            .disabled(!state.isValid)
            .padding(.top, 4)
          }
        }
      }
    }
  }
}

struct ProEmailLink: View {
  var body: some View {
    EmailLinkScreen { state in
      if state.didSend {
        ProPage {
          ProHeader(
            symbol: "envelope.badge",
            title: "Check your inbox",
            subtitle: "We sent a sign-in link to \(state.email.wrappedValue). Open it on this device to finish signing in."
          )
        } content: {
          ProErrorText(message: state.errorMessage)
          ProTextButton(
            title: "Use a different email",
            identifier: "different-email-button",
            action: state.dismissAlert
          )
          .disabled(state.isLoading)
        }
      } else {
        ProPage {
          ProHeader(
            symbol: "envelope",
            title: "Sign in with a link",
            subtitle: "We'll email you a link that signs you in, no password needed."
          )
        } content: {
          VStack(alignment: .leading, spacing: 16) {
            ProField(
              label: "Email",
              placeholder: "name@company.com",
              text: state.email,
              keyboard: .emailAddress,
              contentType: .emailAddress,
              identifier: "email-field"
            )
            ProErrorText(message: state.errorMessage)
            ProPrimaryButton(
              title: "Send link",
              isLoading: state.isLoading,
              identifier: "send-login-link-button",
              action: state.sendSignInLink
            )
            .disabled(!state.isValid)
            .padding(.top, 4)
          }
        }
      }
    }
  }
}

struct ProEnterPhoneNumber: View {
  var body: some View {
    EnterPhoneNumberScreen { state in
      ProPage {
        ProHeader(
          symbol: "phone",
          title: "Sign in with your phone",
          subtitle: "We'll text you a 6-digit code to confirm it's you. Message and data rates may apply."
        )
      } content: {
        VStack(alignment: .leading, spacing: 16) {
          ProPhoneField(phoneNumber: state.phoneNumber, country: state.selectedCountry)
          ProErrorText(message: state.errorMessage)
          ProPrimaryButton(
            title: "Send code",
            isLoading: state.isLoading,
            identifier: "send-code-button",
            action: state.sendCode
          )
          .disabled(!state.isValid)
          .padding(.top, 4)
        }
      }
    }
  }
}

struct ProEnterVerificationCode: View {
  let verificationID: String
  let fullPhoneNumber: String

  var body: some View {
    EnterVerificationCodeScreen(
      verificationID: verificationID,
      fullPhoneNumber: fullPhoneNumber
    ) { state in
      ProPage {
        ProHeader(
          symbol: "number",
          title: "Enter the code",
          subtitle: "We sent a 6-digit code to \(state.fullPhoneNumber)."
        )
      } content: {
        VStack(alignment: .leading, spacing: 16) {
          ProField(
            label: "Verification code",
            placeholder: "6-digit code",
            text: state.verificationCode,
            keyboard: .numberPad,
            contentType: .oneTimeCode,
            identifier: "verification-code-field"
          )
          ProErrorText(message: state.errorMessage)
          ProPrimaryButton(
            title: "Verify",
            isLoading: state.isLoading,
            identifier: "verify-button",
            action: state.verify
          )
          .disabled(!state.isValid)
          .padding(.top, 4)
        }
        HStack {
          ProTextButton(
            title: state.resendCountdown > 0
              ? "Resend code in \(state.resendCountdown)s"
              : "Resend code",
            alignment: .leading,
            identifier: "resend-code-button",
            action: state.resendCode
          )
          .disabled(state.resendCountdown > 0 || state.isLoading)
          ProTextButton(
            title: "Use a different number",
            alignment: .trailing,
            identifier: "change-number-button",
            action: state.changeNumber
          )
        }
        .padding(.top, 4)
      }
    }
  }
}
