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

import CoreImage.CIFilterBuiltins
import FirebaseAuth
import FirebaseAuthSwiftUI
import SwiftUI

// The Figma file has no frames for these screens; their copy and structure follow the
// FirebaseUI-Android full customization demo, restyled with the theme's Landing values.

struct DemoSignedIn: View {
  let state: SignedInContentState

  var body: some View {
    DemoPage(title: "You're in") {
      DemoBodyText("Signed in as \(state.user?.email ?? state.user?.phoneNumber ?? "you").")
      // Email verification and password changes only apply to an account with an email.
      let hasEmail = state.user?.email != nil
      if hasEmail, !state.isEmailVerified {
        DemoBodyText("Check your inbox to verify your email address.")
        DemoButton(
          title: "Verify email",
          kind: .secondary,
          identifier: "verify-email-button",
          action: state.verifyEmail
        )
      }
      DemoErrorText(message: state.errorMessage)
      if hasEmail {
        DemoButton(
          title: "Change password",
          isLoading: state.isLoading,
          identifier: "update-password-button",
          action: state.updatePassword
        )
      }
      if state.isMFAEnabled {
        DemoButton(
          title: "Manage two-factor",
          kind: .secondary,
          identifier: "mfa-management-button",
          action: state.goToMFAManagement
        )
      }
      DemoLink(
        title: "Sign out",
        alignment: .leading,
        identifier: "sign-out-button",
        action: state.signOut
      )
      DemoLink(
        title: "Delete account",
        alignment: .leading,
        identifier: "delete-account-button",
        action: state.deleteAccount
      )
    }
    .disabled(state.isLoading)
  }
}

struct DemoMFAManagement: View {
  var body: some View {
    MFAManagementScreen { state in
      DemoPage(title: "Two-factor") {
        if state.enrolledFactors.isEmpty {
          DemoBodyText("Add a second step to sign-in, so a password on its own isn't enough.")
        } else {
          DemoBodyText("Already on this account")
          ForEach(state.enrolledFactors, id: \.uid) { factor in
            DemoFactorRow(factor: factor) {
              state.unenroll(factor.uid)
            }
          }
        }
        DemoErrorText(message: state.errorMessage)
        DemoButton(
          title: state.enrolledFactors.isEmpty ? "Set up two-factor" : "Add another method",
          isLoading: state.isLoading,
          identifier: "add-factor-button",
          action: state.goToEnrollment
        )
      }
    }
  }
}

private struct DemoFactorRow: View {
  let factor: MultiFactorInfo
  let remove: () -> Void

  @AppStorage(DemoThemeID.storageKey) private var themeID: DemoThemeID = .doggo

  var body: some View {
    let theme = themeID.theme
    let shape = RoundedRectangle(cornerRadius: theme.fieldCornerRadius)
    HStack(spacing: 16) {
      VStack(alignment: .leading, spacing: 2) {
        Text(factor.displayName ?? "Second step")
          .demoText(theme.fieldText)
        Text(factor.factorID == PhoneMultiFactorID
          ? (factor as? PhoneMultiFactorInfo)?.phoneNumber ?? "Text message"
          : "Authenticator app")
          .font(theme.fieldText.font(relativeTo: .footnote))
          .foregroundStyle(theme.fieldPlaceholder)
      }
      Spacer()
      Button("Remove", action: remove)
        .font(theme.link.font())
        .foregroundStyle(theme.link.color)
        .buttonStyle(.plain)
        .accessibilityIdentifier("remove-factor-button")
    }
    .padding(.horizontal, 16)
    .frame(minHeight: 56)
    .background(theme.fieldFill, in: shape)
    .overlay { shape.strokeBorder(theme.fieldStroke.color, lineWidth: theme.fieldStroke.width) }
  }
}

struct DemoMFAEnrolment: View {
  var body: some View {
    MFAEnrolmentScreen { state in
      switch state.step {
      case .selectFactor:
        DemoPage(title: "Secure your account") {
          DemoBodyText("Add a second step to sign-in, so a password on its own isn't enough.")
          ForEach(state.allowedFactors, id: \.self) { factor in
            DemoChoiceRow(
              title: factor == .sms ? "Text message" : "Authenticator app",
              isSelected: state.selectedFactorType.wrappedValue == factor,
              identifier: factor == .sms ? "sms-factor-button" : "totp-factor-button"
            ) {
              state.selectedFactorType.wrappedValue = factor
            }
          }
          DemoErrorText(message: state.isMFAEnabled
            ? state.errorMessage
            : "Two-factor sign-in isn't enabled for this app.")
          DemoButton(
            title: "Continue",
            isLoading: state.isLoading,
            identifier: "start-enrollment-button",
            action: state.startEnrollment
          )
          .disabled(!state.isValid)
        }
      case .enterPhoneNumber:
        DemoPage(title: "Add your number") {
          DemoBodyText("We'll text a code to this number whenever you sign in.")
          displayNameField(state)
          DemoPhoneNumberField(phoneNumber: state.phoneNumber, country: state.selectedCountry)
          DemoErrorText(message: state.errorMessage)
          DemoButton(
            title: "Send code",
            isLoading: state.isLoading,
            identifier: "send-code-button",
            action: state.sendCode
          )
          .disabled(!state.isValid)
        }
      case .enterVerificationCode:
        DemoPage(title: "Confirm the code") {
          DemoBodyText("We sent a code to \(state.sentPhoneNumber ?? "your phone").")
          DemoCodeField(code: state.verificationCode, identifier: "verification-code-field")
          DemoErrorText(message: state.errorMessage)
          DemoButton(
            title: "Verify",
            isLoading: state.isLoading,
            identifier: "enroll-button",
            action: state.enroll
          )
          .disabled(!state.isValid)
          DemoLink(
            title: "Resend code",
            alignment: .leading,
            identifier: "resend-code-button",
            action: state.sendCode
          )
        }
      case .setUpTOTP:
        DemoPage(title: "Scan to set up") {
          DemoBodyText("Scan this with your authenticator app, or type the key in by hand.")
          if let url = state.totpQRCodeURL, let qrCode = DemoQRCode(url: url) {
            qrCode
          }
          if let secret = state.totpSecret {
            DemoLink(
              title: state.didCopySecret ? "Copied" : secret,
              alignment: .center,
              identifier: "totp-secret",
              action: state.copySecret
            )
          }
          displayNameField(state)
          DemoCodeField(code: state.totpCode, identifier: "totp-code-field")
          DemoErrorText(message: state.errorMessage)
          DemoButton(
            title: "Verify",
            isLoading: state.isLoading,
            identifier: "enroll-button",
            action: state.enroll
          )
          .disabled(!state.isValid)
        }
      }
    }
  }

