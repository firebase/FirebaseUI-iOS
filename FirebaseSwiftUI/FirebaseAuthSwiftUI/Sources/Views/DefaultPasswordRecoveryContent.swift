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

/// The stock content of ``PasswordRecoveryScreen``.
@MainActor
public struct DefaultPasswordRecoveryContent: View {
  public init(state: PasswordRecoveryContentState) {
    self.state = state
  }

  @Environment(AuthService.self) private var authService
  private let state: PasswordRecoveryContentState

  public var body: some View {
    VStack(spacing: 24) {
      AuthTextField(
        text: state.email,
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
      Button(action: state.sendResetLink) {
        Text(authService.string.forgotPasswordInputLabel)
          .padding(.vertical, 8)
          .frame(maxWidth: .infinity)
      }
      .disabled(!state.isValid)
      .frame(maxWidth: .infinity)
      .authCTAButtonStyle()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    .navigationTitle(authService.string.passwordRecoveryTitle)
    .safeAreaPadding()
    .sheet(isPresented: Binding(
      get: { state.didSend },
      set: { isPresented in
        if !isPresented {
          state.dismissSuccess()
        }
      }
    )) {
      successSheet
    }
  }

  @ViewBuilder
  @MainActor
  private var successSheet: some View {
    VStack {
      Text(authService.string.passwordRecoveryEmailSentTitle)
        .authFont(.largeTitle)
        .fontWeight(.bold)
        .padding()
      Text(authService.string.passwordRecoveryHelperMessage)
        .authCustomFont(.body)
        .padding()

      Divider()

      Text(String(format: authService.string.passwordRecoveryEmailSentMessage, state.sentEmail))
        .authCustomFont(.body)
        .padding()

      Divider()

      Button(authService.string.okButtonLabel, action: state.dismissSuccess)
        .padding()
    }
    .padding()
  }
}
