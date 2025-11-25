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
import FirebaseCore
import SwiftUI

public struct PasswordRecoveryView {
  @Environment(AuthService.self) private var authService
  @State private var email = ""
  @State private var showSuccessSheet = false
  @State private var sentEmail = ""

  public init() {}

  private func sendPasswordRecoveryEmail() async {
    do {
      try await authService.sendPasswordRecoveryEmail(email: email)
      sentEmail = email
      showSuccessSheet = true
    } catch {
      // Error already displayed via modal by AuthService
    }
  }
}

extension PasswordRecoveryView: View {
  public var body: some View {
    VStack(spacing: 24) {
      AuthTextField(
        text: $email,
        label: authService.string.passwordRecoveryEmailFieldLabel,
        prompt: authService.string.emailInputLabel,
        keyboardType: .emailAddress,
        contentType: .emailAddress,
        validations: [
          FormValidators.email,
        ],
        leading: {
          Image(systemName: "at")
        }
      )
      Button(action: {
        Task {
          await sendPasswordRecoveryEmail()
        }
      }) {
        Text(authService.string.forgotPasswordInputLabel)
          .padding(.vertical, 8)
          .frame(maxWidth: .infinity)
      }
      .disabled(!CommonUtils.isValidEmail(email))
      .frame(maxWidth: .infinity)
      .buttonStyle(.borderedProminent)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    .navigationTitle(authService.string.passwordRecoveryTitle)
    .safeAreaPadding()
    .sheet(isPresented: $showSuccessSheet) {
      successSheet
    }
  }

  @ViewBuilder
  @MainActor
  private var successSheet: some View {
    VStack {
      Text(authService.string.passwordRecoveryEmailSentTitle)
        .font(.largeTitle)
        .fontWeight(.bold)
        .padding()
      Text(authService.string.passwordRecoveryHelperMessage)
        .padding()

      Divider()

      Text(String(format: authService.string.passwordRecoveryEmailSentMessage, sentEmail))
        .padding()

      Divider()

      Button(authService.string.okButtonLabel) {
        showSuccessSheet = false
        email = ""
        authService.navigator.clear()
      }
      .padding()
    }
    .padding()
  }
}

#Preview {
  FirebaseOptions.dummyConfigurationForPreview()
  return PasswordRecoveryView()
    .environment(AuthService())
}
