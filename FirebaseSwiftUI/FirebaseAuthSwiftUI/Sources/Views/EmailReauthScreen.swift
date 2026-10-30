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

/// The state and actions of the password reauthentication prompt, passed to
/// ``EmailReauthScreen``'s content.
public struct EmailReauthContentState {
  /// The password the user typed.
  public let password: Binding<String>

  /// Reauthenticates with ``email`` and ``password``, pushing second-factor resolution when the
  /// user has MFA. Does nothing unless ``isValid`` is `true` and ``isLoading`` is `false`.
  public let verify: @MainActor () -> Void

  /// Cancels reauthentication and dismisses the prompt.
  public let cancel: @MainActor () -> Void

  /// The email address of the signed-in user.
  public let email: String

  /// Whether ``password`` is not empty.
  public let isValid: Bool

  /// Whether a reauthentication attempt is in flight.
  public let isLoading: Bool

  /// The localized message of the last failed attempt. It clears when the password changes or
  /// the next attempt starts. The prompt's error alert still shows for the same failure.
  public let errorMessage: String?

  /// Creates a state, for example to preview custom content with stub actions.
  public init(password: Binding<String>,
              verify: @escaping @MainActor () -> Void,
              cancel: @escaping @MainActor () -> Void,
              email: String,
              isValid: Bool,
              isLoading: Bool,
              errorMessage: String?) {
    self.password = password
    self.verify = verify
    self.cancel = cancel
    self.email = email
    self.isValid = isValid
    self.isLoading = isLoading
    self.errorMessage = errorMessage
  }
}

/// The password reauthentication prompt, with its content drawn by you.
///
/// The screen reauthenticates, resolves a second factor, and reports errors. Your content only
/// draws the UI from the ``EmailReauthContentState`` it receives. Apps usually supply content
/// with `reauthContent(_:)` rather than creating this screen.
@MainActor
public struct EmailReauthScreen<Content: View>: View {
  public init(email: String,
              coordinator: ReauthenticationCoordinator,
              @ViewBuilder content: @escaping (EmailReauthContentState) -> Content) {
    self.email = email
    self.coordinator = coordinator
    self.content = content
  }

  @Environment(AuthService.self) private var authService
  @Environment(\.reportError) private var reportError
  @State private var password = ""
  @State private var isLoading = false
  @State private var errorMessage: String?
  @State private var error: AlertError?
  @State private var mfaRequired: MFARequired?

  private let email: String
  private let coordinator: ReauthenticationCoordinator
  private let content: (EmailReauthContentState) -> Content

  public var body: some View {
    NavigationStack {
      content(EmailReauthContentState(
        password: $password,
        verify: verify,
        cancel: { coordinator.reauthCancelled() },
        email: email,
        isValid: isValid,
        isLoading: isLoading,
        errorMessage: errorMessage
      ))
      .mfaReauthResolution($mfaRequired, coordinator: coordinator)
    }
    .onChange(of: password) { errorMessage = nil }
    .errorAlert(error: $error, okButtonLabel: authService.string.okButtonLabel)
  }

  private var isValid: Bool {
    !password.isEmpty
  }

  private func verify() {
    guard isValid, !isLoading else { return }
    isLoading = true
    errorMessage = nil
    Task {
      defer { isLoading = false }
      do {
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        try await authService.reauthenticate(with: credential)
        coordinator.reauthCompleted()
      } catch let AuthServiceError.multiFactorReauthenticationRequired(mfaRequired) {
        self.mfaRequired = mfaRequired
      } catch {
        errorMessage = authService.string.localizedErrorMessage(for: error)
        if let reportError {
          reportError(error)
        } else {
          self.error = AlertError(
            title: "Error",
            message: error.localizedDescription,
            underlyingError: error
          )
        }
      }
    }
  }
}