  private func displayNameField(_ state: MFAEnrollmentContentState) -> some View {
    DemoTextField(
      icon: "person",
      placeholder: "Name this method",
      text: state.displayName,
      identifier: "display-name-field"
    )
  }
}

struct DemoMFAResolution: View {
  let mfaRequired: MFARequired

  var body: some View {
    MFAResolutionScreen(mfaRequired: mfaRequired) { state in
      DemoPage(title: "One more step") {
        if state.hints.count > 1 {
          ForEach(Array(state.hints.enumerated()), id: \.offset) { index, hint in
            DemoChoiceRow(
              title: label(for: hint),
              isSelected: state.selectedHintIndex.wrappedValue == index,
              identifier: "hint-\(index)-button"
            ) {
              state.selectedHintIndex.wrappedValue = index
            }
          }
        }
        if let hint = selectedHint(state) {
          switch hint {
          case let .phone(_, _, phoneNumber):
            if state.isCodeSent {
              DemoBodyText("We sent a code to \(phoneNumber ?? "your phone").")
              DemoCodeField(code: state.verificationCode, identifier: "verification-code-field")
            } else {
              DemoBodyText("We'll text a code to \(phoneNumber ?? "your phone").")
            }
          case .totp:
            DemoBodyText("Enter the 6-digit code your authenticator app is showing right now.")
            DemoCodeField(code: state.totpCode, identifier: "totp-code-field")
          }
        }
        DemoErrorText(message: state.errorMessage)
        if case .phone = selectedHint(state), !state.isCodeSent {
          DemoButton(
            title: "Send code",
            isLoading: state.isLoading,
            identifier: "send-code-button",
            action: state.sendCode
          )
        } else {
          DemoButton(
            title: "Verify",
            isLoading: state.isLoading,
            identifier: "resolve-button",
            action: state.resolve
          )
          .disabled(!state.isValid)
        }
        DemoLink(
          title: "Cancel",
          alignment: .leading,
          identifier: "cancel-button",
          action: state.cancel
        )
      }
    }
  }

  private func selectedHint(_ state: MFAResolutionContentState) -> MFAHint? {
    let index = state.selectedHintIndex.wrappedValue
    return state.hints.indices.contains(index) ? state.hints[index] : nil
  }

  private func label(for hint: MFAHint) -> String {
    switch hint {
    case let .phone(displayName, _, _): displayName ?? "Text message"
    case let .totp(displayName, _): displayName ?? "Authenticator app"
    }
  }
}

/// A choice between second factors, drawn in the text field's style.
private struct DemoChoiceRow: View {
  let title: String
  let isSelected: Bool
  var identifier: String
  let action: () -> Void

  @AppStorage(DemoThemeID.storageKey) private var themeID: DemoThemeID = .doggo

  var body: some View {
    let theme = themeID.theme
    let shape = RoundedRectangle(cornerRadius: theme.fieldCornerRadius)
    Button(action: action) {
      HStack {
        Text(title)
          .demoText(theme.fieldText)
        Spacer()
        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
          .foregroundStyle(theme.fieldIcon)
      }
      .padding(.horizontal, 16)
      .frame(minHeight: 56)
      .background(theme.fieldFill, in: shape)
      .overlay {
        shape.strokeBorder(theme.fieldStroke.color, lineWidth: theme.fieldStroke.width)
      }
    }
    .buttonStyle(.plain)
    .accessibilityAddTraits(isSelected ? .isSelected : [])
    .accessibilityIdentifier(identifier)
  }
}

/// A QR code for the TOTP setup URL, drawn with Core Image.
private struct DemoQRCode: View {
  let image: UIImage

  init?(url: URL) {
    let filter = CIFilter.qrCodeGenerator()
    filter.message = Data(url.absoluteString.utf8)
    guard let output = filter.outputImage?.transformed(by: CGAffineTransform(scaleX: 8, y: 8)),
          let cgImage = CIContext().createCGImage(output, from: output.extent) else {
      return nil
    }
    image = UIImage(cgImage: cgImage)
  }

  var body: some View {
    Image(uiImage: image)
      .interpolation(.none)
      .resizable()
      .frame(width: 176, height: 176)
      .padding(12)
      .background(.white, in: RoundedRectangle(cornerRadius: 24))
      .frame(maxWidth: .infinity)
      .accessibilityLabel("QR code for your authenticator app")
      .accessibilityIdentifier("totp-qr-code")
  }
}
