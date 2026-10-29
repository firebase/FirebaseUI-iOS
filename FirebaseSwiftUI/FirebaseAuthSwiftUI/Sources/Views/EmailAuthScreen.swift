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
  /// handlers. Does nothing unless ``isValid`` is `true` and ``isLoading`` is `false`.
  public let signIn: @MainActor () -> Void

  /// Creates an account with ``email`` and ``password``, routing MFA and account conflicts to
  /// their handlers. Does nothing unless ``isValid`` is `true` and ``isLoading`` is `false`.
  public let signUp: @MainActor () -> Void

  /// Toggles ``flow`` between sign-in and sign-up, with animation. On a screen with a fixed
  /// flow it navigates instead: sign-up pops back and sign-in pushes ``AuthView/signUp``.
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

  /// The localized message of the last failed attempt. It clears when a field or ``flow``
  /// changes or the next attempt starts. The sheet's error alert still shows for the same
  /// failure.
  public let errorMessage: String?

  /// Creates a state, for example to preview custom content with stub actions.
  public init(email: Binding<String>,
              password: Binding<String>,
              confirmPassword: Binding<String>,
              signIn: @escaping @MainActor () -> Void,
              signUp: @escaping @MainActor () -> Void,
              switchFlow: @escaping @MainActor () -> Void,
              goToSignUp: @escaping @MainActor () -> Void,
              goToPasswordRecovery: @escaping @MainActor () -> Void,
              goToEmailLink: @escaping @MainActor () -> Void,
              flow: AuthenticationFlow,
              isValid: Bool,
              isLoading: Bool,
              errorMessage: String?) {
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
///   .pickerContent {
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
///         DefaultAuthMethodPicker()
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
  /// "Sign up" link its own sign-up screen. Use `.signUp` only for an ``AuthView/signUp``
  /// destination, where `switchFlow` pops back to the screen that pushed it.
  public init(flow: AuthenticationFlow? = nil,
              @ViewBuilder content: @escaping (EmailAuthContentState) -> Content) {
    fixedFlow = flow
    self.content = content
  }

  @Environment(AuthService.self) private var authService
  @Environment(\.accountConflictHandler) private var accountConflictHandler
  @Environment(\.mfaHandler) private var mfaHandler
  @Environment(\.reportError) private var reportError
  @State private var email = ""
  @State private var password = ""
  @State private var confirmPassword = ""
  @State private var isWorking = false
  @State private var errorMessage: String?

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
      errorMessage: errorMessage
    ))
    .onChange(of: email) { errorMessage = nil }
    .onChange(of: password) { errorMessage = nil }
    .onChange(of: confirmPassword) { errorMessage = nil }
    .onChange(of: authService.authenticationFlow) { errorMessage = nil }
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

  private var flow: AuthenticationFlow {
    fixedFlow ?? authService.authenticationFlow
  }

  private var isValid: Bool {
    return if flow == .signIn {
      FormValidators.email.isValid(input: email) && !password.isEmpty
    } else {
      FormValidators.email.isValid(input: email) &&
        FormValidators.atLeast6Characters.isValid(input: password) &&
        FormValidators.confirmPassword(password: password).isValid(input: confirmPassword)
    }
  }

  private var isLoading: Bool {
    isWorking || authService.authenticationState == .authenticating
  }

  private func switchFlow() {
    switch fixedFlow {
    case .signUp:
      if authService.authView == .signUp {
        authService.navigator.pop()
      }
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
    submit { [email, password] in
      try await authService.signIn(email: email, password: password)
    }
  }

  private func signUp() {
    submit { [email, password] in
      try await authService.createUser(email: email, password: password)
    }
  }

  private func submit(_ attempt: @escaping @MainActor () async throws -> SignInOutcome) {
    guard isValid, !isLoading else { return }
    isWorking = true
    errorMessage = nil
    Task {
      defer { isWorking = false }
      do {
        switch try await attempt() {
        case let .mfaRequired(mfaInfo):
          mfaHandler?(mfaInfo)
        case .signedIn:
          // Close a pushed sign-up screen so the signed-in screen shows, like the other routes.
          authService.navigator.clear()
        }
      } catch {
        if case let AuthServiceError.accountConflict(ctx) = error,
           let onConflict = accountConflictHandler {
          onConflict(ctx)
          return
        }

        reportError?(error)
        // The legacy sign-in recovery sheet explains this failure, so there is no message.
        if case .legacySignInRecoveryPresented = error as? AuthServiceError {
          return
        }

        errorMessage = authService.string.localizedErrorMessage(for: error)
      }
    }
  }
}
