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

/// The state and actions of the phone number screen, passed to ``EnterPhoneNumberScreen``'s
/// content.
public struct PhoneNumberContentState {
  /// The national phone number, without the dial code.
  public let phoneNumber: Binding<String>

  /// The country whose dial code prefixes ``phoneNumber``.
  public let selectedCountry: Binding<CountryData>

  /// Sends a verification code to the full phone number, then pushes
  /// ``AuthView/enterVerificationCode(verificationID:fullPhoneNumber:)``. Does nothing unless
  /// ``isValid`` is `true` and ``isLoading`` is `false`.
  public let sendCode: @MainActor () -> Void

  /// Whether ``phoneNumber`` is non-empty.
  public let isValid: Bool

  /// Whether a code is being sent, or the ``AuthService`` is signing in.
  public let isLoading: Bool

  /// The localized message of the last failed attempt. It clears when the number or country
  /// changes or the next attempt starts. The sheet's error alert still shows for the same failure.
  public let errorMessage: String?

  /// Creates a state, for example to preview custom content with stub actions.
  public init(phoneNumber: Binding<String>,
              selectedCountry: Binding<CountryData>,
              sendCode: @escaping @MainActor () -> Void,
              isValid: Bool,
              isLoading: Bool,
              errorMessage: String?) {
    self.phoneNumber = phoneNumber
    self.selectedCountry = selectedCountry
    self.sendCode = sendCode
    self.isValid = isValid
    self.isLoading = isLoading
    self.errorMessage = errorMessage
  }
}

/// The phone number screen, with its content drawn by you.
///
/// The screen sends the code, navigates, and reports errors. Your content only draws the UI from
/// the ``PhoneNumberContentState`` it receives. Wrap ``DefaultEnterPhoneNumberContent`` to keep
/// the stock markup.
///
/// Example:
/// ```swift
/// AuthPickerView { authenticatedApp }
///   .pickerDestination { screen in
///     switch screen {
///     case .enterPhoneNumber:
///       EnterPhoneNumberScreen { state in
///         TextField("Phone number", text: state.phoneNumber)
///         Button("Send code", action: state.sendCode)
///           .disabled(!state.isValid || state.isLoading)
///       }
///     default:
///       DefaultAuthPickerDestination(screen: screen)
///     }
///   }
/// ```
@MainActor
public struct EnterPhoneNumberScreen<Content: View>: View {
  public init(@ViewBuilder content: @escaping (PhoneNumberContentState) -> Content) {
    self.content = content
  }

  @Environment(AuthService.self) private var authService
  @Environment(\.reportError) private var reportError
  @State private var phoneNumber: String = ""
  @State private var selectedCountry: CountryData = .default
  @State private var isWorking = false
  @State private var errorMessage: String?

  private let content: (PhoneNumberContentState) -> Content

  public var body: some View {
    content(PhoneNumberContentState(
      phoneNumber: $phoneNumber,
      selectedCountry: $selectedCountry,
      sendCode: sendCode,
      isValid: isValid,
      isLoading: isLoading,
      errorMessage: errorMessage
    ))
    .onChange(of: phoneNumber) { errorMessage = nil }
    .onChange(of: selectedCountry) { errorMessage = nil }
  }

  private var isValid: Bool {
    !phoneNumber.isEmpty
  }

  private var isLoading: Bool {
    isWorking || authService.authenticationState == .authenticating
  }

  private func sendCode() {
    guard isValid, !isLoading else { return }
    isWorking = true
    errorMessage = nil
    Task {
      defer { isWorking = false }
      do {
        let fullPhoneNumber = selectedCountry.dialCode + phoneNumber
        let id = try await authService.verifyPhoneNumber(phoneNumber: fullPhoneNumber)
        authService.navigator.push(.enterVerificationCode(
          verificationID: id,
          fullPhoneNumber: fullPhoneNumber
        ))
      } catch {
        errorMessage = authService.string.localizedErrorMessage(for: error)
        reportError?(error)
      }
    }
  }
}
