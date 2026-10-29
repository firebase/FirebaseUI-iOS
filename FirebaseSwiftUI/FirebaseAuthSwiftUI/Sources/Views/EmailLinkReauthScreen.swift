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

/// The state and actions of the email link reauthentication prompt, passed to
/// ``EmailLinkReauthScreen``'s content.
///
/// The screen sends the first link when it appears and completes reauthentication when the app
/// opens the link.
public struct EmailLinkReauthContentState {
  /// Sends a new link to ``email``. Does nothing while ``isLoading`` is `true`.
  public let resendLink: @MainActor () -> Void

  /// Cancels reauthentication and dismisses the prompt.
  public let cancel: @MainActor () -> Void

  /// The email address of the signed-in user.
  public let email: String

  /// Whether a link was sent, so the content should ask the user to open it.
  public let linkSent: Bool

  /// Whether a link is being sent.
  public let isLoading: Bool

  /// The localized message of the last failed send or link sign-in. It clears when the next
  /// attempt starts. The prompt's error alert still shows for the same failure.
  public let errorMessage: String?

  /// Creates a state, for example to preview custom content with stub actions.
  public init(resendLink: @escaping @MainActor () -> Void,
              cancel: @escaping @MainActor () -> Void,
              email: String,
              linkSent: Bool,
              isLoading: Bool,
              errorMessage: String?) {
    self.resendLink = resendLink
    self.cancel = cancel
    self.email = email
    self.linkSent = linkSent
    self.isLoading = isLoading
    self.errorMessage = errorMessage
  }
}

/// The email link reauthentication prompt, with its content drawn by you.
///
/// The screen sends the link, reauthenticates when the app opens it, resolves a second factor,
/// and reports errors. Your content only draws the UI from the ``EmailLinkReauthContentState``
/// it receives. Apps usually supply content with `reauthContent(_:)` rather than creating this
/// screen.
@MainActor
public struct EmailLinkReauthScreen<Content: View>: View {
  public init(email: String,
              coordinator: ReauthenticationCoordinator,
              @ViewBuilder content: @escaping (EmailLinkReauthContentState) -> Content) {
    self.email = email
    self.coordinator = coordinator
    self.content = content
  }

  @Environment(AuthService.self) private var authService
  @Environment(\.reportError) private var reportError
  @State private var linkSent = false
  @State private var isLoading = false
  @State private var errorMessage: String?
  @State private var error: AlertError?
  @State private var mfaRequired: MFARequired?

  private let email: String
  private let coordinator: ReauthenticationCoordinator
  private let content: (EmailLinkReauthContentState) -> Content

  public var body: some View {
    NavigationStack {
      content(EmailLinkReauthContentState(
        resendLink: { Task { await sendLink() } },
        cancel: { coordinator.reauthCancelled() },
        email: email,
        linkSent: linkSent,
        isLoading: isLoading,
        errorMessage: errorMessage
      ))
      .onOpenURL { url in
        handleReauthURL(url)
      }
      .task {
        await sendLink()
      }
      .mfaReauthResolution($mfaRequired, coordinator: coordinator)
    }
    .errorAlert(error: $error, okButtonLabel: authService.string.okButtonLabel)
  }

  private func sendLink() async {
    guard !isLoading else { return }
    isLoading = true
    errorMessage = nil
    defer { isLoading = false }
    do {
      try await authService.sendEmailSignInLink(email: email, isReauth: true)
      linkSent = true
    } catch {
      report(error)
    }
  }

  private func handleReauthURL(_ url: URL) {
    errorMessage = nil
    Task {
      do {
        try await authService.handleSignInLink(url: url)
        coordinator.reauthCompleted()
      } catch let AuthServiceError.multiFactorReauthenticationRequired(mfaRequired) {
        self.mfaRequired = mfaRequired
      } catch {
        report(error)
      }
    }
  }

  private func report(_ error: Error) {
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
