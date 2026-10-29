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

// The reauthentication prompts, given to `.reauthContent`. The library still presents them as
// sheets when a sensitive action (deleting the account, changing the password, managing
// two-factor) needs a recent sign-in, and still verifies the user and reports errors. Neither the
// Figma file nor the Android demo draws them, so they reuse each theme's own screen pieces.

/// The reauthentication prompt for the selected theme.
struct ThemedReauth: View {
  let prompt: ReauthPrompt

  @AppStorage(DemoThemeID.storageKey) private var themeID: DemoThemeID = .doggo

  var body: some View {
    if themeID == .professional {
      ProReauth(prompt: prompt)
    } else {
      DemoReauth(prompt: prompt)
    }
  }
}

/// The Figma themes' reauthentication prompt, in the shared layout.
private struct DemoReauth: View {
  let prompt: ReauthPrompt

  var body: some View {
    switch prompt {
    case let .password(state):
      DemoPage(title: "Confirm it's you", showsThemeMenu: false) {
        DemoBodyText("Enter the password for \(state.email) to continue.")
        DemoTextField(
          icon: "ellipsis.rectangle",
          placeholder: "Password",
          text: state.password,
          isSecure: true,
          contentType: .password,
          identifier: "reauth-password-field"
        )
        DemoErrorText(message: state.errorMessage)
        DemoButton(
          title: "Continue",
          isLoading: state.isLoading,
          identifier: "reauth-verify-button",
          action: state.verify
        )
        .disabled(!state.isValid)
        DemoLink(
          title: "Cancel",
          alignment: .leading,
          identifier: "reauth-cancel-button",
          action: state.cancel
        )
      }
    case let .phone(state):
      DemoPage(title: "Confirm it's you", showsThemeMenu: false) {
        DemoBodyText(state.codeSent
          ? "We sent a code to \(state.phoneNumber)."
          : "We'll text a code to \(state.phoneNumber) to confirm it's you.")
        if state.codeSent {
          DemoCodeField(code: state.verificationCode, identifier: "reauth-code-field")
        }
        DemoErrorText(message: state.errorMessage)
        if state.codeSent {
          DemoButton(
            title: "Verify",
            isLoading: state.isLoading,
            identifier: "reauth-verify-button",
            action: state.verify
          )
          .disabled(!state.isValid)
          DemoLink(
            title: "Resend code",
            alignment: .leading,
            identifier: "reauth-resend-button",
            action: state.sendCode
          )
          .disabled(state.isLoading)
        } else {
          DemoButton(
            title: "Send code",
            isLoading: state.isLoading,
            identifier: "reauth-send-code-button",
            action: state.sendCode
          )
        }
        DemoLink(
          title: "Cancel",
          alignment: .leading,
          identifier: "reauth-cancel-button",
          action: state.cancel
        )
      }
    case let .emailLink(state):
      DemoPage(title: "Check your inbox", showsThemeMenu: false) {
        DemoBodyText(state.linkSent
          ? "We sent a sign-in link to \(state.email). Open it on this device to continue."
          : "Sending a sign-in link to \(state.email).")
        DemoErrorText(message: state.errorMessage)
        DemoButton(
          title: "Resend link",
          kind: .secondary,
          isLoading: state.isLoading,
          identifier: "reauth-resend-button",
          action: state.resendLink
        )
        DemoLink(
          title: "Cancel",
          alignment: .leading,
          identifier: "reauth-cancel-button",
          action: state.cancel
        )
      }
    }
  }
}

/// The Professional reauthentication prompt, in its own layout.
private struct ProReauth: View {
  let prompt: ReauthPrompt

  var body: some View {
    switch prompt {
    case let .password(state):
      ProPage(showsThemeMenu: false) {
        ProHeader(
          symbol: "lock",
          title: "Confirm it's you",
          subtitle: "For your security, enter the password for \(state.email) to continue."
        )
      } content: {
        VStack(alignment: .leading, spacing: 16) {
          ProField(
            label: "Password",
            placeholder: "Enter your password",
            text: state.password,
            isSecure: true,
            contentType: .password,
            identifier: "reauth-password-field"
          )
          ProErrorText(message: state.errorMessage)
          ProPrimaryButton(
            title: "Continue",
            isLoading: state.isLoading,
            identifier: "reauth-verify-button",
            action: state.verify
          )
          .disabled(!state.isValid)
          .padding(.top, 4)
        }
        ProTextButton(title: "Cancel", identifier: "reauth-cancel-button", action: state.cancel)
          .padding(.top, 4)
      }
    case let .phone(state):
      ProPage(showsThemeMenu: false) {
        ProHeader(
          symbol: "phone",
          title: "Confirm it's you",
          subtitle: state.codeSent
            ? "Enter the 6-digit code we sent to \(state.phoneNumber)."
            : "For your security, we'll text a code to \(state.phoneNumber)."
        )
      } content: {
        VStack(alignment: .leading, spacing: 16) {
          if state.codeSent {
            ProField(
              label: "Verification code",
              placeholder: "6-digit code",
              text: state.verificationCode,
              keyboard: .numberPad,
              contentType: .oneTimeCode,
              identifier: "reauth-code-field"
            )
          }
          ProErrorText(message: state.errorMessage)
          if state.codeSent {
            ProPrimaryButton(
              title: "Verify",
              isLoading: state.isLoading,
              identifier: "reauth-verify-button",
              action: state.verify
            )
            .disabled(!state.isValid)
            .padding(.top, 4)
          } else {
            ProPrimaryButton(
              title: "Send code",
              isLoading: state.isLoading,
              identifier: "reauth-send-code-button",
              action: state.sendCode
            )
            .padding(.top, 4)
          }
        }
        if state.codeSent {
          ProTextButton(
            title: "Resend code",
            identifier: "reauth-resend-button",
            action: state.sendCode
          )
          .disabled(state.isLoading)
          .padding(.top, 4)
        }
        ProTextButton(title: "Cancel", identifier: "reauth-cancel-button", action: state.cancel)
      }
    case let .emailLink(state):
      ProPage(showsThemeMenu: false) {
        ProHeader(
          symbol: "envelope.badge",
          title: "Check your inbox",
          subtitle: state.linkSent
            ? "We sent a sign-in link to \(state.email). Open it on this device to continue."
            : "Sending a sign-in link to \(state.email)."
        )
      } content: {
        VStack(alignment: .leading, spacing: 0) {
          ProErrorText(message: state.errorMessage)
          ProTextButton(
            title: "Resend link",
            identifier: "reauth-resend-button",
            action: state.resendLink
          )
          .disabled(state.isLoading)
          ProTextButton(title: "Cancel", identifier: "reauth-cancel-button", action: state.cancel)
        }
      }
    }
  }
}
