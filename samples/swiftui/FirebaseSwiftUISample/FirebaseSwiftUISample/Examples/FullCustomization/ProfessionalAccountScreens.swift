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

import FirebaseAuth
import FirebaseAuthSwiftUI
import SwiftUI

/// The Professional signed-in screen: an account settings page with grouped rows.
struct ProAccount: View {
  let state: SignedInContentState

  private var user: User? { state.user }

  private var providerIDs: [String] {
    user?.providerData.map(\.providerID) ?? []
  }

  /// Only accounts that sign in with a password can change one.
  private var hasPassword: Bool { providerIDs.contains("password") }

  private var signInMethod: String {
    switch providerIDs.first {
    case "password": "email"
    case "phone": "phone"
    case "google.com": "Google"
    case "apple.com": "Apple"
    case "github.com": "GitHub"
    case let other?: other
    case nil: "a temporary account"
    }
  }

  private var isTwoFactorOn: Bool {
    !(user?.multiFactor.enrolledFactors.isEmpty ?? true)
  }

  var body: some View {
    ProPage {
      ProHeader(title: "Account")
    } content: {
      VStack(alignment: .leading, spacing: 0) {
        profile
        ProErrorText(message: state.errorMessage)
          .padding(.top, 16)
        security
        ProGroup {
          ProRow(
            title: "Sign out",
            tint: ProPalette.accent,
            showsChevron: false,
            identifier: "sign-out-button",
            action: state.signOut
          )
        }
        .padding(.top, 24)
        ProGroup {
          ProRow(
            title: "Delete account",
            tint: ProPalette.danger,
            showsChevron: false,
            identifier: "delete-account-button",
            action: state.deleteAccount
          )
        }
        .padding(.top, 24)
        Text(
          "Deleting your account removes your data permanently. You may be asked to sign in again first."
        )
        .font(.system(size: 13))
        .foregroundStyle(ProPalette.muted)
        .fixedSize(horizontal: false, vertical: true)
        .padding(.horizontal, 4)
        .padding(.top, 8)
      }
      .disabled(state.isLoading)
    }
  }

  private var profile: some View {
    let identity = user?.email ?? user?.phoneNumber ?? "Signed in"
    return HStack(spacing: 14) {
      Text(String(identity.prefix(1)).uppercased())
        .font(.system(size: 22, weight: .semibold))
        .foregroundStyle(ProPalette.accentSoftText)
        .frame(width: 56, height: 56)
        .background(ProPalette.accentSoft, in: Circle())
        .accessibilityHidden(true)
      VStack(alignment: .leading, spacing: 2) {
        Text(identity)
          .font(.system(size: 17, weight: .semibold))
          .lineLimit(1)
          .truncationMode(.middle)
        Text("Signed in with \(signInMethod)")
          .font(.system(size: 14))
          .foregroundStyle(ProPalette.muted)
      }
    }
    .accessibilityElement(children: .combine)
    .accessibilityIdentifier("profile")
  }

  @ViewBuilder
  private var security: some View {
    let email = user?.email
    if hasPassword || state.isMFAEnabled || email != nil {
      ProSectionLabel(text: "Security")
        .padding(.top, 32)
      ProGroup {
        if hasPassword {
          ProRow(
            symbol: "key",
            title: "Password",
            value: "Change",
            identifier: "update-password-button",
            action: state.updatePassword
          )
        }
        if state.isMFAEnabled {
          if hasPassword {
            ProRowSeparator()
          }
          ProRow(
            symbol: "lock.shield",
            title: "Two-factor authentication",
            value: isTwoFactorOn ? "On" : "Off",
            identifier: "mfa-management-button",
            action: state.goToMFAManagement
          )
        }
        if email != nil {
          if hasPassword || state.isMFAEnabled {
            ProRowSeparator()
          }
          ProRow(
            symbol: "envelope",
            title: "Email",
            value: state.isEmailVerified ? "Verified" : "Verify",
            valueTint: state.isEmailVerified ? ProPalette.muted : ProPalette.accent,
            showsChevron: false,
            identifier: "verify-email-button",
            action: state.isEmailVerified ? {} : state.verifyEmail
          )
          .disabled(state.isEmailVerified)
        }
      }
    }
  }
}

struct ProMFAManagement: View {
  var body: some View {
    MFAManagementScreen { state in
      ProPage {
        ProHeader(
          symbol: "lock.shield",
          title: "Two-factor authentication",
          subtitle: state.enrolledFactors.isEmpty
            ? "Add a second step to sign-in, so a password on its own isn't enough."
            : "These methods can confirm it's you when you sign in."
        )
      } content: {
        VStack(alignment: .leading, spacing: 0) {
          if !state.enrolledFactors.isEmpty {
            ProSectionLabel(text: "Your methods")
            ProGroup {
              let factors = Array(state.enrolledFactors.enumerated())
              ForEach(factors, id: \.element.uid) { index, factor in
                if index > 0 {
                  ProRowSeparator(inset: 66)
                }
                ProFactorRow(factor: factor) {
                  state.unenroll(factor.uid)
                }
              }
            }
            .disabled(state.isLoading)
          }
          ProErrorText(message: state.errorMessage)
            .padding(.top, 16)
          ProPrimaryButton(
            title: state.enrolledFactors.isEmpty ? "Set up two-factor" : "Add another method",
            isLoading: state.isLoading,
            identifier: "add-factor-button",
            action: state.goToEnrollment
          )
          .padding(.top, 8)
        }
      }
    }
  }
}

