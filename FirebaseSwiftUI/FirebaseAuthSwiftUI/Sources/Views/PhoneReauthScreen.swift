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

@preconcurrency import FirebaseAuth
import SwiftUI

/// The state and actions of the phone reauthentication prompt, passed to
/// ``PhoneReauthScreen``'s content.
public struct PhoneReauthContentState {
  /// The code the user typed.
  public let verificationCode: Binding<String>

  /// Sends a verification code to ``phoneNumber``, or a new one once ``codeSent`` is `true`.
  /// Does nothing while ``isLoading`` is `true`.
  public let sendCode: @MainActor () -> Void

  /// Reauthenticates with ``verificationCode``, pushing second-factor resolution when the user
  /// has MFA. Does nothing unless ``codeSent`` and ``isValid`` are `true` and ``isLoading`` is
  /// `false`.
  public let verify: @MainActor () -> Void

  /// Cancels reauthentication and dismisses the prompt.
  public let cancel: @MainActor () -> Void

  /// The phone number of the signed-in user.
  public let phoneNumber: String

  /// Whether a code was sent, so the content should ask for it.
  public let codeSent: Bool

  /// Whether ``verificationCode`` has 6 characters.
  public let isValid: Bool

  /// Whether a send or verify is in flight.
  public let isLoading: Bool

  /// The localized message of the last failed send or verify. It clears when the code changes
  /// or the next attempt starts. The prompt's error alert still shows for the same failure.
  public let errorMessage: String?

  /// Creates a state, for example to preview custom content with stub actions.
  public init(verificationCode: Binding<String>,
              sendCode: @escaping @MainActor () -> Void,
              verify: @escaping @MainActor () -> Void,
              cancel: @escaping @MainActor () -> Void,
              phoneNumber: String,
              codeSent: Bool,
              isValid: Bool,
              isLoading: Bool,
              errorMessage: String?) {
    self.verificationCode = verificationCode
    self.sendCode = sendCode
    self.verify = verify
    self.cancel = cancel
    self.phoneNumber = phoneNumber
    self.codeSent = codeSent
    self.isValid = isValid
    self.isLoading = isLoading
    self.errorMessage = errorMessage
  }
}

/// The phone reauthentication prompt, with its content drawn by you.
///
/// The screen sends the code, reauthenticates, resolves a second factor, and reports errors.
/// Your content only draws the UI from the ``PhoneReauthContentState`` it receives. Apps usually
/// supply content with `reauthContent(_:)` rather than creating this screen.
@MainActor
public struct PhoneReauthScreen<Content: View>: View {
  public init(phoneNumber: String,
              coordinator: ReauthenticationCoordinator,
              @ViewBuilder content: @escaping (PhoneReauthContentState) -> Content) {
    self.phoneNumber = phoneNumber
    self.coordinator = coordinator
    self.content = content
  }

  @Environment(AuthService.self) private var authService
  @Environment(\.reportError) private var reportError
  @State private var verificationID: String?
  @State private var verificationCode = ""
  @State private var isLoading = false
  @State private var errorMessage: String?
  @State private var error: AlertError?
  @State private var mfaRequired: MFARequired?

  private let phoneNumber: String
  private let coordinator: ReauthenticationCoordinator
  private let content: (PhoneReauthContentState) -> Content

  public var body: some View {
    NavigationStack {
      content(PhoneReauthContentState(
        verificationCode: $verificationCode,
        sendCode: sendCode,
        verify: verify,
        cancel: { coordinator.reauthCancelled() },
        phoneNumber: phoneNumber,
        codeSent: verificationID != nil,
        isValid: isValid,
        isLoading: isLoading,
        errorMessage: errorMessage
      ))
      .mfaReauthResolution($mfaRequired, coordinator: coordinator)
    }
    .onChange(of: verificationCode) { errorMessage = nil }
    .errorAlert(error: $error, okButtonLabel: authService.string.okButtonLabel)
  }

  private var isValid: Bool {
    verificationCode.count == 6
  }

  private func sendCode() {
    guard !isLoading else { return }
    isLoading = true
    errorMessage = nil
    Task {
      defer { isLoading = false }
      do {
        verificationID = try await authService.verifyPhoneNumber(phoneNumber: phoneNumber)
      } catch {
        report(error)
      }
    }
  }

  private func verify() {
    guard let verificationID, isValid, !isLoading else { return }
    isLoading = true
    errorMessage = nil
    Task {
      defer { isLoading = false }
      do {
        let credential = PhoneAuthProvider.provider()
          .credential(withVerificationID: verificationID, verificationCode: verificationCode)
        try await authService.reauthenticate(with: credential)
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
