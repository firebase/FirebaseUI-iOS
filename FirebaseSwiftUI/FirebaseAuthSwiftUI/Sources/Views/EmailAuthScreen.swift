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

/// The state and actions of the email and password form, passed to ``EmailAuthScreen``'s
/// content.
public struct EmailAuthContentState {
  /// The email address. The screen fills it in from ``AuthService/suggestedEmailAddress``.
  public let email: Binding<String>

  /// The password.
  public let password: Binding<String>

  /// The repeated password, checked against ``password`` when ``flow`` is
  /// ``AuthenticationFlow/signUp``.
  public let confirmPassword: Binding<String>

  /// Signs in with ``email`` and ``password``, routing MFA and account conflicts to their
  /// handlers. Does nothing while ``isLoading`` is `true` or unless the email is valid and the
  /// password is non-empty, whatever ``flow`` is.
  public let signIn: @MainActor () -> Void

  /// Creates an account with ``email`` and ``password``, routing MFA and account conflicts to
  /// their handlers. Does nothing while ``isLoading`` is `true` or unless the email is valid, the
  /// password has at least 6 characters and ``confirmPassword`` matches, whatever ``flow`` is.
  public let signUp: @MainActor () -> Void

  /// Toggles ``flow`` between sign-in and sign-up, with animation. On a screen with a fixed
  /// flow it navigates instead: sign-up goes to ``AuthView/signIn`` and sign-in pushes
  /// ``AuthView/signUp``.
  public let switchFlow: @MainActor () -> Void

  /// Pushes ``AuthView/signUp``, for a sign-up screen of its own instead of toggling ``flow``.
  public let goToSignUp: @MainActor () -> Void

  /// Pushes ``AuthView/passwordRecovery``.
  public let goToPasswordRecovery: @MainActor () -> Void

  /// Starts email-link sign-in, the same as the stock email-link button.
  public let goToEmailLink: @MainActor () -> Void

  /// Whether the form signs in or signs up. Shared with ``AuthService/authenticationFlow``
  /// unless the screen was created with a fixed flow.
  public let flow: AuthenticationFlow

  /// Whether the fields are valid for ``flow``: a valid email and a non-empty password to sign
  /// in; a valid email, a password of at least 6 characters and a matching ``confirmPassword``
  /// to sign up.
  public let isValid: Bool

  /// Whether a sign-in or sign-up is in flight, or the ``AuthService`` is signing in.
  public let isLoading: Bool

  /// The localized message of the last failed attempt, for your content to show. The sheet's
  /// error alert doesn't show it; ``DefaultEmailAuthContent`` shows it in the same alert. It
  /// clears when a field or ``flow`` changes, the next attempt starts, or ``dismissError`` runs.
  public let errorMessage: String?

  /// Clears ``errorMessage``, for example when the user closes your error UI.
  public let dismissError: @MainActor () -> Void

  /// Creates a state, for example to preview custom content with stub actions. Every parameter
  /// has a default, so pass only what the preview needs; later releases add new parameters
  /// with defaults too.
  public init(email: Binding<String> = .constant(""),
              password: Binding<String> = .constant(""),
              confirmPassword: Binding<String> = .constant(""),
              signIn: @escaping @MainActor () -> Void = {},
              signUp: @escaping @MainActor () -> Void = {},
              switchFlow: @escaping @MainActor () -> Void = {},
              goToSignUp: @escaping @MainActor () -> Void = {},
              goToPasswordRecovery: @escaping @MainActor () -> Void = {},
              goToEmailLink: @escaping @MainActor () -> Void = {},
              flow: AuthenticationFlow = .signIn,
              isValid: Bool = false,
              isLoading: Bool = false,
              errorMessage: String? = nil,
              dismissError: @escaping @MainActor () -> Void = {}) {
    self.email = email
    self.password = password
    self.confirmPassword = confirmPassword
    self.signIn = signIn
    self.signUp = signUp
    self.switchFlow = switchFlow
    self.goToSignUp = goToSignUp
    self.goToPasswordRecovery = goToPasswordRecovery
    self.goToEmailLink = goToEmailLink
    self.flow = flow
    self.isValid = isValid
    self.isLoading = isLoading
    self.errorMessage = errorMessage
    self.dismissError = dismissError
  }
}