/// An enrolled second factor, with a Remove action.
private struct ProFactorRow: View {
  let factor: MultiFactorInfo
  let remove: () -> Void

  private var isPhone: Bool { factor.factorID == PhoneMultiFactorID }

  var body: some View {
    HStack(spacing: 14) {
      ProIconTile(symbol: isPhone ? "message" : "iphone")
      VStack(alignment: .leading, spacing: 2) {
        Text(factor.displayName ?? (isPhone ? "Text message" : "Authenticator app"))
          .font(.system(size: 16, weight: .medium))
        Text(isPhone
          ? (factor as? PhoneMultiFactorInfo)?.phoneNumber ?? "Text message"
          : "Authenticator app")
          .font(.system(size: 14))
          .foregroundStyle(ProPalette.muted)
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      Button("Remove", action: remove)
        .font(.system(size: 15, weight: .medium))
        .foregroundStyle(ProPalette.danger)
        .frame(minHeight: 44)
        .buttonStyle(.plain)
        .accessibilityIdentifier("remove-factor-button")
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 8)
  }
}

struct ProMFAEnrolment: View {
  var body: some View {
    MFAEnrolmentScreen { ProMFAEnrolmentContent(state: $0) }
  }
}

/// The enrolment steps, apart from `MFAEnrolmentScreen` so they can be previewed with a stub
/// state: the Auth emulator can't enrol TOTP.
struct ProMFAEnrolmentContent: View {
  let state: MFAEnrollmentContentState

