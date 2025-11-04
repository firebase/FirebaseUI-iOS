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
  
  // View-layer state for handling auto-linking flow
  @State private var pendingCredentialForLinking: AuthCredential?
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
              }
            }
        }
        .interactiveDismissDisabled(authService.configuration.interactiveDismissEnabled)
      }
      // View-layer logic: Intercept credential conflict errors and store for auto-linking
      .onChange(of: authService.currentError) { _, newValue in
        handleCredentialConflictError(newValue)
      }
      // View-layer logic: Auto-link pending credential after successful sign-in
      .onChange(of: authService.authenticationState) { _, newState in
        if newState == .authenticated {
          attemptAutoLinkPendingCredential()
        }
      }
  }
  
  /// View-layer logic: Handle credential conflict errors by storing credential for auto-linking
  private func handleCredentialConflictError(_ error: AlertError?) {
    guard let error = error,
          let nsError = error.underlyingError as? NSError else { return }
    
    // Check if this is a credential conflict error that should trigger auto-linking
    let shouldStoreCredential =
      nsError.code == AuthErrorCode.accountExistsWithDifferentCredential.rawValue || // 17007
      nsError.code == AuthErrorCode.credentialAlreadyInUse.rawValue ||               // 17025
      nsError.code == AuthErrorCode.emailAlreadyInUse.rawValue ||                    // 17020
      nsError.code == 17094                                                           // duplicate credential
    
    if shouldStoreCredential {
      // Extract the credential from the error and store it
      let credential = nsError.userInfo[AuthErrorUserInfoUpdatedCredentialKey] as? AuthCredential
      pendingCredentialForLinking = credential
      // Error still propagates to user via normal error modal
    }
  }
  
  /// View-layer logic: Attempt to link pending credential after successful sign-in
  private func attemptAutoLinkPendingCredential() {
    guard let credential = pendingCredentialForLinking else { return }
    
    Task {
      do {
        try await authService.linkAccounts(credentials: credential)
        // Successfully linked, clear the pending credential
        pendingCredentialForLinking = nil
      } catch {
        // Silently swallow linking errors - user is already signed in
        // Consumer's custom views can observe authService.currentError if they want to handle this
        pendingCredentialForLinking = nil
      }
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
    .errorAlert(
      error: $authService.currentError,
      okButtonLabel: authService.string.okButtonLabel
    )
  }

  @ViewBuilder
  var authMethodPicker: some View {
    GeometryReader { proxy in
      ScrollView {
        VStack(spacing: 24) {
          Image(Assets.firebaseAuthLogo)
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
    .padding(.horizontal, proxy.size.width * 0.18)
  }
}

#Preview {
  FirebaseOptions.dummyConfigurationForPreview()
  let authService = AuthService()
    .withEmailSignIn()
  return AuthPickerView().environment(authService)
}
