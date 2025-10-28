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
    authService.authenticationFlow =
      authService
        .authenticationFlow == .signIn ? .signUp : .signIn
  }
}

extension AuthPickerView: View {
  public var body: some View {
    authMethodPicker
      .safeAreaPadding()
      .navigationTitle(authService.string.authPickerTitle)
      .navigationBarTitleDisplayMode(.large)
      .errorAlert(
        error: Binding(
          get: { authService.currentError },
          set: { authService.currentError = $0 }
        ),
        okButtonLabel: authService.string.okButtonLabel
      )
  }

  @ViewBuilder
  var authMethodPicker: some View {
    GeometryReader { proxy in
      ScrollView {
        VStack(spacing: 24) {
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
                EmailAuthView()
              }
              if authService.emailSignInEnabled {
                Divider()
                HStack {
                  Text(
                    authService
                      .authenticationFlow == .signIn
                      ? authService.string.dontHaveAnAccountYetLabel
                      : authService.string.alreadyHaveAnAccountLabel
                  )
                  Button(action: {
                    withAnimation {
                      switchFlow()
                    }
                  }) {
                    Text(
                      authService.authenticationFlow == .signUp
                        ? authService.string
                          .emailLoginFlowLabel
                        : authService.string.emailSignUpFlowLabel
                    )
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                  }.accessibilityIdentifier("switch-auth-flow")
                }
              }
              otherSignInOptions(proxy)
              tosAndPPFooter
            //PrivacyTOCsView(displayMode: .footer)
            default:
              // TODO: - possibly refactor this, see: https://github.com/firebase/FirebaseUI-iOS/pull/1259#discussion_r2105473437
              EmptyView()
            }
          }
        }
      }
    }
  }

  @ViewBuilder
  func otherSignInOptions(_ proxy: GeometryProxy) -> some View {
    VStack {
      authService.renderButtons()
    }
    .padding(.horizontal, proxy.size.width * 0.18)
  }

  @ViewBuilder
  var tosAndPPFooter: some View {
    AnnotatedString(
      fullText:
        "By continuing, you accept our Terms of Service and Privacy Policy.",
      links: [
        ("Terms of Service", "https://example.com/terms"),
        ("Privacy Policy", "https://example.com/privacy"),
      ]
    )
  }
}

#Preview {
  FirebaseOptions.dummyConfigurationForPreview()
  let authService = AuthService()
    .withEmailSignIn()
  return AuthPickerView().environment(authService)
}
