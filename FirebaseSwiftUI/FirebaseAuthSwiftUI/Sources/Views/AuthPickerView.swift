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
                .environment(\.signInWithMergeConflictHandler, signInWithMergeConflictHandling)
            }
            VStack {
              authService.renderButtons()
            }
            .padding(.horizontal)
            .environment(\.signInWithMergeConflictHandler, signInWithMergeConflictHandling)
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
