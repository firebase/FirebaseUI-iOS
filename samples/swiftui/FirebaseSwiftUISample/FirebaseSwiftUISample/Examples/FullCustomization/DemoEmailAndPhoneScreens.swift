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

// The Figma file has no frames for these screens; their copy and structure follow the
// FirebaseUI-Android full customization demo, restyled with the theme's Landing values.

struct DemoPasswordRecovery: View {
  var body: some View {
    PasswordRecoveryScreen { state in
      if state.didSend {
        DemoPage(title: "Check your inbox") {
          DemoBodyText("Reset link sent! Follow the link we sent to \(state.sentEmail).")
          DemoButton(
            title: "Back to login",
            identifier: "back-to-login-button",
            action: state.dismissSuccess
          )
        }
      } else {
        DemoPage(title: "Reset password") {
          DemoBodyText("Enter your email address and we'll send you a link to reset it.")
          DemoTextField(
            icon: "at",
            placeholder: "Email address",
            text: state.email,
            keyboard: .emailAddress,
            contentType: .emailAddress,
            identifier: "email-field"
          )
          DemoErrorText(message: state.errorMessage)
          DemoButton(
            title: "Send reset link",
            isLoading: state.isLoading,
            identifier: "send-reset-link-button",
            action: state.sendResetLink
          )
          .disabled(!state.isValid)
        }
      }
    }
  }
}

struct DemoEmailLink: View {
  var body: some View {
    EmailLinkScreen { state in
      if state.didSend {
        DemoPage(title: "Check your inbox") {
          DemoBodyText(
            "Login link sent! Open it on this device to sign in as \(state.email.wrappedValue)."
          )
          DemoErrorText(message: state.errorMessage)
          DemoButton(
            title: "Use a different email",
            kind: .secondary,
            isLoading: state.isLoading,
            identifier: "different-email-button",
            action: state.dismissAlert
          )
        }
      } else {
        DemoPage(title: "Email link sign-in") {
          DemoBodyText("We'll email you a link that signs you in, no password needed.")
          DemoTextField(
            icon: "at",
            placeholder: "Email address",
            text: state.email,
            keyboard: .emailAddress,
            contentType: .emailAddress,
            identifier: "email-field"
          )
          DemoErrorText(message: state.errorMessage)
          DemoButton(
            title: "Send login link",
            isLoading: state.isLoading,
            identifier: "send-login-link-button",
            action: state.sendSignInLink
          )
          .disabled(!state.isValid)
        }
      }
    }
  }
}

struct DemoEnterPhoneNumber: View {
  var body: some View {
    EnterPhoneNumberScreen { state in
      DemoPage(title: "Login by phone number") {
        DemoPhoneNumberField(phoneNumber: state.phoneNumber, country: state.selectedCountry)
        DemoBodyText(
          "By signing in with phone number, an SMS may be sent. Message & data rates may apply."
        )
        DemoErrorText(message: state.errorMessage)
        DemoButton(
          title: "Send code",
          isLoading: state.isLoading,
          identifier: "send-code-button",
          action: state.sendCode
        )
        .disabled(!state.isValid)
      }
    }
  }
}

struct DemoEnterVerificationCode: View {
  let verificationID: String
  let fullPhoneNumber: String

  var body: some View {
    EnterVerificationCodeScreen(
      verificationID: verificationID,
      fullPhoneNumber: fullPhoneNumber
    ) { state in
      DemoPage(title: "Enter your code") {
        DemoBodyText("We sent a code to \(state.fullPhoneNumber).")
        DemoCodeField(code: state.verificationCode, identifier: "verification-code-field")
        DemoErrorText(message: state.errorMessage)
        DemoButton(
          title: "Verify",
          isLoading: state.isLoading,
          identifier: "verify-button",
          action: state.verify
        )
        .disabled(!state.isValid)
        DemoLink(
          title: state.resendCountdown > 0
            ? "Resend code in \(state.resendCountdown)s"
            : "Resend code",
          alignment: .leading,
          identifier: "resend-code-button",
          action: state.resendCode
        )
        .disabled(state.resendCountdown > 0 || state.isLoading)
        DemoLink(
          title: "Use a different number",
          alignment: .leading,
          identifier: "change-number-button",
          action: state.changeNumber
        )
      }
    }
  }
}

/// The library's `CountrySelector` inside a demo text field's frame, tinted with the field text.
struct DemoPhoneNumberField: View {
  let phoneNumber: Binding<String>
  let country: Binding<CountryData>

  @AppStorage(DemoThemeID.storageKey) private var themeID: DemoThemeID = .doggo

  var body: some View {
    let theme = themeID.theme
    let shape = RoundedRectangle(cornerRadius: theme.fieldCornerRadius)
    HStack(spacing: 8) {
      CountrySelector(selectedCountry: country)
        .tint(theme.fieldText.color)
        .font(theme.fieldText.font())
        .accessibilityIdentifier("country-selector")
      TextField(text: phoneNumber) {
        Text("Phone number").foregroundStyle(theme.fieldPlaceholder)
      }
      .font(theme.fieldText.font())
      .foregroundStyle(theme.fieldText.color)
      .keyboardType(.phonePad)
      .textContentType(.telephoneNumber)
      .accessibilityIdentifier("phone-number-field")
    }
    .padding(.horizontal, 16)
    .frame(minHeight: 56)
    .background(theme.fieldFill, in: shape)
    .overlay { shape.strokeBorder(theme.fieldStroke.color, lineWidth: theme.fieldStroke.width) }
  }
}

/// A one-time code in a demo text field.
struct DemoCodeField: View {
  let code: Binding<String>
  var identifier: String

  var body: some View {
    DemoTextField(
      icon: "number",
      placeholder: "6-digit code",
      text: code,
      keyboard: .numberPad,
      contentType: .oneTimeCode,
      identifier: identifier
    )
  }
}
