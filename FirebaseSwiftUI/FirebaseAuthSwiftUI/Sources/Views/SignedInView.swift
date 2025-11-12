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

import FirebaseCore
import SwiftUI

@MainActor
public struct SignedInView {
  @Environment(AuthService.self) private var authService
  @Environment(\.reportError) private var reportError
  @State private var showDeleteConfirmation = false
  @State private var showEmailVerificationSent = false

  private func sendEmailVerification() async throws {
    do {
      try await authService.sendEmailVerification()
      showEmailVerificationSent = true
    } catch {
      if let errorHandler = reportError {
        errorHandler(error)
      } else {
        throw error
      }
    }
  }
}

extension SignedInView: View {
  public var body: some View {
    VStack {
      Text(authService.string.signedInTitle)
        .font(.largeTitle)
        .fontWeight(.bold)
        .padding()
        .accessibilityIdentifier("signed-in-text")
      Text(
        "\(authService.currentUser?.email ?? authService.currentUser?.displayName ?? "Unknown")"
      )
      if authService.currentUser?.isEmailVerified == false {
        Button {
          Task {
            try await sendEmailVerification()
          }
        } label: {
          Text(authService.string.sendEmailVerificationButtonLabel)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .padding([.top, .bottom], 8)
        .frame(maxWidth: .infinity)
        .accessibilityIdentifier("verify-email-button")
      }
      Button {
        authService.navigator.push(.updatePassword)
      } label: {
        Text(authService.string.updatePasswordButtonLabel)
          .padding(.vertical, 8)
          .frame(maxWidth: .infinity)
      }
      .buttonStyle(.borderedProminent)
      .padding([.top, .bottom], 8)
      .frame(maxWidth: .infinity)
      .accessibilityIdentifier("update-password-button")

      Button {
        authService.navigator.push(.mfaManagement)
      } label: {
        Text("Manage Two-Factor Authentication")
          .padding(.vertical, 8)
          .frame(maxWidth: .infinity)
      }
      .buttonStyle(.borderedProminent)
      .padding([.top, .bottom], 8)
      .frame(maxWidth: .infinity)
      .accessibilityIdentifier("mfa-management-button")

      Button {
        showDeleteConfirmation = true
      } label: {
        Text(authService.string.deleteAccountButtonLabel)
          .padding(.vertical, 8)
          .frame(maxWidth: .infinity)
      }
      .buttonStyle(.borderedProminent)
      .padding([.top, .bottom], 8)
      .frame(maxWidth: .infinity)
      .accessibilityIdentifier("delete-account-button")

      Button {
        Task {
          do {
            try await authService.signOut()
          } catch {
            if let errorHandler = reportError {
              errorHandler(error)
            } else {
              throw error
            }
          }
        }
      } label: {
        Text(authService.string.signOutButtonLabel)
          .padding(.vertical, 8)
          .frame(maxWidth: .infinity)
      }
      .buttonStyle(.borderedProminent)
      .padding([.top, .bottom], 8)
      .frame(maxWidth: .infinity)
      .accessibilityIdentifier("sign-out-button")
    }
    .safeAreaPadding()
    .sheet(isPresented: $showDeleteConfirmation) {
      DeleteAccountConfirmationSheet(
        onConfirm: {
          showDeleteConfirmation = false
          Task {
            do {
              try await authService.deleteUser()
            } catch {
              if let errorHandler = reportError {
                errorHandler(error)
              } else {
                throw error
              }
            }
          }
        },
        onCancel: {
          showDeleteConfirmation = false
        }
      )
      .presentationDetents([.medium])
    }
    .sheet(isPresented: $showEmailVerificationSent) {
      VStack(spacing: 24) {
        Text(authService.string.verifyEmailSheetMessage)
          .font(.headline)
        Text("Please tap on the link in your email to complete verification.")
        Button {
          showEmailVerificationSent = false
        } label: {
          Text(authService.string.okButtonLabel)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .padding([.top, .bottom], 8)
        .frame(maxWidth: .infinity)
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
      .safeAreaPadding()
      .presentationDetents([.medium])
    }
  }
}

private struct DeleteAccountConfirmationSheet: View {
  @Environment(AuthService.self) private var authService
  let onConfirm: () -> Void
  let onCancel: () -> Void

  var body: some View {
    VStack(spacing: 24) {
      VStack(spacing: 12) {
        Image(systemName: "exclamationmark.triangle.fill")
          .font(.system(size: 60))
          .foregroundColor(.red)

        Text("Delete Account?")
          .font(.title)
          .fontWeight(.bold)

        Text(
          "This action cannot be undone. All your data will be permanently deleted. You may need to reauthenticate to complete this action."
        )
        .font(.body)
        .foregroundColor(.secondary)
        .multilineTextAlignment(.center)
        .padding(.horizontal)
      }

      VStack(spacing: 12) {
        Button {
          onConfirm()
        } label: {
          Text("Delete Account")
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .tint(.red)
        .padding([.top, .bottom], 8)
        .frame(maxWidth: .infinity)
        .accessibilityIdentifier("confirm-delete-button")

        Button {
          onCancel()
        } label: {
          Text("Cancel")
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
        .padding([.top, .bottom], 8)
        .frame(maxWidth: .infinity)
        .accessibilityIdentifier("cancel-delete-button")
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    .safeAreaPadding()
  }
}

#Preview {
  FirebaseOptions.dummyConfigurationForPreview()
  return SignedInView()
    .environment(AuthService())
}
