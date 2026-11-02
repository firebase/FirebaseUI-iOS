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

/// Seconds between sending a code and allowing a resend.
private let resendDelay: TimeInterval = 60

/// The state and actions of the verification code screen, passed to
/// ``EnterVerificationCodeScreen``'s content.
public struct VerificationCodeContentState {
  /// The code the user typed.
  public let verificationCode: Binding<String>

  /// Signs in with the code, routing MFA and account conflicts to their handlers. Does nothing
  /// unless ``isValid`` is `true` and ``isLoading`` is `false`.
  public let verify: @MainActor () -> Void

  /// Sends a new code and clears ``verificationCode``. Does nothing while ``resendCountdown`` is
  /// above zero or ``isLoading`` is `true`.
  public let resendCode: @MainActor () -> Void

  /// Pops back to the phone number screen.
  public let changeNumber: @MainActor () -> Void

  /// The number the code was sent to, including the dial code.
  public let fullPhoneNumber: String

  /// Seconds left before ``resendCode`` is available; `0` when it is.
  public let resendCountdown: Int

  /// Whether ``verificationCode`` has 6 digits.
  public let isValid: Bool

  /// Whether a verify or resend is in flight, or the ``AuthService`` is signing in.
  public let isLoading: Bool

  /// The localized message of the last failed verify or resend. It clears when the code changes
  /// or the next attempt starts. The sheet's error alert still shows for the same failure.
  public let errorMessage: String?

  /// Creates a state, for example to preview custom content with stub actions.
  public init(verificationCode: Binding<String>,
              verify: @escaping @MainActor () -> Void,
              resendCode: @escaping @MainActor () -> Void,
              changeNumber: @escaping @MainActor () -> Void,
              fullPhoneNumber: String,
              resendCountdown: Int,
              isValid: Bool,
              isLoading: Bool,
              errorMessage: String?) {
    self.verificationCode = verificationCode
    self.verify = verify
    self.resendCode = resendCode
    self.changeNumber = changeNumber
    self.fullPhoneNumber = fullPhoneNumber
    self.resendCountdown = resendCountdown
    self.isValid = isValid
    self.isLoading = isLoading
    self.errorMessage = errorMessage
  }
}

/// The verification code screen, with its content drawn by you.
///
/// The screen signs in, resends codes, runs the resend countdown, and routes MFA, account
/// conflicts and errors. It reads `verificationID` once; codes it resends replace it
/// internally. Your content only draws the UI from the ``VerificationCodeContentState`` it
/// receives. Wrap ``DefaultEnterVerificationCodeContent`` to keep the stock markup.
///
/// Example:
/// ```swift
/// AuthPickerView { authenticatedApp }
///   .pickerDestination { screen in
///     switch screen {
///     case let .enterVerificationCode(verificationID, fullPhoneNumber):
///       EnterVerificationCodeScreen(
///         verificationID: verificationID,
///         fullPhoneNumber: fullPhoneNumber
///       ) { state in
///         TextField("Code", text: state.verificationCode)
///         Button("Verify", action: state.verify)
///           .disabled(!state.isValid || state.isLoading)
///       }
///     default:
///       DefaultAuthPickerDestination(screen: screen)
///     }
///   }
/// ```
@MainActor
public struct EnterVerificationCodeScreen<Content: View>: View {
  public init(verificationID: String,
              fullPhoneNumber: String,
              @ViewBuilder content: @escaping (VerificationCodeContentState) -> Content) {
    _verificationID = State(initialValue: verificationID)
    self.fullPhoneNumber = fullPhoneNumber
    self.content = content
  }

  @Environment(AuthService.self) private var authService
  @Environment(\.mfaHandler) private var mfaHandler
  @Environment(\.accountConflictHandler) private var accountConflictHandler
  @Environment(\.reportError) private var reportError
  @State private var verificationID: String
  @State private var verificationCode: String = ""
  @State private var resendAvailableAt = Date().addingTimeInterval(resendDelay)
  @State private var resendCountdown = Int(resendDelay)
  @State private var isWorking = false
  @State private var errorMessage: String?

  private let fullPhoneNumber: String
  private let content: (VerificationCodeContentState) -> Content

  public var body: some View {
    content(VerificationCodeContentState(
      verificationCode: $verificationCode,
      verify: verify,
      resendCode: resendCode,
      changeNumber: { authService.navigator.pop() },
      fullPhoneNumber: fullPhoneNumber,
      resendCountdown: resendCountdown,
      isValid: isValid,
      isLoading: isLoading,
      errorMessage: errorMessage
    ))
    .onChange(of: verificationCode) { errorMessage = nil }
    .task(id: resendAvailableAt) {
      while !Task.isCancelled {
        resendCountdown = max(0, Int(resendAvailableAt.timeIntervalSinceNow.rounded(.up)))
        guard resendCountdown > 0 else { return }
        try? await Task.sleep(for: .seconds(1))
      }
    }
  }

  private var isValid: Bool {
    verificationCode.count == 6
  }

  private var isLoading: Bool {
    isWorking || authService.authenticationState == .authenticating
  }

  private func verify() {
    guard isValid, !isLoading else { return }
    isWorking = true
    errorMessage = nil
    Task {
      defer { isWorking = false }
      do {
        let credential = PhoneAuthProvider.provider()
          .credential(withVerificationID: verificationID, verificationCode: verificationCode)
        switch try await authService.signIn(credentials: credential) {
        case let .mfaRequired(mfaInfo):
          mfaHandler?(mfaInfo)
        case .signedIn:
          authService.navigator.clear()
        }
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

  private func resendCode() {
    guard resendCountdown == 0, !isLoading else { return }
    isWorking = true
    errorMessage = nil
    Task {
      defer { isWorking = false }
      do {
        verificationID = try await authService.verifyPhoneNumber(phoneNumber: fullPhoneNumber)
        verificationCode = ""
        resendAvailableAt = Date().addingTimeInterval(resendDelay)
      } catch {
        errorMessage = authService.string.localizedErrorMessage(for: error)
        reportError?(error)
      }
    }
  }
}
