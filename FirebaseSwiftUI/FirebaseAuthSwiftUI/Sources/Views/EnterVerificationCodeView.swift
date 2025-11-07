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
struct EnterVerificationCodeView: View {
  @Environment(AuthService.self) private var authService
  @Environment(\.accountConflictHandler) private var accountConflictHandler
  @Environment(\.reportError) private var reportError
  @State private var verificationCode: String = ""

  let verificationID: String
  let fullPhoneNumber: String

  var body: some View {
    @Bindable var authService = authService
    VStack(spacing: 32) {
      VStack(spacing: 16) {
        VStack(spacing: 8) {
          Text(authService.string.sentCodeMessage(phoneNumber: fullPhoneNumber))
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, alignment: .leading)

          Button {
            authService.navigator.pop()
          } label: {
            Text(authService.string.changeNumberButtonLabel)
              .font(.caption)
              .frame(maxWidth: .infinity, alignment: .leading)
          }
        }
        .padding(.bottom)
        .frame(maxWidth: .infinity, alignment: .leading)

        VerificationCodeInputField(
          code: $verificationCode,
          validations: [
            FormValidators.verificationCode
          ],
          maintainsValidationMessage: true
        )

        Button(action: {
          Task {
            do {
              try await authService.signInWithPhoneNumber(
                verificationID: verificationID,
                verificationCode: verificationCode
              )
              authService.navigator.clear()
            } catch {
              reportError?(error)

              if case let AuthServiceError.accountConflict(ctx) = error,
                 let onConflict = accountConflictHandler {
                onConflict(ctx)
                return
              }

              throw error
            }
          }
        }) {
          if authService.authenticationState == .authenticating {
            ProgressView()
              .frame(height: 32)
              .frame(maxWidth: .infinity)
          } else {
            Text(authService.string.verifyAndSignInButtonLabel)
              .frame(height: 32)
              .frame(maxWidth: .infinity)
          }
        }
        .buttonStyle(.borderedProminent)
        .disabled(authService.authenticationState == .authenticating || verificationCode.count != 6)
      }

      Spacer()
    }
    .navigationTitle(authService.string.enterVerificationCodeTitle)
    .navigationBarTitleDisplayMode(.large)
    .padding(.horizontal)
  }
}

#Preview {
  FirebaseOptions.dummyConfigurationForPreview()

  return NavigationStack {
    EnterVerificationCodeView(
      verificationID: "mock-id",
      fullPhoneNumber: "+1 5551234567",
    )
    .environment(AuthService())
  }
}
