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
import FirebaseAuthUIComponents
import FirebaseCore
import SwiftUI

struct EnterPhoneNumberView: View {
  @Environment(AuthService.self) private var authService
  @Environment(\.reportError) private var reportError
  @State private var phoneNumber: String = ""
  @State private var selectedCountry: CountryData = .default

  var body: some View {
    VStack(spacing: 16) {
      Text(authService.string.enterPhoneNumberPlaceholder)
        .font(.subheadline)
        .foregroundStyle(.secondary)
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top)

      AuthTextField(
        text: $phoneNumber,
        label: authService.string.phoneFieldLabel,
        prompt: authService.string.enterPhoneNumberPlaceholder,
        keyboardType: .phonePad,
        contentType: .telephoneNumber,
        validations: [
          FormValidators.phoneNumber
        ],
        onChange: { _ in }
      ) {
        CountrySelector(
          selectedCountry: $selectedCountry,
          enabled: !(authService.authenticationState == .authenticating)
        )
      }

      Button(action: {
        Task {
          do {
            let fullPhoneNumber = selectedCountry.dialCode + phoneNumber
            let id = try await authService.verifyPhoneNumber(phoneNumber: fullPhoneNumber)
            authService.navigator.push(.enterVerificationCode(
              verificationID: id,
              fullPhoneNumber: fullPhoneNumber
            ))
          } catch {
            if let errorHandler = reportError {
              errorHandler(error)
            } else {
              throw error
            }
          }
        }
      }) {
        if authService.authenticationState == .authenticating {
          ProgressView()
            .frame(height: 32)
            .frame(maxWidth: .infinity)
        } else {
          Text(authService.string.sendCodeButtonLabel)
            .frame(height: 32)
            .frame(maxWidth: .infinity)
        }
      }
      .buttonStyle(.borderedProminent)
      .disabled(authService.authenticationState == .authenticating || phoneNumber.isEmpty)
      .padding(.top, 8)

      Spacer()
    }
    .navigationTitle(authService.string.phoneSignInTitle)
    .padding(.horizontal)
  }
}

#Preview {
  FirebaseOptions.dummyConfigurationForPreview()

  return EnterPhoneNumberView()
    .environment(AuthService())
}
