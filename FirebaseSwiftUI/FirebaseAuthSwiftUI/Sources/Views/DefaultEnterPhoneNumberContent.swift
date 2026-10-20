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

/// The stock content of ``EnterPhoneNumberScreen``.
@MainActor
public struct DefaultEnterPhoneNumberContent: View {
  public init(state: PhoneNumberContentState) {
    self.state = state
  }

  @Environment(AuthService.self) private var authService
  private let state: PhoneNumberContentState

  public var body: some View {
    VStack(spacing: 16) {
      Text(authService.string.enterPhoneNumberPlaceholder)
        .authFont(.subheadline)
        .foregroundStyle(.secondary)
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top)

      AuthTextField(
        text: state.phoneNumber,
        label: authService.string.phoneFieldLabel,
        prompt: authService.string.enterPhoneNumberPlaceholder,
        keyboardType: .phonePad,
        contentType: .telephoneNumber,
        validations: [
          FormValidators.phoneNumber,
        ],
        onChange: { _ in }
      ) {
        CountrySelector(
          selectedCountry: state.selectedCountry,
          enabled: !state.isLoading
        )
      }

      Button(action: state.sendCode) {
        if state.isLoading {
          ProgressView()
            .frame(height: 32)
            .frame(maxWidth: .infinity)
        } else {
          Text(authService.string.sendCodeButtonLabel)
            .frame(height: 32)
            .frame(maxWidth: .infinity)
        }
      }
      .authCTAButtonStyle()
      .disabled(state.isLoading || !state.isValid)
      .padding(.top, 8)

      Spacer()
    }
    .navigationTitle(authService.string.phoneSignInTitle)
    .padding(.horizontal)
  }
}
