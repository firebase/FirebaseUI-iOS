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
import FirebaseAuthUIComponents
import FirebaseCore
import SwiftUI

private enum FocusableField: Hashable {
  case phoneNumber
  case verificationCode
  case totpCode
}

@MainActor
public struct MFAEnrolmentView {
  @Environment(AuthService.self) private var authService

  @State private var selectedFactorType: SecondFactorType = .sms
  @State private var phoneNumber = ""
  @State private var selectedCountry: CountryData = .default
  @State private var verificationCode = ""
  @State private var totpCode = ""
  @State private var currentSession: EnrollmentSession?
  @State private var isLoading = false
  @State private var displayName = ""
  @State private var showCopiedFeedback = false

  @FocusState private var focus: FocusableField?

  public init() {}

  private var allowedFactorTypes: [SecondFactorType] {
    return Array(authService.configuration.allowedSecondFactors).sorted { lhs, rhs in
      // Sort SMS first, then TOTP
      switch (lhs, rhs) {
      case (.sms, .totp): return true
      case (.totp, .sms): return false
      default: return false
      }
    }
  }

  private var canStartEnrollment: Bool {
    !isLoading && currentSession == nil && authService.configuration.mfaEnabled
  }

  private var canSendSMSVerification: Bool {
    currentSession?.type == .sms &&
      currentSession?.status == .initiated &&
      !phoneNumber.isEmpty &&
      !displayName.isEmpty &&
      !isLoading
  }

  private var canCompleteEnrollment: Bool {
    guard let session = currentSession, !isLoading else { return false }

    switch session.type {
    case .sms:
      return session.status == .verificationSent && !verificationCode.isEmpty && !displayName
        .isEmpty
    case .totp:
      return session.status == .initiated && !totpCode.isEmpty && !displayName.isEmpty
    }
  }

  private func startEnrollment() {
    Task {
      isLoading = true
      defer { isLoading = false }

      let session = try await authService.startMfaEnrollment(
        type: selectedFactorType,
        accountName: authService.currentUser?.email,
        issuer: authService.configuration.mfaIssuer
      )
      currentSession = session
    }
  }

  private func sendSMSVerification() {
    guard let session = currentSession else { return }

    Task {
      isLoading = true
      defer { isLoading = false }

      let fullPhoneNumber = selectedCountry.dialCode + phoneNumber
      let verificationId = try await authService.sendSmsVerificationForEnrollment(
        session: session,
        phoneNumber: fullPhoneNumber
      )
      // Update session status
      currentSession = EnrollmentSession(
        id: session.id,
        type: session.type,
        session: session.session,
        totpInfo: session.totpInfo,
        phoneNumber: fullPhoneNumber,
        verificationId: verificationId,
        status: .verificationSent,
        createdAt: session.createdAt,
        expiresAt: session.expiresAt
      )
    }
  }

  private func completeEnrollment() {
    guard let session = currentSession else { return }

    Task {
      isLoading = true
      defer { isLoading = false }

      let code = session.type == .sms ? verificationCode : totpCode
      try await authService.completeEnrollment(
        session: session,
        verificationId: session.verificationId,
        verificationCode: code,
        displayName: displayName
      )

      // Reset form state on success
      resetForm()

      authService.navigator.clear()
    }
  }

  private func resetForm() {
    currentSession = nil
    phoneNumber = ""
    selectedCountry = .default
    verificationCode = ""
    totpCode = ""
    displayName = ""
    focus = nil
  }

  private func copyToClipboard(_ text: String) {
    UIPasteboard.general.string = text

    // Show feedback
    showCopiedFeedback = true

    // Quickly show it has been copied to the clipboard
    Task {
      try? await Task.sleep(nanoseconds: 500_000_000)
      showCopiedFeedback = false
    }
  }

  private func generateQRCode(from string: String) -> UIImage? {
    let data = Data(string.utf8)

    guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
    filter.setValue(data, forKey: "inputMessage")
    filter.setValue("H", forKey: "inputCorrectionLevel")

    guard let ciImage = filter.outputImage else { return nil }

    // Scale up the QR code for better quality
    let transform = CGAffineTransform(scaleX: 10, y: 10)
    let scaledImage = ciImage.transformed(by: transform)

    let context = CIContext()
    guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else {
      return nil
    }

    return UIImage(cgImage: cgImage)
  }
}

