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

import FirebaseAuthSwiftUI
import FirebaseAuthUIComponents
import SwiftUI

/// A generic OAuth sign-in button that adapts to any provider's configuration
@MainActor
public struct GenericOAuthButton {
  @Environment(AuthService.self) private var authService
  @Environment(\.accountConflictHandler) private var accountConflictHandler
  @Environment(\.mfaHandler) private var mfaHandler
  @Environment(\.reportError) private var reportError
  let provider: OAuthProviderSwift
  public init(provider: OAuthProviderSwift) {
    self.provider = provider
  }
}

extension GenericOAuthButton: View {
  public var body: some View {
    // Create custom style from provider configuration
    var resolvedStyle: ProviderStyle {
      ProviderStyle(
        icon: provider.buttonIcon,
        backgroundColor: provider.buttonBackgroundColor,
        contentColor: provider.buttonForegroundColor
      )
    }

    return AnyView(
      AuthProviderButton(
        label: provider.displayName,
        style: resolvedStyle,
        accessibilityId: "sign-in-with-\(provider.providerId)-button"
      ) {
        Task {
          do {
            let outcome = try await authService.signIn(provider)

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
    )
  }
}
