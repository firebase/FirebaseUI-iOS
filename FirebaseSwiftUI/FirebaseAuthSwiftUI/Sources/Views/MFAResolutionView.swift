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
import FirebaseCore
import SwiftUI

private enum FocusableField: Hashable {
  case verificationCode
  case totpCode
}

@MainActor
public struct MFAResolutionView {
  let mfaRequired: MFARequired

  @Environment(AuthService.self) private var authService
  @Environment(\.reportError) private var reportError

  @State private var verificationCode = ""
  @State private var totpCode = ""
  @State private var isLoading = false
  @State private var selectedHintIndex = 0
  @State private var verificationId: String?

  @FocusState private var focus: FocusableField?

  public init(mfaRequired: MFARequired) {
    self.mfaRequired = mfaRequired
  }

  private var selectedHint: MFAHint? {
    guard selectedHintIndex < mfaRequired.hints.count else {
      return nil
    }
    return mfaRequired.hints[selectedHintIndex]
  }

  private var canCompleteResolution: Bool {
    guard !isLoading else { return false }

    switch selectedHint {
    case .phone:
      return !verificationCode.isEmpty
    case .totp:
      return !totpCode.isEmpty
    case .none:
      return false
    }
  }

  private func startSMSChallenge() {
    guard selectedHintIndex < mfaRequired.hints.count else { return }

    Task {
      isLoading = true

      do {
        let verificationId = try await authService.resolveSmsChallenge(hintIndex: selectedHintIndex)
        self.verificationId = verificationId
        isLoading = false
      } catch {
        reportError?(error)
        isLoading = false
      }
    }
  }

  private func completeResolution() {
    Task {
      isLoading = true

      do {
        let code = selectedHint?.isPhoneHint == true ? verificationCode : totpCode
        try await authService.resolveSignIn(
          code: code,
          hintIndex: selectedHintIndex,
          verificationId: verificationId
        )
        // On success, the AuthService will update the authentication state
        // and we should navigate back to the main app
        authService.navigator.clear()
        isLoading = false
      } catch {
        reportError?(error)
        isLoading = false
      }
    }
  }

  private func cancelResolution() {
    authService.navigator.clear()
  }
}

