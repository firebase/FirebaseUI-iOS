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
public struct AuthPickerView<Content: View> {
  public init(@ViewBuilder content: @escaping () -> Content = { EmptyView() }) {
    self.content = content
  }

  @Environment(AuthService.self) private var authService
  private let content: () -> Content

  // View-layer error state
  @State private var error: AlertError?
}

extension AuthPickerView: View {
  public var body: some View {
    @Bindable var authService = authService
    content()
      .sheet(isPresented: $authService.isPresented) {
        @Bindable var navigator = authService.navigator
        NavigationStack(path: $navigator.routes) {
          authPickerViewInternal
            .navigationTitle(authService.authenticationState == .unauthenticated ? authService
              .string.authPickerTitle : "")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
              toolbar
            }
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
                EnterPhoneNumberView()
              case let .enterVerificationCode(verificationID, fullPhoneNumber):
                EnterVerificationCodeView(
                  verificationID: verificationID,
                  fullPhoneNumber: fullPhoneNumber
                )
              }
            }
        }
        .environment(\.reportError, reportError)
        .errorAlert(
          error: $error,
          okButtonLabel: authService.string.okButtonLabel
        )
        .interactiveDismissDisabled(authService.configuration.interactiveDismissEnabled)
        // Apply account conflict handling at NavigationStack level
        .accountConflictHandler()
        // Apply MFA handling at NavigationStack level
        .mfaHandler()
      }
  }

  /// Closure for reporting errors from child views
  private func reportError(_ error: Error) {
    Task { @MainActor in
      self.error = AlertError(
        message: authService.string.localizedErrorMessage(for: error),
        underlyingError: error
      )
    }
  }

  @ToolbarContentBuilder
  var toolbar: some ToolbarContent {
    ToolbarItem(placement: .topBarTrailing) {
      if !authService.configuration.shouldHideCancelButton {
        Button {
          authService.isPresented = false
        } label: {
          Image(systemName: "xmark")
            .foregroundStyle(Color(UIColor.label))
        }
      }
    }
  }

  @ViewBuilder
  var authPickerViewInternal: some View {
    @Bindable var authService = authService
    VStack {
      if authService.authenticationState == .authenticated {
        SignedInView()
      } else {
        authMethodPicker
          .safeAreaPadding()
      }
    }
    .overlay {
      if authService.authenticationState == .authenticating {
        VStack(spacing: 24) {
          ProgressView()
            .scaleEffect(1.25)
            .tint(.white)
          Text("Authenticating...")
            .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.black.opacity(0.7))
      }
    }
  }

  @ViewBuilder
  var authMethodPicker: some View {
    GeometryReader { proxy in
      ScrollView {
        VStack(spacing: 24) {
          Image(authService.configuration.logo ?? Assets.firebaseAuthLogo)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 100, height: 100)
          if authService.emailSignInEnabled {
            EmailAuthView()
          }
          Divider()
          otherSignInOptions(proxy)
          PrivacyTOCsView(displayMode: .full)
        }
      }
    }
  }

  @ViewBuilder
  func otherSignInOptions(_ proxy: GeometryProxy) -> some View {
    VStack {
      authService.renderButtons()
    }
    .padding(.horizontal, proxy.size.width * 0.14)
  }
}

#Preview {
  FirebaseOptions.dummyConfigurationForPreview()
  let authService = AuthService()
    .withEmailSignIn()
  return AuthPickerView().environment(authService)
}
