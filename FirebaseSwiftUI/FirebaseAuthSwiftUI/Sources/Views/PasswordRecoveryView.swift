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
    VStack {
      HStack {
        Button(action: {
          authService.authView = .authPicker
        }) {
          HStack(spacing: 4) {
            Image(systemName: "chevron.left")
              .font(.system(size: 17, weight: .medium))
            Text(authService.string.backButtonLabel)
              .font(.system(size: 17))
          }
          .foregroundColor(.blue)
        }
        .accessibilityIdentifier("password-recovery-back-button")

        Spacer()
      }
      .padding(.horizontal)
      .padding(.top, 8)
      Text(authService.string.passwordRecoveryTitle)
        .font(.largeTitle)
        .fontWeight(.bold)
        .padding()
        .accessibilityIdentifier("password-recovery-text")

      Divider()

      LabeledContent {
        TextField(authService.string.emailInputLabel, text: $email)
          .textInputAutocapitalization(.never)
          .disableAutocorrection(true)
          .submitLabel(.next)
      } label: {
        Image(systemName: "at")
      }
      .padding(.vertical, 6)
      .background(Divider(), alignment: .bottom)
      .padding(.bottom, 4)

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
      .padding([.top, .bottom, .horizontal], 8)
      .frame(maxWidth: .infinity)
      .buttonStyle(.borderedProminent)
    }
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
        authService.authView = .authPicker
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