extension MFAEnrolmentView: View {
  public var body: some View {
    VStack(spacing: 24) {
      // Header (only shown when no session is active)
      if currentSession == nil {
        VStack(spacing: 8) {
          Text("Set Up Two-Factor Authentication")
            .font(.largeTitle)
            .fontWeight(.bold)
            .multilineTextAlignment(.center)

          Text("Add an extra layer of security to your account")
            .font(.subheadline)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
        }
      }

      // Factor Type Selection (only if no session started)
      if currentSession == nil {
        if !authService.configuration.mfaEnabled {
          VStack(spacing: 12) {
            Image(systemName: "lock.slash")
              .font(.system(size: 40))
              .foregroundColor(.orange)

            Text("Multi-Factor Authentication Disabled")
              .font(.title2)
              .fontWeight(.semibold)

            Text(
              "MFA is not enabled in the current configuration. Please contact your administrator."
            )
            .font(.body)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
          }
          .accessibilityIdentifier("mfa-disabled-message")
        } else if allowedFactorTypes.isEmpty {
          VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
              .font(.system(size: 40))
              .foregroundColor(.orange)

            Text("No Authentication Methods Available")
              .font(.title2)
              .fontWeight(.semibold)

            Text("No MFA methods are configured as allowed. Please contact your administrator.")
              .font(.body)
              .foregroundColor(.secondary)
              .multilineTextAlignment(.center)
          }
          .accessibilityIdentifier("no-factors-message")
        } else {
          VStack(alignment: .leading, spacing: 12) {
            Text("Choose Authentication Method")
              .font(.headline)

            Picker("Authentication Method", selection: $selectedFactorType) {
              ForEach(allowedFactorTypes, id: \.self) { factorType in
                switch factorType {
                case .sms:
                  Image(systemName: "message").tag(SecondFactorType.sms)
                case .totp:
                  Image(systemName: "qrcode").tag(SecondFactorType.totp)
                }
              }
            }
            .pickerStyle(.segmented)
            .accessibilityIdentifier("factor-type-picker")
          }
        }
      }

      // Content based on current state
      if let session = currentSession {
        enrollmentContent(for: session)
      } else {
        initialContent
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    .safeAreaPadding()
    .navigationTitle("Two-Factor Authentication")
    .onAppear {
      // Initialize selected factor type to first allowed type
      if !allowedFactorTypes.contains(selectedFactorType),
         let firstAllowed = allowedFactorTypes.first {
        selectedFactorType = firstAllowed
      }
    }
  }

  @ViewBuilder
  private var initialContent: some View {
    VStack(spacing: 24) {
      // Description based on selected type
      if selectedFactorType == .sms {
        VStack(spacing: 8) {
          Image(systemName: "message.circle")
            .font(.system(size: 40))
            .foregroundColor(.blue)

          Text("SMS Authentication")
            .font(.title2)
            .fontWeight(.semibold)

          Text("We'll send a verification code to your phone number each time you sign in.")
            .font(.body)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
        }
      } else {
        VStack(spacing: 8) {
          Image(systemName: "qrcode")
            .font(.system(size: 40))
            .foregroundColor(.green)

          Text("Authenticator App")
            .font(.title2)
            .fontWeight(.semibold)

          Text(
            "Use an authenticator app like Google Authenticator or Authy to generate verification codes."
          )
          .font(.body)
          .foregroundColor(.secondary)
          .multilineTextAlignment(.center)
        }
      }

      Button {
        startEnrollment()
      } label: {
        HStack {
          if isLoading {
            ProgressView()
              .scaleEffect(0.8)
          }
          Text("Get Started")
        }
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
      }
      .buttonStyle(.borderedProminent)
      .disabled(!canStartEnrollment)
      .padding([.top, .bottom], 8)
      .frame(maxWidth: .infinity)
      .accessibilityIdentifier("start-enrollment-button")
    }
  }

  @ViewBuilder
  private func enrollmentContent(for session: EnrollmentSession) -> some View {
    switch session.type {
    case .sms:
      smsEnrollmentContent(session: session)
    case .totp:
      totpEnrollmentContent(session: session)
    }
  }

  @ViewBuilder
  private func smsEnrollmentContent(session: EnrollmentSession) -> some View {
    VStack(spacing: 24) {
      // SMS enrollment steps
      if session.status == .initiated {
        VStack(spacing: 24) {
          VStack(spacing: 8) {
            Image(systemName: "phone")
              .font(.system(size: 48))
              .foregroundColor(.blue)

            Text("Enter Your Phone Number")
              .font(.title2)
              .fontWeight(.semibold)

            Text("We'll send a verification code to this number")
              .font(.body)
              .foregroundColor(.secondary)
              .multilineTextAlignment(.center)
          }

          AuthTextField(
            text: $phoneNumber,
            label: authService.string.phoneNumberFieldLabel,
            prompt: authService.string.enterPhoneNumberPrompt,
            keyboardType: .phonePad,
            contentType: .telephoneNumber,
            onChange: { _ in }
          ) {
            CountrySelector(
              selectedCountry: $selectedCountry,
              enabled: !isLoading
            )
          }
          .focused($focus, equals: .phoneNumber)
          .accessibilityIdentifier("phone-number-field")

          AuthTextField(
            text: $displayName,
            label: authService.string.displayNameFieldLabel,
            prompt: authService.string.enterDisplayNameForDevicePrompt,
            leading: {
              Image(systemName: "person")
            }
          )
          .accessibilityIdentifier("display-name-field")

          Button {
            sendSMSVerification()
          } label: {
            HStack {
              if isLoading {
                ProgressView()
                  .scaleEffect(0.8)
              }
              Text("Send Code")
            }
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
          }
          .buttonStyle(.borderedProminent)
          .disabled(!canSendSMSVerification)
          .padding([.top, .bottom], 8)
          .frame(maxWidth: .infinity)
          .accessibilityIdentifier("send-sms-button")
        }
      } else if session.status == .verificationSent {
        VStack(spacing: 24) {
          VStack(spacing: 8) {
            Image(systemName: "checkmark.message")
              .font(.system(size: 48))
              .foregroundColor(.green)

            Text("Enter Verification Code")
              .font(.title2)
              .fontWeight(.semibold)

            Text("We sent a code to \(session.phoneNumber ?? "your phone")")
              .font(.body)
              .foregroundColor(.secondary)
              .multilineTextAlignment(.center)
          }

          AuthTextField(
            text: $verificationCode,
            label: authService.string.verificationCodeFieldLabel,
            prompt: "Enter 6-digit code",
            keyboardType: .numberPad,
            contentType: .oneTimeCode,
            leading: {
              Image(systemName: "number")
            }
          )
          .focused($focus, equals: .verificationCode)
          .accessibilityIdentifier("verification-code-field")

          Button {
            completeEnrollment()
          } label: {
            HStack {
              if isLoading {
                ProgressView()
                  .scaleEffect(0.8)
              }
              Text("Complete Setup")
            }
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
          }
          .buttonStyle(.borderedProminent)
          .disabled(!canCompleteEnrollment)
          .padding([.top, .bottom], 8)
          .frame(maxWidth: .infinity)
          .accessibilityIdentifier("complete-enrollment-button")

          Button {
            sendSMSVerification()
          } label: {
            Text("Resend Code")
              .padding(.vertical, 8)
              .frame(maxWidth: .infinity)
          }
          .buttonStyle(.bordered)
          .padding([.top, .bottom], 8)
          .frame(maxWidth: .infinity)
          .accessibilityIdentifier("resend-code-button")
        }
      }
    }
  }

  @ViewBuilder
  private func totpEnrollmentContent(session: EnrollmentSession) -> some View {
    VStack(spacing: 16) {
      if let totpInfo = session.totpInfo {
        VStack(spacing: 16) {
          VStack(spacing: 6) {
            Image(systemName: "qrcode")
              .font(.system(size: 40))
              .foregroundColor(.green)

            Text("Scan QR Code")
              .font(.title2)
              .fontWeight(.semibold)

            Text("Scan with your authenticator app or tap to open directly")
              .font(.body)
              .foregroundColor(.secondary)
              .multilineTextAlignment(.center)
              .lineLimit(nil)
              .padding(.horizontal)
          }

          // QR Code generated from the otpauth:// URI
          if let qrURL = totpInfo.qrCodeURL,
             let qrImage = generateQRCode(from: qrURL.absoluteString) {
            Button(action: {
              UIApplication.shared.open(qrURL)
            }) {
              VStack(spacing: 8) {
                Image(uiImage: qrImage)
                  .interpolation(.none)
                  .resizable()
                  .aspectRatio(contentMode: .fit)
                  .frame(width: 180, height: 180)
                  .accessibilityIdentifier("qr-code-image")

                HStack(spacing: 6) {
                  Image(systemName: "arrow.up.forward.app.fill")
                    .font(.caption)
                  Text("Tap to open in authenticator app")
                    .font(.caption)
                    .fontWeight(.medium)
                }
                .foregroundColor(.blue)
              }
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("open-authenticator-button")
          } else {
            RoundedRectangle(cornerRadius: 8)
              .fill(Color.gray.opacity(0.3))
              .frame(width: 180, height: 180)
              .overlay(
                VStack {
                  Image(systemName: "exclamationmark.triangle")
                    .font(.title)
                    .foregroundColor(.orange)
                  Text("Unable to generate QR Code")
                    .font(.caption)
                }
              )
          }

          VStack(spacing: 6) {
            Text("Manual Entry Key:")
              .font(.headline)

            Button(action: {
              copyToClipboard(totpInfo.sharedSecretKey)
            }) {
              HStack {
                Text(totpInfo.sharedSecretKey)
                  .font(.system(.body, design: .monospaced))
                  .lineLimit(1)
                  .minimumScaleFactor(0.5)

                Spacer()

                Image(systemName: showCopiedFeedback ? "checkmark" : "doc.on.doc")
                  .foregroundColor(showCopiedFeedback ? .green : .blue)
              }
              .padding()
              .background(Color.gray.opacity(0.1))
              .cornerRadius(8)
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("totp-secret-key")

            if showCopiedFeedback {
              Text("Copied to clipboard!")
                .font(.caption)
                .foregroundColor(.green)
                .transition(.opacity)
            }
          }
          .animation(.easeInOut(duration: 0.2), value: showCopiedFeedback)

          AuthTextField(
            text: $displayName,
            label: authService.string.displayNameFieldLabel,
            prompt: authService.string.enterDisplayNameForAuthenticatorPrompt,
            leading: {
              Image(systemName: "person")
            }
          )
          .accessibilityIdentifier("display-name-field")

          AuthTextField(
            text: $totpCode,
            label: authService.string.verificationCodeFieldLabel,
            prompt: authService.string.enterCodeFromAppPrompt,
            keyboardType: .numberPad,
            contentType: .oneTimeCode,
            leading: {
              Image(systemName: "number")
            }
          )
          .focused($focus, equals: .totpCode)
          .accessibilityIdentifier("totp-code-field")

          Button {
            completeEnrollment()
          } label: {
            HStack {
              if isLoading {
                ProgressView()
                  .scaleEffect(0.8)
              }
              Text("Complete Setup")
            }
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
          }
          .buttonStyle(.borderedProminent)
          .disabled(!canCompleteEnrollment)
          .padding([.top, .bottom], 8)
          .frame(maxWidth: .infinity)
          .accessibilityIdentifier("complete-enrollment-button")
        }
      }
    }
  }
}

#Preview("MFA Enabled - Both Methods") {
  FirebaseOptions.dummyConfigurationForPreview()
  let config = AuthConfiguration(
    mfaEnabled: true,
    allowedSecondFactors: [.sms, .totp]
  )
  let authService = AuthService(configuration: config)
  return MFAEnrolmentView()
    .environment(authService)
}

#Preview("MFA Disabled") {
  FirebaseOptions.dummyConfigurationForPreview()
  let config = AuthConfiguration(
    mfaEnabled: false,
    allowedSecondFactors: []
  )
  let authService = AuthService(configuration: config)
  return MFAEnrolmentView()
    .environment(authService)
}

#Preview("No Allowed Factors") {
  FirebaseOptions.dummyConfigurationForPreview()
  let config = AuthConfiguration(
    mfaEnabled: true,
    allowedSecondFactors: []
  )
  let authService = AuthService(configuration: config)
  return MFAEnrolmentView()
    .environment(authService)
}

#Preview("SMS Only") {
  FirebaseOptions.dummyConfigurationForPreview()
  let config = AuthConfiguration(
    mfaEnabled: true,
    allowedSecondFactors: [.sms]
  )
  let authService = AuthService(configuration: config)
  return MFAEnrolmentView()
    .environment(authService)
}

#Preview("TOTP Only") {
  FirebaseOptions.dummyConfigurationForPreview()
  let config = AuthConfiguration(
    mfaEnabled: true,
    allowedSecondFactors: [.totp]
  )
  let authService = AuthService(configuration: config)
  return MFAEnrolmentView()
    .environment(authService)
}
