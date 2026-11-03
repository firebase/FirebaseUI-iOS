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

import SwiftUI

/// The state and actions of the password recovery screen, passed to
/// ``PasswordRecoveryScreen``'s content.
public struct PasswordRecoveryContentState {
  /// The email address to send the reset link to.
  public let email: Binding<String>

  /// Sends a password reset link to ``email``, then sets ``didSend``. Does nothing unless
  /// ``isValid`` is `true` and ``isLoading`` is `false`.
  public let sendResetLink: @MainActor () -> Void

  /// Clears ``didSend`` and ``email`` and returns to the first screen of the sheet.
  public let dismissSuccess: @MainActor () -> Void

  /// Clears ``didSend``, keeping ``email`` and staying on this screen, for example when the
  /// user swipes a success sheet away.
  public let hideSuccess: @MainActor () -> Void

  /// Whether a reset link was sent and neither ``dismissSuccess`` nor ``hideSuccess`` has been
  /// called since.
  public let didSend: Bool

  /// The address the last reset link was sent to; empty until one is sent.
  public let sentEmail: String

  /// Whether ``email`` is a valid email address.
  public let isValid: Bool

  /// Whether a reset link is being sent, or the ``AuthService`` is signing in.
  public let isLoading: Bool

  /// The localized message of the last failed attempt. It clears when the email changes or the
  /// next attempt starts. The sheet's error alert still shows for the same failure.
  public let errorMessage: String?

  /// Creates a state, for example to preview custom content with stub actions.
  public init(email: Binding<String>,
              sendResetLink: @escaping @MainActor () -> Void,
              dismissSuccess: @escaping @MainActor () -> Void,
              hideSuccess: @escaping @MainActor () -> Void,
              didSend: Bool,
              sentEmail: String,
              isValid: Bool,
              isLoading: Bool,
              errorMessage: String?) {
    self.email = email
    self.sendResetLink = sendResetLink
    self.dismissSuccess = dismissSuccess
    self.hideSuccess = hideSuccess
    self.didSend = didSend
    self.sentEmail = sentEmail
    self.isValid = isValid
    self.isLoading = isLoading
    self.errorMessage = errorMessage
  }
}

/// The password recovery screen, with its content drawn by you.
///
/// The screen sends the reset link, navigates, and reports errors. Your content only draws the
/// UI from the ``PasswordRecoveryContentState`` it receives. Wrap
/// ``DefaultPasswordRecoveryContent`` to keep the stock markup.
///
/// Example:
/// ```swift
/// AuthPickerView { authenticatedApp }
///   .pickerDestination { screen in
///     switch screen {
///     case .passwordRecovery:
///       PasswordRecoveryScreen { state in
///         if state.didSend {
///           Text("Check \(state.sentEmail)")
///           Button("OK", action: state.dismissSuccess)
///         } else {
///           TextField("Email", text: state.email)
///           Button("Send reset link", action: state.sendResetLink)
///             .disabled(!state.isValid || state.isLoading)
///         }
///       }
///     default:
///       DefaultAuthPickerDestination(screen: screen)
///     }
///   }
/// ```
@MainActor
public struct PasswordRecoveryScreen<Content: View>: View {
  public init(@ViewBuilder content: @escaping (PasswordRecoveryContentState) -> Content) {
    self.content = content
  }

  @Environment(AuthService.self) private var authService
  @Environment(\.reportError) private var reportError
  @State private var email = ""
  @State private var didSend = false
  @State private var sentEmail = ""
  @State private var isWorking = false
  @State private var errorMessage: String?

  private let content: (PasswordRecoveryContentState) -> Content

  public var body: some View {
    content(PasswordRecoveryContentState(
      email: $email,
      sendResetLink: sendResetLink,
      dismissSuccess: dismissSuccess,
      hideSuccess: { didSend = false },
      didSend: didSend,
      sentEmail: sentEmail,
      isValid: isValid,
      isLoading: isLoading,
      errorMessage: errorMessage
    ))
    .onChange(of: email) { errorMessage = nil }
  }

  private var isValid: Bool {
    CommonUtils.isValidEmail(email)
  }

  private var isLoading: Bool {
    isWorking || authService.authenticationState == .authenticating
  }

  private func sendResetLink() {
    guard isValid, !isLoading else { return }
    isWorking = true
    errorMessage = nil
    Task {
      defer { isWorking = false }
      do {
        try await authService.sendPasswordRecoveryEmail(email: email)
        sentEmail = email
        didSend = true
      } catch {
        errorMessage = authService.string.localizedErrorMessage(for: error)
        reportError?(error)
      }
    }
  }

  private func dismissSuccess() {
    didSend = false
    email = ""
    authService.navigator.clear()
  }
}
