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

// MARK: - Merge Conflict Handling

/// Helper function to handle sign-in with automatic merge conflict resolution.
///
/// This function attempts to sign in with the provided action. If a merge conflict occurs
/// (when an anonymous user is being upgraded and the credential is already associated with
/// an existing account), it automatically signs out the anonymous user and signs in with
/// the existing account's credential.
///
/// - Parameters:
///   - authService: The AuthService instance to use for sign-in operations
///   - signInAction: An async closure that performs the sign-in operation
/// - Returns: The SignInOutcome from the successful sign-in
/// - Throws: Re-throws any errors except accountMergeConflict (which is handled internally)
@MainActor
public func signInWithMergeConflictHandling(authService: AuthService,
                                            signInAction: () async throws
                                              -> SignInOutcome) async throws -> SignInOutcome {
  do {
    return try await signInAction()
  } catch let error as AuthServiceError {
    if case let .accountMergeConflict(context) = error {
      // The anonymous account conflicts with an existing account
      // Sign out the anonymous user
      try await authService.signOut()

      // Sign in with the existing account's credential
      // This works because shouldHandleAnonymousUpgrade is now false after sign out
      return try await authService.signIn(credentials: context.credential)
    }
    throw error
  }
}

// MARK: - Environment Key for Sign-In Handler

/// Environment key for a sign-in handler that includes merge conflict resolution
private struct SignInHandlerKey: EnvironmentKey {
  static let defaultValue: (@MainActor (AuthService, () async throws -> SignInOutcome) async throws
    -> SignInOutcome)? = nil
}

public extension EnvironmentValues {
  /// A sign-in handler that automatically handles merge conflicts for anonymous user upgrades.
  /// When set in the environment, views should use this handler to wrap their sign-in calls.
  var signInWithMergeConflictHandler: (@MainActor (AuthService,
                                                   () async throws -> SignInOutcome) async throws
      -> SignInOutcome)? {
    get { self[SignInHandlerKey.self] }
    set { self[SignInHandlerKey.self] = newValue }
  }
}

@MainActor
public struct AuthPickerView<Content: View> {
  public init(@ViewBuilder content: @escaping () -> Content = { EmptyView() }) {
    self.content = content
  }

  @Environment(AuthService.self) private var authService
  private let content: () -> Content
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
                if let phoneProvider = authService.currentPhoneProvider {
                  EnterPhoneNumberView(phoneProvider: phoneProvider)
                } else {
                  EmptyView()
                }
              case let .enterVerificationCode(verificationID, fullPhoneNumber):
                if let phoneProvider = authService.currentPhoneProvider {
                  EnterVerificationCodeView(
                    verificationID: verificationID,
                    fullPhoneNumber: fullPhoneNumber,
                    phoneProvider: phoneProvider
                  )
                } else {
                  EmptyView()
                }
              }
            }
        }
        .interactiveDismissDisabled(authService.configuration.interactiveDismissEnabled)
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
      if authService.authenticationState == .unauthenticated {
        authMethodPicker
          .safeAreaPadding()
      } else {
        SignedInView()
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
            EmailAuthView().environment(\.signInWithMergeConflictHandler, signInWithMergeConflictHandling)
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
    .environment(\.signInWithMergeConflictHandler, signInWithMergeConflictHandling)
  }
}

#Preview {
  FirebaseOptions.dummyConfigurationForPreview()
  let authService = AuthService()
    .withEmailSignIn()
  return AuthPickerView().environment(authService)
}
