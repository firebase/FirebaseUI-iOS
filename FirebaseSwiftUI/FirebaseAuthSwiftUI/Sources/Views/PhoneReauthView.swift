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

@preconcurrency import FirebaseAuth
import FirebaseAuthUIComponents
import FirebaseCore
import SwiftUI

@MainActor
public struct PhoneReauthView {
  @Environment(AuthService.self) private var authService
  @Environment(\.reportError) private var reportError

  let phoneNumber: String
  let coordinator: ReauthenticationCoordinator

  @State private var verificationID: String?
  @State private var verificationCode = ""
  @State private var isLoading = false
  @State private var error: AlertError?

  private func sendSMS() {
    Task { @MainActor in
      isLoading = true
      do {
        let vid = try await authService.verifyPhoneNumber(phoneNumber: phoneNumber)
        verificationID = vid
        isLoading = false
      } catch {
        if let reportError = reportError {
          reportError(error)
        } else {
          self.error = AlertError(
            title: "Error",
            message: error.localizedDescription,
            underlyingError: error
          )
        }
        isLoading = false
      }
    }
  }

  private func verifyCode() {
    guard let verificationID = verificationID else { return }

    Task { @MainActor in
      isLoading = true
      do {
        guard let user = authService.currentUser else {
          throw AuthServiceError.noCurrentUser
        }

        let credential = PhoneAuthProvider.provider()
          .credential(withVerificationID: verificationID, verificationCode: verificationCode)

        try await user.reauthenticate(with: credential)
        coordinator.reauthCompleted()
        isLoading = false
      } catch {
        if let reportError = reportError {
          reportError(error)
        } else {
          self.error = AlertError(
            title: "Error",
            message: error.localizedDescription,
            underlyingError: error
          )
        }
        isLoading = false
      }
    }
  }
}

extension PhoneReauthView: View {
  public var body: some View {
    NavigationStack {
      VStack(spacing: 24) {
        // Header
        VStack(spacing: 12) {
          Image(systemName: "phone.circle.fill")
            .font(.system(size: 60))
            .foregroundColor(.blue)

          Text("Verify Phone Number")
            .font(.title)
            .fontWeight(.bold)

          Text("For security, please verify your phone number")
            .font(.body)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
        }
        .padding()

        if verificationID == nil {
          // Initial state - sending SMS
          VStack(spacing: 16) {
            Text("We'll send a verification code to:")
              .font(.subheadline)
              .foregroundStyle(.secondary)
              .frame(maxWidth: .infinity, alignment: .leading)

            Text(phoneNumber)
              .font(.headline)
              .frame(maxWidth: .infinity, alignment: .leading)
              .padding(.bottom, 8)

            Button(action: {
              sendSMS()
            }) {
              if isLoading {
                ProgressView()
                  .frame(height: 32)
                  .frame(maxWidth: .infinity)
              } else {
                Text("Send Verification Code")
                  .frame(height: 32)
                  .frame(maxWidth: .infinity)
              }
            }
            .buttonStyle(.borderedProminent)
            .disabled(isLoading)
            .accessibilityIdentifier("send-verification-code-button")
          }
          .padding(.horizontal)
        } else {
          // Enter verification code
          VStack(spacing: 16) {
            Text("Enter the 6-digit code sent to:")
              .font(.subheadline)
              .foregroundStyle(.secondary)
              .frame(maxWidth: .infinity, alignment: .leading)

            Text(phoneNumber)
              .font(.caption)
              .frame(maxWidth: .infinity, alignment: .leading)
              .padding(.bottom, 8)

            VerificationCodeInputField(
              code: $verificationCode,
              validations: [
                FormValidators.verificationCode,
              ],
              maintainsValidationMessage: true
            )
            .accessibilityIdentifier("verification-code-field")

            Button(action: {
              verifyCode()
            }) {
              if isLoading {
                ProgressView()
                  .frame(height: 32)
                  .frame(maxWidth: .infinity)
              } else {
                Text("Verify")
                  .frame(height: 32)
                  .frame(maxWidth: .infinity)
              }
            }
            .buttonStyle(.borderedProminent)
            .disabled(verificationCode.count != 6 || isLoading)
            .accessibilityIdentifier("verify-button")

            Button(action: {
              sendSMS()
            }) {
              Text("Resend Code")
                .frame(height: 32)
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .disabled(isLoading)
            .accessibilityIdentifier("resend-code-button")
          }
          .padding(.horizontal)
        }

        Spacer()

        Button(authService.string.cancelButtonLabel) {
          coordinator.reauthCancelled()
        }
        .padding(.horizontal)
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
      .navigationBarTitleDisplayMode(.inline)
    }
    .errorAlert(error: $error, okButtonLabel: authService.string.okButtonLabel)
  }
}

#Preview {
  FirebaseOptions.dummyConfigurationForPreview()
  return PhoneReauthView(
    phoneNumber: "+1234567890",
    coordinator: ReauthenticationCoordinator()
  )
  .environment(AuthService())
}
