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

/// The state and actions of the email-link screen, passed to ``EmailLinkScreen``'s content.
public struct EmailLinkContentState {
  /// The email address to send the sign-in link to. The screen fills it in from
  /// ``AuthService/suggestedEmailAddress``.
  public let email: Binding<String>

  /// Sends a sign-in link to ``email``, then sets ``didSend``. Does nothing unless ``isValid`` is
  /// `true` and ``isLoading`` is `false`.
  public let sendSignInLink: @MainActor () -> Void

  /// Clears ``didSend``.
  public let dismissAlert: @MainActor () -> Void

  /// Whether a sign-in link was sent and ``dismissAlert`` hasn't been called since.
  public let didSend: Bool

  /// Whether ``email`` is a valid email address.
  public let isValid: Bool

  /// Whether a link is being sent or handled, or the ``AuthService`` is signing in.
  public let isLoading: Bool

  /// The localized message of the last failed send or link sign-in. It clears when the email
  /// changes or the next attempt starts. The sheet's error alert still shows for the same
  /// failure.
  public let errorMessage: String?

  /// Creates a state, for example to preview custom content with stub actions.
  public init(email: Binding<String>,
              sendSignInLink: @escaping @MainActor () -> Void,
              dismissAlert: @escaping @MainActor () -> Void,
              didSend: Bool,
              isValid: Bool,
              isLoading: Bool,
              errorMessage: String?) {
    self.email = email
    self.sendSignInLink = sendSignInLink
    self.dismissAlert = dismissAlert
    self.didSend = didSend
    self.isValid = isValid
    self.isLoading = isLoading
    self.errorMessage = errorMessage
  }
}

/// The email-link screen, with its content drawn by you.
///
/// The screen sends the link, signs in when the app opens it, and routes account conflicts and
/// errors. Your content only draws the UI from the ``EmailLinkContentState`` it receives. Wrap
/// ``DefaultEmailLinkContent`` to keep the stock markup.
///
/// Example:
/// ```swift
/// AuthPickerView { authenticatedApp }
///   .pickerDestination { screen in
///     switch screen {
///     case .emailLink:
///       EmailLinkScreen { state in
///         TextField("Email", text: state.email)
///         Button("Send link", action: state.sendSignInLink)
///           .disabled(!state.isValid || state.isLoading)
///         if state.didSend {
///           Text("Check your inbox")
///         }
///       }
///     default:
///       DefaultAuthPickerDestination(screen: screen)
///     }
///   }
/// ```
@MainActor
public struct EmailLinkScreen<Content: View>: View {
  public init(@ViewBuilder content: @escaping (EmailLinkContentState) -> Content) {
    self.content = content
  }

  @Environment(AuthService.self) private var authService
  @Environment(\.accountConflictHandler) private var accountConflictHandler
  @Environment(\.reportError) private var reportError
  @State private var email = ""
  @State private var didSend = false
  @State private var isWorking = false
  @State private var isHandlingLink = false
  @State private var errorMessage: String?

  private let content: (EmailLinkContentState) -> Content

  public var body: some View {
    content(EmailLinkContentState(
      email: $email,
      sendSignInLink: sendSignInLink,
      dismissAlert: { didSend = false },
      didSend: didSend,
      isValid: isValid,
      isLoading: isLoading,
      errorMessage: errorMessage
    ))
    .onChange(of: email) { errorMessage = nil }
    .onOpenURL { url in
      // Content with several root views gets this handler once per view; the link is one-time,
      // so only the first one handles it.
      guard !isHandlingLink else { return }
      isHandlingLink = true
      errorMessage = nil
      Task {
        defer { isHandlingLink = false }
        do {
          try await authService.handleSignInLink(url: url)
        } catch {
          if case let AuthServiceError.accountConflict(ctx) = error,
             let onConflict = accountConflictHandler {
            onConflict(ctx)
            return
          }

          errorMessage = authService.string.localizedErrorMessage(for: error)
          reportError?(error)
        }
      }
    }
    .onAppear {
      if let suggestedEmailAddress = authService.suggestedEmailAddress {
        email = suggestedEmailAddress
      }
    }
    .onChange(of: authService.suggestedEmailAddress) { _, suggestedEmailAddress in
      if let suggestedEmailAddress {
        email = suggestedEmailAddress
      }
    }
  }

  private var isValid: Bool {
    CommonUtils.isValidEmail(email)
  }

  private var isLoading: Bool {
    isWorking || isHandlingLink || authService.authenticationState == .authenticating
  }

  private func sendSignInLink() {
    guard isValid, !isLoading else { return }
    isWorking = true
    errorMessage = nil
    Task {
      defer { isWorking = false }
      do {
        try await authService.sendEmailSignInLink(email: email)
        didSend = true
        authService.emailLink = email
      } catch {
        errorMessage = authService.string.localizedErrorMessage(for: error)
        reportError?(error)
      }
    }
  }
}
