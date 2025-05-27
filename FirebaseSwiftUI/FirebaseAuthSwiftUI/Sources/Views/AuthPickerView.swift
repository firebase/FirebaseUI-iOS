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

@MainActor
public struct AuthPickerView {
  @Environment(AuthService.self) private var authService

  public init() {}

  private func switchFlow() {
    authService.authenticationFlow = authService
      .authenticationFlow == .login ? .signUp : .login
  }
}

extension AuthPickerView: View {
  public var body: some View {
    VStack {
      Text(authService.string.authPickerTitle)
        .font(.largeTitle)
        .fontWeight(.bold)
        .padding()
      if authService.authenticationState == .authenticated {
        SignedInView()
      } else if authService.authView == .passwordRecovery {
        PasswordRecoveryView()
      } else if authService.authView == .emailLink {
        EmailLinkView()
      } else {
        if authService.emailSignInEnabled {
          Text(authService.authenticationFlow == .login ? authService.string
            .emailLoginFlowLabel : authService.string.emailSignUpFlowLabel)
          Divider()
          EmailAuthView()
        }
        VStack {
          authService.renderButtons()
        }.padding(.horizontal)
        if authService.emailSignInEnabled {
          Divider()
          HStack {
            Text(authService
              .authenticationFlow == .login ? authService.string.dontHaveAnAccountYetLabel :
              authService.string.alreadyHaveAnAccountLabel)
            Button(action: {
              withAnimation {
                switchFlow()
              }
            }) {
              Text(authService.authenticationFlow == .signUp ? authService.string
                .emailLoginFlowLabel : authService.string.emailSignUpFlowLabel)
                .fontWeight(.semibold)
                .foregroundColor(.blue)
            }
          }
          PrivacyTOCsView(displayMode: .footer)
          Text(authService.errorMessage).foregroundColor(.red)
        }
      }
    }
  }
}

#Preview {
  FirebaseOptions.dummyConfigurationForPreview()
  let authService = AuthService()
    .withEmailSignIn()
  return AuthPickerView().environment(authService)
}
