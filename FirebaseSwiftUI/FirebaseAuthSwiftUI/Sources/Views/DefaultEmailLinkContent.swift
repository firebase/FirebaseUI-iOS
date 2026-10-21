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

/// The stock content of ``EmailLinkScreen``.
@MainActor
public struct DefaultEmailLinkContent: View {
  public init(state: EmailLinkContentState) {
    self.state = state
  }

  @Environment(AuthService.self) private var authService
  private let state: EmailLinkContentState

  public var body: some View {
    VStack(spacing: 24) {
      AuthTextField(
        text: state.email,
        label: authService.string.signInLinkEmailFieldLabel,
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
      .accessibilityIdentifier("email-link-email-field")
      Button(action: state.sendSignInLink) {
        Text(authService.string.sendEmailLinkButtonLabel)
          .padding(.vertical, 8)
          .frame(maxWidth: .infinity)
      }
      .authCTAButtonStyle()
      .disabled(!state.isValid)
      .padding([.top, .bottom], 8)
      .frame(maxWidth: .infinity)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    .navigationTitle(authService.string.signInWithEmailLinkViewTitle)
    .safeAreaPadding()
    .alert(
      authService.string.signInWithEmailLinkViewTitle,
      isPresented: Binding(
        get: { state.didSend },
        set: { isPresented in
          if !isPresented {
            state.dismissAlert()
          }
        }
      )
    ) {
      Button(authService.string.okButtonLabel) {}
    } message: {
      Text(authService.string.signInWithEmailLinkViewMessage)
    }
  }
}
