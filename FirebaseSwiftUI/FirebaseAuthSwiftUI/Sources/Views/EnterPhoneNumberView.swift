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

@MainActor
struct EnterPhoneNumberView: View {
  @Environment(AuthService.self) private var authService
  @State private var phoneNumber: String = ""
  @State private var selectedCountry: CountryData = .default
  @State private var currentError: AlertError? = nil
  @State private var isProcessing: Bool = false

  let phoneProvider: PhoneAuthProviderSwift

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
        onChange: { _ in }
      ) {
        CountrySelector(
          selectedCountry: $selectedCountry,
          enabled: !isProcessing
        )
      }

      Button(action: {
        Task {
          isProcessing = true
          do {
            let fullPhoneNumber = selectedCountry.dialCode + phoneNumber
            let id = try await phoneProvider.verifyPhoneNumber(phoneNumber: fullPhoneNumber)
            authService.navigator.push(.enterVerificationCode(
              verificationID: id,
              fullPhoneNumber: fullPhoneNumber
            ))
            currentError = nil
          } catch {
            currentError = AlertError(message: error.localizedDescription)
          }
          isProcessing = false
        }
      }) {
        if isProcessing {
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
      .disabled(isProcessing || phoneNumber.isEmpty)
      .padding(.top, 8)

      Spacer()
    }
    .navigationTitle(authService.string.phoneSignInTitle)
    .padding(.horizontal)
    .errorAlert(error: $currentError, okButtonLabel: authService.string.okButtonLabel)
  }
}

#Preview {
  FirebaseOptions.dummyConfigurationForPreview()

  class MockPhoneProvider: PhoneAuthProviderSwift {
    var id: String = "phone"

    func verifyPhoneNumber(phoneNumber _: String) async throws -> String {
      return "mock-verification-id"
    }

    func createAuthCredential() async throws -> AuthCredential {
      fatalError("Not implemented in preview")
    }
    
    func createAuthCredential(verificationId: String, verificationCode: String) async throws -> AuthCredential {
      fatalError("Not implemented in preview")
    }
  }

  return EnterPhoneNumberView(phoneProvider: MockPhoneProvider())
    .environment(AuthService())
}
