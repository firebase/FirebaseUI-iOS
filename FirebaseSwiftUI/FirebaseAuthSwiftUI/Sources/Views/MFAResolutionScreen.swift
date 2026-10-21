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

/// The state and actions of the MFA resolution screen, passed to ``MFAResolutionScreen``'s
/// content.
public struct MFAResolutionContentState {
  /// The index in ``hints`` of the factor the user resolves with. Changing it clears
  /// ``verificationCode``, ``totpCode`` and ``isCodeSent``.
  public let selectedHintIndex: Binding<Int>

  /// The SMS code the user typed, for a phone hint.
  public let verificationCode: Binding<String>

  /// The authenticator app code the user typed, for a TOTP hint.
  public let totpCode: Binding<String>

  /// Sends an SMS code to the selected phone hint and sets ``isCodeSent``. Does nothing unless
  /// the selected hint is a phone hint and ``isLoading`` is `false`.
  public let sendCode: @MainActor () -> Void

  /// Completes sign-in with the code for the selected hint, then clears navigation. Does nothing
  /// unless ``isValid`` is `true` and ``isLoading`` is `false`.
  public let resolve: @MainActor () -> Void

  /// Abandons sign-in and clears navigation.
  public let cancel: @MainActor () -> Void

  /// The second factors the user can resolve with.
  public let hints: [MFAHint]

  /// Whether an SMS code was sent for the selected phone hint.
  public let isCodeSent: Bool

  /// Whether the code for the selected hint is non-empty.
  public let isValid: Bool

  /// Whether a send or resolve is in flight, or the ``AuthService`` is signing in.
  public let isLoading: Bool

  /// The localized message of the last failed send or resolve. It clears when a code or the
  /// selected hint changes or the next attempt starts. The sheet's error alert still shows for
  /// the same failure.
  public let errorMessage: String?

  /// Creates a state, for example to preview custom content with stub actions.
  public init(selectedHintIndex: Binding<Int>,
              verificationCode: Binding<String>,
              totpCode: Binding<String>,
              sendCode: @escaping @MainActor () -> Void,
              resolve: @escaping @MainActor () -> Void,
              cancel: @escaping @MainActor () -> Void,
              hints: [MFAHint],
              isCodeSent: Bool,
              isValid: Bool,
              isLoading: Bool,
              errorMessage: String?) {
    self.selectedHintIndex = selectedHintIndex
    self.verificationCode = verificationCode
    self.totpCode = totpCode
    self.sendCode = sendCode
    self.resolve = resolve
    self.cancel = cancel
    self.hints = hints
    self.isCodeSent = isCodeSent
    self.isValid = isValid
    self.isLoading = isLoading
    self.errorMessage = errorMessage
  }
}

/// The MFA resolution screen, with its content drawn by you.
///
/// The screen sends SMS codes, completes sign-in with the second factor, navigates, and reports
/// errors. Your content only draws the UI from the ``MFAResolutionContentState`` it receives.
/// Wrap ``DefaultMFAResolutionContent`` to keep the stock markup.
///
/// Example:
/// ```swift
/// AuthPickerView { authenticatedApp }
///   .pickerDestination { screen in
///     switch screen {
///     case let .mfaResolution(mfaRequired):
///       MFAResolutionScreen(mfaRequired: mfaRequired) { state in
///         TextField("Code", text: state.totpCode)
///         Button("Verify", action: state.resolve)
///           .disabled(!state.isValid || state.isLoading)
///       }
///     default:
///       DefaultAuthPickerDestination(screen: screen)
///     }
///   }
/// ```
@MainActor
public struct MFAResolutionScreen<Content: View>: View {
  public init(mfaRequired: MFARequired,
              @ViewBuilder content: @escaping (MFAResolutionContentState) -> Content) {
    self.mfaRequired = mfaRequired
    self.content = content
  }

  @Environment(AuthService.self) private var authService
  @Environment(\.reportError) private var reportError
  @State private var selectedHintIndex = 0
  @State private var verificationCode = ""
  @State private var totpCode = ""
  @State private var verificationId: String?
  @State private var isWorking = false
  @State private var errorMessage: String?

  private let mfaRequired: MFARequired
  private let content: (MFAResolutionContentState) -> Content

  public var body: some View {
    content(MFAResolutionContentState(
      selectedHintIndex: $selectedHintIndex,
      verificationCode: $verificationCode,
      totpCode: $totpCode,
      sendCode: sendCode,
      resolve: resolve,
      cancel: { authService.navigator.clear() },
      hints: mfaRequired.hints,
      isCodeSent: verificationId != nil,
      isValid: isValid,
      isLoading: isLoading,
      errorMessage: errorMessage
    ))
    .onChange(of: selectedHintIndex) {
      verificationCode = ""
      totpCode = ""
      verificationId = nil
      errorMessage = nil
    }
    .onChange(of: verificationCode) { errorMessage = nil }
    .onChange(of: totpCode) { errorMessage = nil }
  }

  private var selectedHint: MFAHint? {
    guard mfaRequired.hints.indices.contains(selectedHintIndex) else { return nil }
    return mfaRequired.hints[selectedHintIndex]
  }

  private var isValid: Bool {
    switch selectedHint {
    case .phone:
      return !verificationCode.isEmpty
    case .totp:
      return !totpCode.isEmpty
    case .none:
      return false
    }
  }

  private var isLoading: Bool {
    isWorking || authService.authenticationState == .authenticating
  }

  private func sendCode() {
    guard case .phone = selectedHint, !isLoading else { return }
    isWorking = true
    errorMessage = nil
    Task {
      defer { isWorking = false }
      do {
        verificationId = try await authService.resolveSmsChallenge(hintIndex: selectedHintIndex)
      } catch {
        errorMessage = authService.string.localizedErrorMessage(for: error)
        reportError?(error)
      }
    }
  }

  private func resolve() {
    guard let selectedHint, isValid, !isLoading else { return }
    isWorking = true
    errorMessage = nil
    Task {
      defer { isWorking = false }
      do {
        let code: String
        switch selectedHint {
        case .phone:
          code = verificationCode
        case .totp:
          code = totpCode
        }
        try await authService.resolveSignIn(
          code: code,
          hintIndex: selectedHintIndex,
          verificationId: verificationId
        )
        authService.navigator.clear()
      } catch {
        errorMessage = authService.string.localizedErrorMessage(for: error)
        reportError?(error)
      }
    }
  }
}