/// The email and password form, with its content drawn by you.
///
/// The screen signs in and signs up, switches the flow, navigates, and routes MFA, account
/// conflicts and errors. Your content only draws the UI from the ``EmailAuthContentState`` it
/// receives. Wrap ``DefaultEmailAuthContent`` to keep the stock markup.
///
/// `AuthPickerView`'s `pickerContent { state in ... }` replaces the whole first screen, so add
/// your own provider buttons calling `state.select`, or the stock ones with
/// ``DefaultAuthMethodPicker``.
///
/// Example:
/// ```swift
/// AuthPickerView { authenticatedApp }
///   .pickerContent { picker in
///     ScrollView {
///       VStack {
///         EmailAuthScreen { state in
///           TextField("Email", text: state.email)
///           SecureField("Password", text: state.password)
///           if let errorMessage = state.errorMessage {
///             Text(errorMessage)
///           }
///           Button("Sign in", action: state.signIn)
///             .disabled(!state.isValid || state.isLoading)
///         }
///         ForEach(picker.providers, id: \.id) { provider in
///           Button(provider.displayName) { picker.select(provider) }
///         }
///       }
///     }
///   }
/// ```
@MainActor
public struct EmailAuthScreen<Content: View>: View {
  /// Creates the screen. Leave `flow` `nil` to follow ``AuthService/authenticationFlow`` and
  /// toggle it in place, as the stock first screen does.
  ///
  /// Pass a `flow` to fix it and make ``EmailAuthContentState/switchFlow`` navigate instead:
  /// `.signIn` pushes ``AuthView/signUp``, so a first screen fixed to `.signIn` gives the stock
  /// "Sign up" link its own sign-up screen, as ``SignInView`` does for ``AuthView/signIn``. Use
  /// `.signUp` only for an ``AuthView/signUp`` destination, where `switchFlow` returns to the
  /// sign-in screen under it, or opens one in its place when sign-up was pushed directly.
  public init(flow: AuthenticationFlow? = nil,
              @ViewBuilder content: @escaping (EmailAuthContentState) -> Content) {
    fixedFlow = flow
    self.content = content
  }

  @Environment(AuthService.self) private var authService
  @Environment(\.accountConflictHandler) private var accountConflictHandler
  @Environment(\.mfaHandler) private var mfaHandler
  @State private var email = ""
  @State private var password = ""
  @State private var confirmPassword = ""
  @State private var isWorking = false
  @State private var errorMessage: String?
  @State private var inlineFormRegistration = InlineEmailFormRegistration()

  private let fixedFlow: AuthenticationFlow?
  private let content: (EmailAuthContentState) -> Content

  public var body: some View {
    content(EmailAuthContentState(
      email: $email,
      password: $password,
      confirmPassword: $confirmPassword,
      signIn: signIn,
      signUp: signUp,
      switchFlow: switchFlow,
      goToSignUp: { authService.navigator.push(.signUp) },
      goToPasswordRecovery: { authService.navigator.push(.passwordRecovery) },
      goToEmailLink: { authService.selectEmailLink() },
      flow: flow,
      isValid: isValid,
      isLoading: isLoading,
      errorMessage: errorMessage,
      dismissError: { errorMessage = nil }
    ))
    .onChange(of: email) { errorMessage = nil }
    .onChange(of: password) { errorMessage = nil }
    .onChange(of: confirmPassword) { errorMessage = nil }
    .onChange(of: authService.authenticationFlow) { errorMessage = nil }
    .onAppear {
      if fixedFlow == nil {
        inlineFormRegistration.register(with: authService)
      }
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

  private var flow: AuthenticationFlow {
    fixedFlow ?? authService.authenticationFlow
  }

  private var isValid: Bool {
    flow == .signIn ? isSignInValid : isSignUpValid
  }

  private var isSignInValid: Bool {
    FormValidators.email.isValid(input: email) && !password.isEmpty
  }

  private var isSignUpValid: Bool {
    FormValidators.email.isValid(input: email) &&
      FormValidators.atLeast6Characters.isValid(input: password) &&
      FormValidators.confirmPassword(password: password).isValid(input: confirmPassword)
  }

  private var isLoading: Bool {
    isWorking || authService.authenticationState == .authenticating
  }

  private func switchFlow() {
    switch fixedFlow {
    case .signUp:
      authService.navigator.switchSignUpToSignIn()
      return
    case .signIn:
      authService.navigator.push(.signUp)
      return
    case nil:
      break
    }
    withAnimation {
      authService.authenticationFlow =
        authService.authenticationFlow == .signIn ? .signUp : .signIn
    }
  }

  private func signIn() {
    guard isSignInValid else { return }
    submit { [email, password] in
      try await authService.signIn(email: email, password: password)
    }
  }

  private func signUp() {
    guard isSignUpValid else { return }
    submit { [email, password] in
      try await authService.createUser(email: email, password: password)
    }
  }

  private func submit(_ attempt: @escaping @MainActor () async throws -> SignInOutcome) {
    guard !isLoading else { return }
    isWorking = true
    errorMessage = nil
    Task {
      defer { isWorking = false }
      do {
        if case let .mfaRequired(mfaInfo) = try await attempt() {
          mfaHandler?(mfaInfo)
        }
      } catch {
        if case let AuthServiceError.accountConflict(ctx) = error,
           let onConflict = accountConflictHandler {
          onConflict(ctx)
          return
        }

        // Errors the sheet's alert skips, such as the legacy sign-in recovery sheet, get no
        // message either.
        if shouldShowErrorAlert(for: error) {
          errorMessage = authService.string.localizedErrorMessage(for: error)
        }
      }
    }
  }
}

/// Counts an in-place ``EmailAuthScreen`` in ``AuthService/inlineEmailFormCount`` for as long as
/// the screen exists. It's held in `@State`, so it outlives the screen being covered by a pushed
/// one and is released when the screen leaves the sheet.
final class InlineEmailFormRegistration: @unchecked Sendable {
  private var unregister: (@Sendable () -> Void)?

  @MainActor
  func register(with authService: AuthService) {
    guard unregister == nil else { return }
    authService.inlineEmailFormCount += 1
    unregister = {
      Task { @MainActor in
        authService.inlineEmailFormCount -= 1
      }
    }
  }

  deinit {
    unregister?()
  }
}
