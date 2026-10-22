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

/// The default signed-out first screen of the authentication sheet: the logo, email sign-in,
/// the provider buttons and the terms.
///
/// Return it from ``AuthPickerView/pickerContent(_:)`` to keep the stock screen while adding
/// modifiers such as a background, or use ``init(authMethodPicker:)`` to lay out the provider
/// buttons yourself.
@MainActor
public struct DefaultAuthPickerContent<AuthMethodPicker: View>: View {
  public init() where AuthMethodPicker == DefaultAuthMethodPicker {
    authMethodPicker = { _ in DefaultAuthMethodPicker() }
  }

  /// Creates the default screen with your own layout for the provider buttons.
  ///
  /// The closure receives an ``AuthMethodPickerState``. Call its `select` to sign in with a
  /// provider, so MFA, account conflicts and errors are handled the same as the default buttons.
  /// Show an email-link button when `isEmailLinkEnabled` is `true`.
  ///
  /// Example:
  /// ```swift
  /// DefaultAuthPickerContent { state in
  ///   ForEach(state.providers, id: \.id) { provider in
  ///     Button(provider.displayName) { state.select(provider) }
  ///   }
  ///   if state.isEmailLinkEnabled {
  ///     Button("Email link", action: state.selectEmailLink)
  ///   }
  /// }
  /// ```
  public init(@ViewBuilder authMethodPicker: @escaping (AuthMethodPickerState)
    -> AuthMethodPicker) {
    self.authMethodPicker = authMethodPicker
  }

  @Environment(AuthService.self) private var authService
  private let authMethodPicker: (AuthMethodPickerState) -> AuthMethodPicker

  public var body: some View {
    ScrollView {
      VStack(spacing: 24) {
        Image(authService.configuration.logo ?? Assets.firebaseAuthLogo)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 100, height: 100)
        if authService.emailPasswordSignInEnabled {
          EmailAuthView()
        }
        Divider()
        VStack {
          AuthMethodPickerStateReader { state in
            authMethodPicker(state)
          }
        }
        PrivacyTOCsView(displayMode: .full)
      }
    }
    .safeAreaPadding()
  }
}

/// Builds an ``AuthMethodPickerState`` from the environment and passes it to its content, so
/// provider selection routes MFA, account conflicts and errors through the same handlers as the
/// default buttons. Used by ``DefaultAuthPickerContent`` and ``AuthPickerContent``.
@MainActor
struct AuthMethodPickerStateReader<Content: View>: View {
  init(@ViewBuilder content: @escaping (AuthMethodPickerState) -> Content) {
    self.content = content
  }

  @Environment(AuthService.self) private var authService
  @Environment(\.mfaHandler) private var mfaHandler
  @Environment(\.accountConflictHandler) private var accountConflictHandler
  @Environment(\.reportError) private var reportError
  private let content: (AuthMethodPickerState) -> Content

  var body: some View {
    content(AuthMethodPickerState(
      providers: authService.registeredProviders,
      select: selectProvider,
      isEmailLinkEnabled: authService.emailLinkSignInEnabled,
      selectEmailLink: authService.selectEmailLink
    ))
  }

  private func selectProvider(_ provider: AuthProviderUI) {
    Task {
      let result: Result<SignInOutcome?, Error>
      do {
        let outcome = try await authService.triggerSignIn(for: provider)
        result = .success(outcome)
      } catch {
        result = .failure(error)
      }
      AuthMethodPickerState.route(
        result,
        mfaHandler: mfaHandler,
        accountConflictHandler: accountConflictHandler,
        reportError: reportError
      )
    }
  }
}

/// The providers and sign-in actions passed to a custom first screen in
/// `AuthPickerView.pickerContent { state in ... }`, or to a custom provider layout in
/// ``DefaultAuthPickerContent/init(authMethodPicker:)``.
public struct AuthMethodPickerState {
  /// The registered providers, in registration order. Email-link sign-in isn't included; see
  /// ``isEmailLinkEnabled``.
  public let providers: [AuthProviderUI]

  /// Signs in with a provider from ``providers``. A provider that is neither credential-based
  /// nor an ``AuthProviderAction`` reports an error instead.
  public let select: @MainActor (AuthProviderUI) -> Void

  /// Whether email-link sign-in is enabled on the ``AuthService``.
  public let isEmailLinkEnabled: Bool

  /// Starts email-link sign-in, the same as the stock email-link button.
  public let selectEmailLink: @MainActor () -> Void

  /// Creates a state, for example to preview a custom layout with stub actions.
  public init(providers: [AuthProviderUI],
              select: @escaping @MainActor (AuthProviderUI) -> Void,
              isEmailLinkEnabled: Bool,
              selectEmailLink: @escaping @MainActor () -> Void) {
    self.providers = providers
    self.select = select
    self.isEmailLinkEnabled = isEmailLinkEnabled
    self.selectEmailLink = selectEmailLink
  }

  /// Hands a provider sign-in result to the same handlers the default provider buttons use:
  /// MFA and account conflicts go to their handlers, and other errors are reported.
  @MainActor
  static func route(_ result: Result<SignInOutcome?, Error>,
                    mfaHandler: ((MFARequired) -> Void)?,
                    accountConflictHandler: ((AccountConflictContext) -> Void)?,
                    reportError: ((Error) -> Void)?) {
    switch result {
    case let .success(.mfaRequired(mfaInfo)):
      mfaHandler?(mfaInfo)
    case .success:
      break
    case let .failure(AuthServiceError.accountConflict(ctx)) where accountConflictHandler != nil:
      accountConflictHandler?(ctx)
    case let .failure(error):
      reportError?(error)
    }
  }
}

/// The default provider list on ``DefaultAuthPickerContent``: every registered provider's
/// button, stacked vertically and inset from the screen edges.
///
/// Its width is 72% of the nearest container, such as the enclosing `ScrollView`, not of its
/// direct parent.
@MainActor
public struct DefaultAuthMethodPicker: View {
  public init() {}

  @Environment(AuthService.self) private var authService

  public var body: some View {
    authService.renderButtons()
      // 72% of the container width, matching a 14% inset on each side.
      .containerRelativeFrame(.horizontal) { length, _ in length * 0.72 }
  }
}
