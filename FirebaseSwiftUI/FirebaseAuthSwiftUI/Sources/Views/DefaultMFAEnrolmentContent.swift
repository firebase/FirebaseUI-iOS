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

import FirebaseAuthUIComponents
import SwiftUI

private enum FocusableField: Hashable {
  case phoneNumber
  case verificationCode
  case totpCode
}

/// The stock content of ``MFAEnrolmentScreen``.
@MainActor
public struct DefaultMFAEnrolmentContent: View {
  public init(state: MFAEnrollmentContentState) {
    self.state = state
  }

  @Environment(AuthService.self) private var authService
  @FocusState private var focus: FocusableField?
  private let state: MFAEnrollmentContentState

  public var body: some View {
    VStack(spacing: 24) {
      // Header (only shown when no session is active)
      if state.step == .selectFactor {
        VStack(spacing: 8) {
          Text("Set Up Two-Factor Authentication")
            .authFont(.largeTitle)
            .fontWeight(.bold)
            .multilineTextAlignment(.center)

          Text("Add an extra layer of security to your account")
            .authFont(.subheadline)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
        }
      }

      // Factor Type Selection (only if no session started)
      if state.step == .selectFactor {
        if !state.isMFAEnabled {
          VStack(spacing: 12) {
            Image(systemName: "lock.slash")
              .font(.system(size: 40))
              .foregroundColor(.orange)

            Text("Multi-Factor Authentication Disabled")
              .authFont(.title2)
              .fontWeight(.semibold)

            Text(
              "MFA is not enabled in the current configuration. Please contact your administrator."
            )
            .authFont(.body)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
          }
          .accessibilityIdentifier("mfa-disabled-message")
        } else if state.allowedFactors.isEmpty {
          VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
              .font(.system(size: 40))
              .foregroundColor(.orange)

            Text("No Authentication Methods Available")
              .authFont(.title2)
              .fontWeight(.semibold)

            Text("No MFA methods are configured as allowed. Please contact your administrator.")
              .authFont(.body)
              .foregroundColor(.secondary)
              .multilineTextAlignment(.center)
          }
          .accessibilityIdentifier("no-factors-message")
        } else {
          VStack(alignment: .leading, spacing: 12) {
            Text("Choose Authentication Method")
              .authFont(.headline)

            Picker("Authentication Method", selection: state.selectedFactorType) {
              ForEach(state.allowedFactors, id: \.self) { factorType in
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
      switch state.step {
      case .selectFactor:
        initialContent
      case .enterPhoneNumber, .enterVerificationCode:
        smsEnrollmentContent
      case .setUpTOTP:
        totpEnrollmentContent
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    .safeAreaPadding()
    .navigationTitle("Two-Factor Authentication")
    .onChange(of: state.step) { focus = nil }
  }

  private var initialContent: some View {
    VStack(spacing: 24) {
      // Description based on selected type
      if state.selectedFactorType.wrappedValue == .sms {
        VStack(spacing: 8) {
          Image(systemName: "message.circle")
            .font(.system(size: 40))
            .foregroundColor(.blue)

          Text("SMS Authentication")
            .authFont(.title2)
            .fontWeight(.semibold)

          Text("We'll send a verification code to your phone number each time you sign in.")
            .authFont(.body)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
        }
      } else {
        VStack(spacing: 8) {
          Image(systemName: "qrcode")
            .font(.system(size: 40))
            .foregroundColor(.green)

          Text("Authenticator App")
            .authFont(.title2)
            .fontWeight(.semibold)

          Text(
            "Use an authenticator app like Google Authenticator or Authy to generate verification codes."
          )
          .authFont(.body)
          .foregroundColor(.secondary)
          .multilineTextAlignment(.center)
        }
      }

      Button {
        state.startEnrollment()
      } label: {
        HStack {
          if state.isLoading {
            ProgressView()
              .scaleEffect(0.8)
          }
          Text("Get Started")
        }
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
      }
      .authCTAButtonStyle()
      .disabled(!state.isValid || state.isLoading)
      .padding([.top, .bottom], 8)
      .frame(maxWidth: .infinity)
      .accessibilityIdentifier("start-enrollment-button")
    }
  }

  private var smsEnrollmentContent: some View {
    VStack(spacing: 24) {
      // SMS enrollment steps
      if state.step == .enterPhoneNumber {
        VStack(spacing: 24) {
          VStack(spacing: 8) {
            Image(systemName: "phone")
              .font(.system(size: 48))
              .foregroundColor(.blue)

            Text("Enter Your Phone Number")
              .authFont(.title2)
              .fontWeight(.semibold)

            Text("We'll send a verification code to this number")
              .authFont(.body)
              .foregroundColor(.secondary)
              .multilineTextAlignment(.center)
          }

          AuthTextField(
            text: state.phoneNumber,
            label: authService.string.phoneNumberFieldLabel,
            prompt: authService.string.enterPhoneNumberPrompt,
            keyboardType: .phonePad,
            contentType: .telephoneNumber,
            validations: [
              FormValidators.phoneNumber,
            ],
            maintainsValidationMessage: true,
            onChange: { _ in }
          ) {
            CountrySelector(
              selectedCountry: state.selectedCountry,
              enabled: !state.isLoading
            )
          }
          .focused($focus, equals: .phoneNumber)
          .accessibilityIdentifier("phone-number-field")

          AuthTextField(
            text: state.displayName,
            label: authService.string.displayNameFieldLabel,
            prompt: authService.string.enterDisplayNameForDevicePrompt,
            validations: [
              FormValidators.notEmpty(label: "Display name"),
            ],
            maintainsValidationMessage: true,
            leading: {
              Image(systemName: "person")
            }
          )
          .accessibilityIdentifier("display-name-field")

          Button {
            state.sendCode()
          } label: {
            HStack {
              if state.isLoading {
                ProgressView()
                  .scaleEffect(0.8)
              }
              Text("Send Code")
            }
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
          }
          .authCTAButtonStyle()
          .disabled(!state.isValid || state.isLoading)
          .padding([.top, .bottom], 8)
          .frame(maxWidth: .infinity)
          .accessibilityIdentifier("send-sms-button")
        }
      } else if state.step == .enterVerificationCode {
        VStack(spacing: 24) {
          VStack(spacing: 8) {
            Image(systemName: "checkmark.message")
              .font(.system(size: 48))
              .foregroundColor(.green)

            Text("Enter Verification Code")
              .authFont(.title2)
              .fontWeight(.semibold)

            Text("We sent a code to \(state.sentPhoneNumber ?? "your phone")")
              .authFont(.body)
              .foregroundColor(.secondary)
              .multilineTextAlignment(.center)
          }

          VerificationCodeInputField(
            code: state.verificationCode,
            validations: [
              FormValidators.verificationCode,
            ],
            maintainsValidationMessage: true
          )
          .accessibilityIdentifier("verification-code-field")

          Button {
            state.enroll()
          } label: {
            HStack {
              if state.isLoading {
                ProgressView()
                  .scaleEffect(0.8)
              }
              Text("Complete Setup")
            }
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
          }
          .authCTAButtonStyle()
          .disabled(!state.isValid || state.isLoading)
          .padding([.top, .bottom], 8)
          .frame(maxWidth: .infinity)
          .accessibilityIdentifier("complete-enrollment-button")

          Button {
            state.sendCode()
          } label: {
            Text("Resend Code")
              .authCustomFont(.body)
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

  private var totpEnrollmentContent: some View {
    VStack(spacing: 16) {
      if let totpSecret = state.totpSecret {
        VStack(spacing: 16) {
          VStack(spacing: 6) {
            Image(systemName: "qrcode")
              .font(.system(size: 40))
              .foregroundColor(.green)

            Text("Scan QR Code")
              .authFont(.title2)
              .fontWeight(.semibold)

            Text("Scan with your authenticator app or tap to open directly")
              .authFont(.body)
              .foregroundColor(.secondary)
              .multilineTextAlignment(.center)
              .lineLimit(nil)
              .padding(.horizontal)
          }

          // QR Code generated from the otpauth:// URI
          if let qrURL = state.totpQRCodeURL,
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
                    .authFont(.caption)
                  Text("Tap to open in authenticator app")
                    .authFont(.caption)
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
                    .authFont(.title)
                    .foregroundColor(.orange)
                  Text("Unable to generate QR Code")
                    .authFont(.caption)
                }
              )
          }

          VStack(spacing: 6) {
            Text("Manual Entry Key:")
              .authFont(.headline)

            Button(action: state.copySecret) {
              HStack {
                Text(totpSecret)
                  .font(.system(.body, design: .monospaced))
                  .lineLimit(1)
                  .minimumScaleFactor(0.5)

                Spacer()

                Image(systemName: state.didCopySecret ? "checkmark" : "doc.on.doc")
                  .foregroundColor(state.didCopySecret ? .green : .blue)
              }
              .padding()
              .background(Color.gray.opacity(0.1))
              .cornerRadius(8)
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("totp-secret-key")

            if state.didCopySecret {
              Text("Copied to clipboard!")
                .authFont(.caption)
                .foregroundColor(.green)
                .transition(.opacity)
            }
          }
          .animation(.easeInOut(duration: 0.2), value: state.didCopySecret)

          AuthTextField(
            text: state.displayName,
            label: authService.string.displayNameFieldLabel,
            prompt: authService.string.enterDisplayNameForAuthenticatorPrompt,
            validations: [
              FormValidators.notEmpty(label: "Display name"),
            ],
            maintainsValidationMessage: true,
            leading: {
              Image(systemName: "person")
            }
          )
          .accessibilityIdentifier("display-name-field")

          VerificationCodeInputField(
            code: state.totpCode,
            validations: [
              FormValidators.verificationCode,
            ],
            maintainsValidationMessage: true
          )
          .accessibilityIdentifier("totp-code-field")

          Button {
            state.enroll()
          } label: {
            HStack {
              if state.isLoading {
                ProgressView()
                  .scaleEffect(0.8)
              }
              Text("Complete Setup")
            }
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
          }
          .authCTAButtonStyle()
          .disabled(!state.isValid || state.isLoading)
          .padding([.top, .bottom], 8)
          .frame(maxWidth: .infinity)
          .accessibilityIdentifier("complete-enrollment-button")
        }
      }
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
