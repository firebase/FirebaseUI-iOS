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
import SwiftUI

/// The state and actions of the signed-in screen, passed to the content of
/// ``AuthPickerView/signedInContent(_:)``.
public struct SignedInContentState {
  /// Signs the user out. Does nothing while ``isLoading`` is `true`.
  public let signOut: @MainActor () -> Void

  /// Asks the user to confirm, then deletes the account, reauthenticating first when Firebase
  /// requires it. Does nothing while ``isLoading`` is `true`.
  public let deleteAccount: @MainActor () -> Void

  /// Pushes ``AuthView/updatePassword``.
  public let updatePassword: @MainActor () -> Void

  /// Sends a verification email to the user, then shows an alert telling them to tap the link.
  /// Does nothing while ``isLoading`` is `true`.
  public let verifyEmail: @MainActor () -> Void

  /// Pushes ``AuthView/mfaManagement``. Offer it only when ``isMFAEnabled`` is `true`.
  public let goToMFAManagement: @MainActor () -> Void

  /// The signed-in user.
  public let user: User?

  /// Whether the user's email is verified; `true` when there is no user.
  public let isEmailVerified: Bool

  /// Whether ``AuthConfiguration/mfaEnabled`` is set. Offer ``goToMFAManagement`` only when it is
  /// `true`.
  public let isMFAEnabled: Bool

  /// Whether a sign out, account deletion or verification email is in flight.
  public let isLoading: Bool

  /// The localized message of the last failed sign out, account deletion or verification email.
  /// It clears when the next of those starts, and stays `nil` when the user cancels
  /// reauthentication. The sheet's error alert still shows for the same failure.
  public let errorMessage: String?

  /// Creates a state, for example to preview custom content with stub actions.
  public init(signOut: @escaping @MainActor () -> Void,
              deleteAccount: @escaping @MainActor () -> Void,
              updatePassword: @escaping @MainActor () -> Void,
              verifyEmail: @escaping @MainActor () -> Void,
              goToMFAManagement: @escaping @MainActor () -> Void,
              user: User?,
              isEmailVerified: Bool,
              isMFAEnabled: Bool,
              isLoading: Bool,
              errorMessage: String?) {
    self.signOut = signOut
    self.deleteAccount = deleteAccount
    self.updatePassword = updatePassword
    self.verifyEmail = verifyEmail
    self.goToMFAManagement = goToMFAManagement
    self.user = user
    self.isEmailVerified = isEmailVerified
    self.isMFAEnabled = isMFAEnabled
    self.isLoading = isLoading
    self.errorMessage = errorMessage
  }
}

/// Runs the signed-in screen's actions, delete confirmation, reauthentication and alerts, and
/// draws its content from the ``SignedInContentState`` it builds.
@MainActor
struct SignedInScreen<Content: View>: View {
  init(@ViewBuilder content: @escaping (SignedInContentState) -> Content) {
    self.content = content
  }

  @Environment(AuthService.self) private var authService
  @Environment(\.reportError) private var reportError
  @State private var showDeleteConfirmation = false
  @State private var showEmailVerificationSent = false
  @State private var reauthCoordinator = ReauthenticationCoordinator()
  @State private var isWorking = false
  @State private var errorMessage: String?

  private let content: (SignedInContentState) -> Content

  var body: some View {
    // A single container, so the sheet and alerts below attach once even when the content is
    // several views.
    VStack {
      content(state)
    }
    .withReauthentication(coordinator: reauthCoordinator)
    .sheet(isPresented: $showDeleteConfirmation) {
      DeleteAccountConfirmationSheet(
        onConfirm: {
          showDeleteConfirmation = false
          deleteAccount()
        },
        onCancel: {
          showDeleteConfirmation = false
        }
      )
      .presentationDetents([.medium])
    }
    .alert(
      authService.string.verifyEmailSheetMessage,
      isPresented: $showEmailVerificationSent
    ) {
      Button(authService.string.okButtonLabel) {
        showEmailVerificationSent = false
      }
    } message: {
      Text(authService.string.emailVerificationTapLinkMessage)
    }
  }

  private var state: SignedInContentState {
    SignedInContentState(
      signOut: signOut,
      deleteAccount: {
        if !isWorking {
          showDeleteConfirmation = true
        }
      },
      updatePassword: { authService.navigator.push(.updatePassword) },
      verifyEmail: verifyEmail,
      goToMFAManagement: { authService.navigator.push(.mfaManagement) },
      user: authService.currentUser,
      isEmailVerified: authService.currentUser?.isEmailVerified != false,
      isMFAEnabled: authService.configuration.mfaEnabled,
      isLoading: isWorking,
      errorMessage: errorMessage
    )
  }

  private func signOut() {
    perform { try await authService.signOut() }
  }

  private func verifyEmail() {
    perform {
      try await authService.sendEmailVerification()
      showEmailVerificationSent = true
    }
  }

  private func deleteAccount() {
    perform {
      try await withReauthenticationIfNeeded(
        authService: authService,
        coordinator: reauthCoordinator
      ) {
        try await authService.deleteUser()
      }
    }
  }

  private func perform(_ action: @escaping @MainActor () async throws -> Void) {
    guard !isWorking else { return }
    isWorking = true
    errorMessage = nil
    Task {
      defer { isWorking = false }
      do {
        try await action()
      } catch {
        if case AuthServiceError.signInCancelled = error {
          // The user dismissed reauthentication; the sheet still reports it, as before.
        } else {
          errorMessage = authService.string.localizedErrorMessage(for: error)
        }
        reportError?(error)
      }
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
          .authFont(.title)
          .fontWeight(.bold)

        Text(
          "This action cannot be undone. All your data will be permanently deleted. You may need to reauthenticate to complete this action."
        )
        .authFont(.body)
        .foregroundColor(.secondary)
        .multilineTextAlignment(.center)
        .padding(.horizontal)
      }

      VStack(spacing: 12) {
        Button {
          onConfirm()
        } label: {
          Text("Delete Account")
            .authCustomFont(.body)
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
            .authCustomFont(.body)
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
