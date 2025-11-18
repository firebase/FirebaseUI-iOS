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
    Task {
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

    Task {
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

          Text(phoneNumber)
            .font(.headline)
            .foregroundColor(.primary)
        }
        .padding()

        if verificationID == nil {
          // Send SMS button
          Button("Send Verification Code") {
            sendSMS()
          }
          .buttonStyle(.borderedProminent)
          .disabled(isLoading)
          .padding()
          .accessibilityIdentifier("send-verification-code-button")
        } else {
          // Enter verification code
          AuthTextField(
            text: $verificationCode,
            label: "Verification Code",
            prompt: "Enter 6-digit code",
            contentType: .oneTimeCode,
            keyboardType: .numberPad,
            leading: {
              Image(systemName: "number")
            }
          )
          .padding(.horizontal)
          .accessibilityIdentifier("verification-code-field")

          Button("Verify") {
            verifyCode()
          }
          .buttonStyle(.borderedProminent)
          .disabled(verificationCode.isEmpty || isLoading)
          .padding()
          .accessibilityIdentifier("verify-button")

          Button("Resend Code") {
            sendSMS()
          }
          .buttonStyle(.bordered)
          .disabled(isLoading)
          .accessibilityIdentifier("resend-code-button")
        }

        Spacer()
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel") {
            coordinator.reauthCancelled()
          }
        }
      }
    }
    .errorAlert(error: $error, okButtonLabel: authService.string.okButtonLabel)
    .onAppear {
      // Auto-send SMS on appear for better UX
      sendSMS()
    }
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
