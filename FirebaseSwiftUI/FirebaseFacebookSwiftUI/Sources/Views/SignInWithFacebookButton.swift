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
import FirebaseAuthSwiftUI
import FirebaseAuthUIComponents
import FirebaseCore
import SwiftUI

/// A button for signing in with Facebook
@MainActor
public struct SignInWithFacebookButton {
  @Environment(AuthService.self) private var authService
  @Environment(\.accountConflictHandler) private var accountConflictHandler
  @Environment(\.mfaHandler) private var mfaHandler
  @Environment(\.reportError) private var reportError
  let facebookProvider: FacebookProviderSwift

  public init(facebookProvider: FacebookProviderSwift) {
    self.facebookProvider = facebookProvider
  }
}

extension SignInWithFacebookButton: View {
  public var body: some View {
    AuthProviderButton(
      label: authService.string.facebookLoginButtonLabel,
      style: .facebook,
      accessibilityId: "sign-in-with-facebook-button"
    ) {
      Task {
        do {
          let outcome = try await authService.signIn(facebookProvider)

          // Handle MFA at view level
          if case let .mfaRequired(mfaInfo) = outcome,
             let onMFA = mfaHandler {
            onMFA(mfaInfo)
            return
          }
        } catch {
          reportError?(error)

          if case let AuthServiceError.accountConflict(ctx) = error,
             let onConflict = accountConflictHandler {
            onConflict(ctx)
            return
          }

          throw error
        }
      }
    }
  }
}

#Preview {
  FirebaseOptions.dummyConfigurationForPreview()
  let facebookProvider = FacebookProviderSwift()
  return SignInWithFacebookButton(facebookProvider: facebookProvider)
    .environment(AuthService())
}