extension MFAResolutionView: View {
  public var body: some View {
    VStack(spacing: 24) {
      // Header
      VStack(spacing: 12) {
        Image(systemName: "lock.shield")
          .font(.system(size: 50))
          .foregroundColor(.blue)

        Text("Two-Factor Authentication")
          .font(.largeTitle)
          .fontWeight(.bold)
          .accessibilityIdentifier("mfa-resolution-title")

        Text("Complete sign-in with your second factor")
          .font(.body)
          .foregroundColor(.secondary)
          .multilineTextAlignment(.center)
      }
      .padding(.horizontal)

      // MFA Hints Selection (if multiple available)
      if mfaRequired.hints.count > 1 {
        mfaHintsSelectionView(mfaRequired: mfaRequired)
      }

      // Resolution Content
      if let hint = selectedHint {
        resolutionContent(for: hint)
      }

      // Action buttons
      VStack(spacing: 12) {
        // Complete Resolution Button
        Button(action: completeResolution) {
          HStack {
            if isLoading {
              ProgressView()
                .scaleEffect(0.8)
            }
            Text("Complete Sign-In")
          }
          .frame(maxWidth: .infinity)
          .padding()
          .background(canCompleteResolution ? Color.blue : Color.gray)
          .foregroundColor(.white)
          .cornerRadius(8)
        }
        .disabled(!canCompleteResolution)
        .accessibilityIdentifier("complete-resolution-button")

        // Cancel Button
        Button(action: cancelResolution) {
          Text("Cancel")
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.gray.opacity(0.2))
            .foregroundColor(.primary)
            .cornerRadius(8)
        }
        .accessibilityIdentifier("cancel-button")
      }
      .padding(.horizontal)
    }
    .padding(.vertical, 20)
  }

  @ViewBuilder
  private func resolutionContent(for hint: MFAHint) -> some View {
    switch hint {
    case let .phone(displayName, _, phoneNumber):
      phoneResolutionContent(displayName: displayName, phoneNumber: phoneNumber)
    case let .totp(displayName, _):
      totpResolutionContent(displayName: displayName)
    }
  }

  @ViewBuilder
  private func phoneResolutionContent(displayName _: String?, phoneNumber: String?) -> some View {
    VStack(spacing: 16) {
      VStack(spacing: 8) {
        Image(systemName: "message.circle.fill")
          .font(.system(size: 40))
          .foregroundColor(.blue)

        Text("SMS Verification")
          .font(.title2)
          .fontWeight(.semibold)

        if let phoneNumber = phoneNumber {
          Text("We'll send a code to ••••••\(String(phoneNumber.suffix(4)))")
            .font(.body)
            .foregroundColor(.secondary)
        } else {
          Text("We'll send a verification code to your phone")
            .font(.body)
            .foregroundColor(.secondary)
        }
      }
      .padding(.horizontal)

      // Send SMS button (if verification ID not yet obtained)
      if verificationId == nil {
        Button(action: startSMSChallenge) {
          HStack {
            if isLoading {
              ProgressView()
                .scaleEffect(0.8)
            }
            Text("Send Code")
          }
          .frame(maxWidth: .infinity)
          .padding()
          .background(isLoading ? Color.gray : Color.blue)
          .foregroundColor(.white)
          .cornerRadius(8)
        }
        .disabled(isLoading)
        .padding(.horizontal)
        .accessibilityIdentifier("send-sms-button")
      } else {
        // Verification code input
        VStack(alignment: .leading, spacing: 8) {
          Text("Verification Code")
            .font(.headline)

          TextField("Enter 6-digit code", text: $verificationCode)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .keyboardType(.numberPad)
            .focused($focus, equals: .verificationCode)
            .accessibilityIdentifier("sms-verification-code-field")
        }
        .padding(.horizontal)
      }
    }
  }

  @ViewBuilder
  private func totpResolutionContent(displayName: String?) -> some View {
    VStack(spacing: 16) {
      VStack(spacing: 8) {
        Image(systemName: "qrcode")
          .font(.system(size: 40))
          .foregroundColor(.green)

        Text("Authenticator App")
          .font(.title2)
          .fontWeight(.semibold)

        Text("Enter the 6-digit code from your authenticator app")
          .font(.body)
          .foregroundColor(.secondary)
          .multilineTextAlignment(.center)

        if let displayName = displayName {
          Text(authService.string.accountPrefix(displayName: displayName))
            .font(.caption)
            .foregroundColor(.secondary)
        }
      }
      .padding(.horizontal)

      // TOTP code input
      VStack(alignment: .leading, spacing: 8) {
        Text("Verification Code")
          .font(.headline)

        TextField("Enter 6-digit code", text: $totpCode)
          .textFieldStyle(RoundedBorderTextFieldStyle())
          .keyboardType(.numberPad)
          .focused($focus, equals: .totpCode)
          .accessibilityIdentifier("totp-verification-code-field")
      }
      .padding(.horizontal)
    }
  }

  @ViewBuilder
  private func mfaHintsSelectionView(mfaRequired: MFARequired) -> some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Choose verification method:")
        .font(.headline)
        .padding(.horizontal)

      // More idiomatic approach using indices
      ForEach(mfaRequired.hints.indices, id: \.self) { index in
        let hint = mfaRequired.hints[index]
        hintSelectionButton(hint: hint, index: index)
      }
    }
  }

  @ViewBuilder
  private func hintSelectionButton(hint: MFAHint, index: Int) -> some View {
    Button(action: {
      selectedHintIndex = index
      // Clear previous input when switching methods
      verificationCode = ""
      totpCode = ""
      verificationId = nil
    }) {
      HStack {
        Image(systemName: hint.isPhoneHint ? "message.circle" : "qrcode")
          .foregroundColor(.blue)

        VStack(alignment: .leading) {
          Text(hintDisplayName(for: hint))
            .font(.body)
            .foregroundColor(.primary)

          hintSubtitle(for: hint)
        }

        Spacer()

        if selectedHintIndex == index {
          Image(systemName: "checkmark.circle.fill")
            .foregroundColor(.blue)
        }
      }
      .padding()
      .background(selectedHintIndex == index ? Color.blue.opacity(0.1) : Color.clear)
      .cornerRadius(8)
      .overlay(
        RoundedRectangle(cornerRadius: 8)
          .stroke(selectedHintIndex == index ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1)
      )
    }
    .buttonStyle(PlainButtonStyle())
    .padding(.horizontal)
    .accessibilityIdentifier("hint-\(index)")
  }

  private func hintDisplayName(for hint: MFAHint) -> String {
    hint.isPhoneHint ? "SMS" : "Authenticator App"
  }

  @ViewBuilder
  private func hintSubtitle(for hint: MFAHint) -> some View {
    if case let .phone(_, _, phoneNumber) = hint, let phone = phoneNumber {
      Text("••••••\(String(phone.suffix(4)))")
        .font(.caption)
        .foregroundColor(.secondary)
    }
  }
}

// Helper extension for MFAHint
private extension MFAHint {
  var isPhoneHint: Bool {
    switch self {
    case .phone:
      return true
    case .totp:
      return false
    }
  }
}

#Preview("Phone SMS Only") {
  FirebaseOptions.dummyConfigurationForPreview()
  let authService = AuthService()
  let mfaRequired = MFARequired(hints: [
    .phone(displayName: "Work Phone", uid: "phone-uid-1", phoneNumber: "+15551234567"),
  ])
  return MFAResolutionView(mfaRequired: mfaRequired).environment(authService)
}

#Preview("TOTP Only") {
  FirebaseOptions.dummyConfigurationForPreview()
  let authService = AuthService()
  let mfaRequired = MFARequired(hints: [
    .totp(displayName: "Authenticator App", uid: "totp-uid-1"),
  ])
  return MFAResolutionView(mfaRequired: mfaRequired).environment(authService)
}

#Preview("Multiple Methods") {
  FirebaseOptions.dummyConfigurationForPreview()
  let authService = AuthService()
  let mfaRequired = MFARequired(hints: [
    .phone(displayName: "Mobile", uid: "phone-uid-1", phoneNumber: "+15551234567"),
    .totp(displayName: "Google Authenticator", uid: "totp-uid-1"),
  ])
  return MFAResolutionView(mfaRequired: mfaRequired).environment(authService)
}

#Preview("Single TOTP") {
  FirebaseOptions.dummyConfigurationForPreview()
  let authService = AuthService()
  let mfaRequired = MFARequired(hints: [
    .totp(displayName: "Authenticator", uid: "totp-uid-1"),
  ])
  return MFAResolutionView(mfaRequired: mfaRequired).environment(authService)
}
