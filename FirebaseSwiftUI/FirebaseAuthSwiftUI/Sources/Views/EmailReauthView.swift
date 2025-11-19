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
public struct EmailReauthView {
  @Environment(AuthService.self) private var authService
  @Environment(\.reportError) private var reportError

  let email: String
  let coordinator: ReauthenticationCoordinator

  @State private var password = ""
  @State private var isLoading = false
  @State private var error: AlertError?

  private func verifyPassword() {
    guard !password.isEmpty else { return }

    Task { @MainActor in
      isLoading = true
      do {
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        try await authService.reauthenticate(with: credential)
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

extension EmailReauthView: View {
  public var body: some View {
    NavigationStack {
      VStack(spacing: 24) {
        // Header
        VStack(spacing: 12) {
          Image(systemName: "lock.circle.fill")
            .font(.system(size: 60))
            .foregroundColor(.blue)

          Text("Confirm Password")
            .font(.title)
            .fontWeight(.bold)

          Text("For security, please enter your password")
            .font(.body)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
        }
        .padding()

        VStack(spacing: 20) {
          Text("Email: \(email)")
            .font(.caption)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 8)

          AuthTextField(
            text: $password,
            label: authService.string.passwordFieldLabel,
            prompt: authService.string.passwordInputLabel,
            contentType: .password,
            isSecureTextField: true,
            onSubmit: { _ in
              verifyPassword()
            },
            leading: {
              Image(systemName: "lock")
            }
          )
          .submitLabel(.done)
          .accessibilityIdentifier("email-reauth-password-field")

          Button(action: verifyPassword) {
            if isLoading {
              ProgressView()
                .frame(height: 32)
                .frame(maxWidth: .infinity)
            } else {
              Text("Confirm")
                .frame(height: 32)
                .frame(maxWidth: .infinity)
            }
          }
          .buttonStyle(.borderedProminent)
          .disabled(password.isEmpty || isLoading)
          .accessibilityIdentifier("confirm-password-button")

          Button(authService.string.cancelButtonLabel) {
            coordinator.reauthCancelled()
          }
        }
        .padding(.horizontal)

        Spacer()
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
      .navigationBarTitleDisplayMode(.inline)
    }
    .errorAlert(error: $error, okButtonLabel: authService.string.okButtonLabel)
  }
}

#Preview {
  FirebaseOptions.dummyConfigurationForPreview()
  return EmailReauthView(
    email: "test@example.com",
    coordinator: ReauthenticationCoordinator()
  )
  .environment(AuthService())
}