  var body: some View {
    switch state.step {
    case .selectFactor:
      ProPage {
        ProHeader(
          symbol: "lock.shield",
          title: "Set up two-factor authentication",
          subtitle: "Add a second step to sign-in, so a password on its own isn't enough."
        )
      } content: {
        VStack(alignment: .leading, spacing: 0) {
          ProSectionLabel(text: "Choose a method")
          ProGroup {
            ForEach(Array(state.allowedFactors.enumerated()), id: \.element) { index, factor in
              if index > 0 {
                ProRowSeparator(inset: 66)
              }
              ProChoiceRow(
                symbol: factor == .sms ? "message" : "iphone",
                title: factor == .sms ? "Text message" : "Authenticator app",
                detail: factor == .sms
                  ? "We'll text a code to your phone."
                  : "Use a code from an app like Google Authenticator.",
                isSelected: state.selectedFactorType.wrappedValue == factor,
                identifier: factor == .sms ? "sms-factor-button" : "totp-factor-button"
              ) {
                state.selectedFactorType.wrappedValue = factor
              }
            }
          }
          ProErrorText(message: state.isMFAEnabled
            ? state.errorMessage
            : "Two-factor sign-in isn't enabled for this app.")
            .padding(.top, 16)
          ProPrimaryButton(
            title: "Continue",
            isLoading: state.isLoading,
            identifier: "start-enrollment-button",
            action: state.startEnrollment
          )
          .disabled(!state.isValid)
          .padding(.top, 12)
        }
      }
    case .enterPhoneNumber:
      ProPage {
        ProHeader(
          symbol: "message",
          title: "Add your phone number",
          subtitle: "We'll text a code to this number whenever you sign in."
        )
      } content: {
        VStack(alignment: .leading, spacing: 16) {
          nameField
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
    case .enterVerificationCode:
      ProPage {
        ProHeader(
          symbol: "number",
          title: "Confirm the code",
          subtitle: "We sent a 6-digit code to \(state.sentPhoneNumber ?? "your phone")."
        )
      } content: {
        VStack(alignment: .leading, spacing: 16) {
          codeField(state.verificationCode)
          ProErrorText(message: state.errorMessage)
          ProPrimaryButton(
            title: "Verify",
            isLoading: state.isLoading,
            identifier: "enroll-button",
            action: state.enroll
          )
          .disabled(!state.isValid)
          .padding(.top, 4)
        }
        ProTextButton(
          title: "Resend code",
          identifier: "resend-code-button",
          action: state.sendCode
        )
        .disabled(state.isLoading)
        .padding(.top, 4)
      }
    case .setUpTOTP:
      ProPage {
        ProHeader(
          symbol: "qrcode",
          title: "Scan to set up",
          subtitle: "Scan the code with your authenticator app, or enter the key by hand."
        )
      } content: {
        VStack(alignment: .leading, spacing: 16) {
          if let url = state.totpQRCodeURL {
            DemoQRCode(url: url)
          }
          if let secret = state.totpSecret {
            HStack(spacing: 12) {
              Text(secret)
                .font(.system(size: 15, design: .monospaced))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
              Button(state.didCopySecret ? "Copied" : "Copy", action: state.copySecret)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(ProPalette.accent)
                .buttonStyle(.plain)
                .accessibilityIdentifier("copy-secret-button")
            }
            .padding(.horizontal, 14)
            .frame(height: 48)
            .proFieldBox()
            .accessibilityIdentifier("totp-secret")
          }
          nameField
          codeField(state.totpCode)
          ProErrorText(message: state.errorMessage)
          ProPrimaryButton(
            title: "Verify",
            isLoading: state.isLoading,
            identifier: "enroll-button",
            action: state.enroll
          )
          .disabled(!state.isValid)
          .padding(.top, 4)
        }
      }
    }
  }

  private var nameField: some View {
    ProField(
      label: "Name",
      placeholder: "For example, Work phone",
      text: state.displayName,
      identifier: "display-name-field"
    )
  }

  private func codeField(_ code: Binding<String>) -> some View {
    ProField(
      label: "Verification code",
      placeholder: "6-digit code",
      text: code,
      keyboard: .numberPad,
      contentType: .oneTimeCode,
      identifier: "verification-code-field"
    )
  }
}

struct ProMFAResolution: View {
  let mfaRequired: MFARequired

  var body: some View {
    MFAResolutionScreen(mfaRequired: mfaRequired) { state in
      let hint = selectedHint(state)
      ProPage {
        ProHeader(symbol: "lock.shield", title: "Verify it's you", subtitle: subtitle(hint, state))
      } content: {
        VStack(alignment: .leading, spacing: 0) {
          if state.hints.count > 1 {
            ProSectionLabel(text: "Choose a method")
            ProGroup {
              ForEach(Array(state.hints.enumerated()), id: \.offset) { index, option in
                if index > 0 {
                  ProRowSeparator(inset: 66)
                }
                ProChoiceRow(
                  symbol: isPhone(option) ? "message" : "iphone",
                  title: title(for: option),
                  detail: detail(for: option),
                  isSelected: state.selectedHintIndex.wrappedValue == index,
                  identifier: "hint-\(index)-button"
                ) {
                  state.selectedHintIndex.wrappedValue = index
                }
              }
            }
            .padding(.bottom, 24)
          }
          VStack(alignment: .leading, spacing: 16) {
            if let hint, !isPhone(hint) || state.isCodeSent {
              ProField(
                label: "Verification code",
                placeholder: "6-digit code",
                text: isPhone(hint) ? state.verificationCode : state.totpCode,
                keyboard: .numberPad,
                contentType: .oneTimeCode,
                identifier: "verification-code-field"
              )
            }
            ProErrorText(message: state.errorMessage)
            if let hint, isPhone(hint), !state.isCodeSent {
              ProPrimaryButton(
                title: "Send code",
                isLoading: state.isLoading,
                identifier: "send-code-button",
                action: state.sendCode
              )
            } else {
              ProPrimaryButton(
                title: "Verify",
                isLoading: state.isLoading,
                identifier: "resolve-button",
                action: state.resolve
              )
              .disabled(!state.isValid)
            }
          }
          if let hint, isPhone(hint), state.isCodeSent {
            ProTextButton(
              title: "Resend code",
              identifier: "resend-code-button",
              action: state.sendCode
            )
            .disabled(state.isLoading)
            .padding(.top, 4)
          }
          ProTextButton(title: "Cancel", identifier: "cancel-button", action: state.cancel)
            .padding(.top, 4)
        }
      }
    }
  }

  private func selectedHint(_ state: MFAResolutionContentState) -> MFAHint? {
    let index = state.selectedHintIndex.wrappedValue
    return state.hints.indices.contains(index) ? state.hints[index] : nil
  }

  private func isPhone(_ hint: MFAHint) -> Bool {
    if case .phone = hint {
      return true
    }
    return false
  }

  private func title(for hint: MFAHint) -> String {
    switch hint {
    case let .phone(displayName, _, _): displayName ?? "Text message"
    case let .totp(displayName, _): displayName ?? "Authenticator app"
    }
  }

  private func detail(for hint: MFAHint) -> String {
    switch hint {
    case let .phone(_, _, phoneNumber): phoneNumber ?? "Text message"
    case .totp: "Authenticator app"
    }
  }

  private func subtitle(_ hint: MFAHint?, _ state: MFAResolutionContentState) -> String {
    switch hint {
    case let .phone(_, _, phoneNumber):
      state.isCodeSent
        ? "Enter the 6-digit code we sent to \(phoneNumber ?? "your phone")."
        : "Your account uses two-factor authentication. We'll text a code to \(phoneNumber ?? "your phone")."
    case .totp:
      "Enter the 6-digit code from your authenticator app."
    case nil:
      "Your account uses two-factor authentication."
    }
  }
}
