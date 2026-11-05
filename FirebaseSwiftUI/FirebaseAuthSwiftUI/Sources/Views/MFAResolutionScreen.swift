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
  /// The index in ``hints`` of the factor the user resolves with. Setting it, even to the
  /// current index, clears ``verificationCode``, ``totpCode`` and ``isCodeSent``.
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

  /// Whether ``resolve`` has what it needs: for a phone hint, a sent code and a non-empty
  /// ``verificationCode``; for a TOTP hint, a non-empty ``totpCode``.
  public let isValid: Bool

  /// Whether a send or resolve is in flight, or the ``AuthService`` is signing in.
  public let isLoading: Bool

  /// The localized message of the last failed send or resolve. It clears when a code or the
  /// selected hint changes or the next attempt starts. The sheet's error alert still shows for
  /// the same failure.
  public let errorMessage: String?

  /// Creates a state, for example to preview custom content with stub actions. Every parameter
  /// has a default, so pass only what the preview needs; later releases add new parameters
  /// with defaults too.
  public init(selectedHintIndex: Binding<Int> = .constant(0),
              verificationCode: Binding<String> = .constant(""),
              totpCode: Binding<String> = .constant(""),
              sendCode: @escaping @MainActor () -> Void = {},
              resolve: @escaping @MainActor () -> Void = {},
              cancel: @escaping @MainActor () -> Void = {},
              hints: [MFAHint] = [],
              isCodeSent: Bool = false,
              isValid: Bool = false,
              isLoading: Bool = false,
              errorMessage: String? = nil) {
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
  @State private var challenge = MFAResolutionContentState.Challenge()
  @State private var isWorking = false
  @State private var errorMessage: String?

  private let mfaRequired: MFARequired
  private let content: (MFAResolutionContentState) -> Content

  public var body: some View {
    // A single container, so the modifiers attach once even when the content returns several
    // views.
    VStack(spacing: 0) {
      content(MFAResolutionContentState(
        selectedHintIndex: Binding(get: { challenge.selectedHintIndex }, set: { selectHint($0) }),
        verificationCode: $challenge.verificationCode,
        totpCode: $challenge.totpCode,
        sendCode: sendCode,
        resolve: resolve,
        cancel: { authService.navigator.clear() },
        hints: mfaRequired.hints,
        isCodeSent: challenge.isCodeSent,
        isValid: challenge.isValid(hints: mfaRequired.hints),
        isLoading: isLoading,
        errorMessage: errorMessage
      ))
    }
    .onChange(of: challenge.verificationCode) { errorMessage = nil }
    .onChange(of: challenge.totpCode) { errorMessage = nil }
  }

  private func selectHint(_ index: Int) {
    challenge.selectHint(index)
    errorMessage = nil
  }

  private var isLoading: Bool {
    isWorking || authService.authenticationState == .authenticating
  }

  private func sendCode() {
    guard challenge.canSendCode(hints: mfaRequired.hints, isLoading: isLoading) else { return }
    isWorking = true
    errorMessage = nil
    let hintIndex = challenge.selectedHintIndex
    Task {
      defer { isWorking = false }
      do {
        let id = try await authService.resolveSmsChallenge(hintIndex: hintIndex)
        challenge.acceptCode(verificationId: id, sentForHint: hintIndex)
      } catch {
        errorMessage = authService.string.localizedErrorMessage(for: error)
        reportError?(error)
      }
    }
  }

  private func resolve() {
    // Captured before the task, so a hint switch mid-tap cannot mix one hint's code with
    // another's index.
    guard let request = challenge.resolveRequest(hints: mfaRequired.hints, isLoading: isLoading)
    else { return }
    isWorking = true
    errorMessage = nil
    Task {
      defer { isWorking = false }
      do {
        try await authService.resolveSignIn(
          code: request.code,
          hintIndex: request.hintIndex,
          verificationId: request.verificationId
        )
        authService.navigator.clear()
      } catch {
        errorMessage = authService.string.localizedErrorMessage(for: error)
        reportError?(error)
      }
    }
  }
}

extension MFAResolutionContentState {
  /// The user's progress through one hint: which hint is selected, the typed codes, and the
  /// verification ID of a sent SMS code.
  struct Challenge: Equatable {
    var selectedHintIndex = 0
    var verificationCode = ""
    var totpCode = ""
    var verificationId: String?

    /// The inputs ``MFAResolutionContentState/resolve`` sends, captured at tap time.
    struct ResolveRequest: Equatable {
      let code: String
      let hintIndex: Int
      let verificationId: String?
    }

    var isCodeSent: Bool {
      verificationId != nil
    }

    func selectedHint(in hints: [MFAHint]) -> MFAHint? {
      hints.indices.contains(selectedHintIndex) ? hints[selectedHintIndex] : nil
    }

    /// Selects a hint and clears the codes and any sent code, even when `index` is already
    /// selected.
    mutating func selectHint(_ index: Int) {
      self = Challenge(selectedHintIndex: index)
    }

    /// Stores the verification ID of a code sent for `hintIndex`, unless the user has since
    /// selected another hint.
    mutating func acceptCode(verificationId: String, sentForHint hintIndex: Int) {
      guard hintIndex == selectedHintIndex else { return }
      self.verificationId = verificationId
    }

    func isValid(hints: [MFAHint]) -> Bool {
      switch selectedHint(in: hints) {
      case .phone:
        isCodeSent && !verificationCode.isEmpty
      case .totp:
        !totpCode.isEmpty
      case .none:
        false
      }
    }

    func canSendCode(hints: [MFAHint], isLoading: Bool) -> Bool {
      guard case .phone = selectedHint(in: hints) else { return false }
      return !isLoading
    }

    func resolveRequest(hints: [MFAHint], isLoading: Bool) -> ResolveRequest? {
      guard let hint = selectedHint(in: hints), isValid(hints: hints), !isLoading else {
        return nil
      }
      let code = switch hint {
      case .phone: verificationCode
      case .totp: totpCode
      }
      return ResolveRequest(
        code: code,
        hintIndex: selectedHintIndex,
        verificationId: verificationId
      )
    }
  }
}
