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

  /// Toggles ``flow`` between sign-in and sign-up, with animation.
  public let switchFlow: @MainActor () -> Void

  /// Pushes ``AuthView/passwordRecovery``.
  public let goToPasswordRecovery: @MainActor () -> Void

  /// Starts email-link sign-in, the same as the stock email-link button.
  public let goToEmailLink: @MainActor () -> Void

  /// Whether the form signs in or signs up. Shared with ``AuthService/authenticationFlow``.
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
/// ``AuthPickerView/pickerContent(_:)`` replaces the whole first screen, so add the provider
/// buttons back with ``DefaultAuthMethodPicker``.
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
  public init(@ViewBuilder content: @escaping (EmailAuthContentState) -> Content) {
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

  private let content: (EmailAuthContentState) -> Content

  public var body: some View {
    content(EmailAuthContentState(
      email: $email,
      password: $password,
      confirmPassword: $confirmPassword,
      signIn: signIn,
      signUp: signUp,
      switchFlow: switchFlow,
      goToPasswordRecovery: { authService.navigator.push(.passwordRecovery) },
      goToEmailLink: { authService.selectEmailLink() },
      flow: authService.authenticationFlow,
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

  private var isValid: Bool {
    return if authService.authenticationFlow == .signIn {
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
        if case let .mfaRequired(mfaInfo) = try await attempt() {
          mfaHandler?(mfaInfo)
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
