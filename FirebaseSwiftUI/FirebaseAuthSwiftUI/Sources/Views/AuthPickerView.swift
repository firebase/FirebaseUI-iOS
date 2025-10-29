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
import FirebaseAuthUIComponents

@MainActor
public struct AuthPickerView<Content: View, Footer: View> {
  public init(
    isPresented: Binding<Bool> = .constant(false),
    interactiveDismissDisabled: Bool = true,
    @ViewBuilder content: @escaping () -> Content = { EmptyView() },
    @ViewBuilder footer: @escaping () -> Footer = { EmptyView() }
  ) {
    self.isPresented = isPresented
    self.interactiveDismissDisabled = interactiveDismissDisabled
    self.content = content
    self.footer = footer
  }
  
  @Environment(AuthService.self) private var authService
  private var isPresented: Binding<Bool>
  private var interactiveDismissDisabled: Bool
  private let content: () -> Content?
  private let footer: () -> Footer?
}

extension AuthPickerView: View {
  public var body: some View {
    content()
      .sheet(isPresented: isPresented) {
        @Bindable var navigator = authService.navigator
        NavigationStack(path: $navigator.routes) {
          authPickerViewInternal
            .navigationTitle(authService.string.authPickerTitle)
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(for: AuthView.self) { view in
              switch view {
              case AuthView.passwordRecovery:
                PasswordRecoveryView()
              case AuthView.emailLink:
                EmailLinkView()
              case AuthView.updatePassword:
                UpdatePasswordView()
              case AuthView.mfaEnrollment:
                MFAEnrolmentView()
              case AuthView.mfaManagement:
                MFAManagementView()
              case AuthView.mfaResolution:
                MFAResolutionView()
              case AuthView.enterPhoneNumber:
                if let phoneProvider = authService.currentPhoneProvider {
                  EnterPhoneNumberView(phoneProvider: phoneProvider)
                } else {
                  EmptyView()
                }
              default:
                EmptyView()
              }
            }
        }
        .interactiveDismissDisabled(interactiveDismissDisabled)
      }
  }
  
  @ViewBuilder
  var authPickerViewInternal: some View {
    authMethodPicker
      .safeAreaPadding()
      .onChange(of: authService.authViewRoutes) { oldValue, newValue in
        debugPrint("Got here: \(newValue)")
      }
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
          if authService.emailSignInEnabled {
            EmailAuthView()
          }
          otherSignInOptions(proxy)
          PrivacyTOCsView(displayMode: .full)
          footer()
        }
      }
    }
  }
  
  //  @ViewBuilder
  //  var authMethodPicker: some View {
  //    GeometryReader { proxy in
  //      ScrollView {
  //        VStack(spacing: 24) {
  //          if authService.authenticationState == .authenticated {
  //            switch authService.authView {
  //            case .mfaEnrollment:
  //              MFAEnrolmentView()
  //            case .mfaManagement:
  //              MFAManagementView()
  //            default:
  //              SignedInView()
  //            }
  //          } else {
  //            switch authService.authView {
  //            case .passwordRecovery:
  //              PasswordRecoveryView()
  //            case .emailLink:
  //              EmailLinkView()
  //            case .mfaEnrollment:
  //              MFAEnrolmentView()
  //            case .mfaResolution:
  //              MFAResolutionView()
  //            case .authPicker:
  //              if authService.emailSignInEnabled {
  //                EmailAuthView()
  //              }
  //              otherSignInOptions(proxy)
  //              PrivacyTOCsView(displayMode: .full)
  //            default:
  //              // TODO: - possibly refactor this, see: https://github.com/firebase/FirebaseUI-iOS/pull/1259#discussion_r2105473437
  //              EmptyView()
  //            }
  //          }
  //        }
  //      }
  //    }
  //  }
  
  @ViewBuilder
  func otherSignInOptions(_ proxy: GeometryProxy) -> some View {
    VStack {
      authService.renderButtons()
    }
    .padding(.horizontal, proxy.size.width * 0.18)
  }
}

#Preview {
  FirebaseOptions.dummyConfigurationForPreview()
  let authService = AuthService()
    .withEmailSignIn()
  return AuthPickerView().environment(authService)
}
