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
      .authenticationFlow == .signIn ? .signUp : .signIn
  }

  @ViewBuilder
  private var authPickerTitleView: some View {
    if authService.authView == .authPicker {
      Text(authService.string.authPickerTitle)
        .font(.largeTitle)
        .fontWeight(.bold)
        .padding()
    }
  }
}

extension AuthPickerView: View {
  public var body: some View {
    ScrollView {
      VStack {
        authPickerTitleView
        if authService.authenticationState == .authenticated {
          switch authService.authView {
          case .mfaEnrollment:
            MFAEnrolmentView()
          case .mfaManagement:
            MFAManagementView()
          default:
            SignedInView()
          }
        } else {
          switch authService.authView {
          case .passwordRecovery:
            PasswordRecoveryView()
          case .emailLink:
            EmailLinkView()
          case .mfaEnrollment:
            MFAEnrolmentView()
          case .mfaResolution:
            MFAResolutionView()  
          case .authPicker:
            if authService.emailSignInEnabled {
              Text(authService.authenticationFlow == .signIn ? authService.string
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
                  .authenticationFlow == .signIn ? authService.string.dontHaveAnAccountYetLabel :
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
                }.accessibilityIdentifier("switch-auth-flow")
              }
            }
            PrivacyTOCsView(displayMode: .footer)
          default:
            // TODO: - possibly refactor this, see: https://github.com/firebase/FirebaseUI-iOS/pull/1259#discussion_r2105473437
            EmptyView()
          }
        }
      }
    }
    .errorAlert(error: Binding(
      get: { authService.currentError },
      set: { authService.currentError = $0 }
    ), okButtonLabel: authService.string.okButtonLabel)
  }
}

#Preview {
  FirebaseOptions.dummyConfigurationForPreview()
  let authService = AuthService()
    .withEmailSignIn()
  return AuthPickerView().environment(authService)
}
