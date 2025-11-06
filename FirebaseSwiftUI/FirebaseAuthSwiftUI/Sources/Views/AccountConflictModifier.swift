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
import SwiftUI

/// Environment key for accessing the account conflict handler
public struct AccountConflictHandlerKey: @preconcurrency EnvironmentKey {
  @MainActor public static let defaultValue: ((AccountConflictContext) -> Void)? = nil
}

public extension EnvironmentValues {
  var accountConflictHandler: ((AccountConflictContext) -> Void)? {
    get { self[AccountConflictHandlerKey.self] }
    set { self[AccountConflictHandlerKey.self] = newValue }
  }
}

/// View modifier that handles account conflicts at the view layer
/// Automatically resolves anonymous upgrade conflicts and stores credentials for other conflicts
@MainActor
struct AccountConflictModifier: ViewModifier {
  @Environment(AuthService.self) private var authService
  @State private var pendingCredentialForLinking: AuthCredential?

  func body(content: Content) -> some View {
    content
      .environment(\.accountConflictHandler, handleAccountConflict)
      .onChange(of: authService.authenticationState) { _, newState in
        // Auto-link pending credential after successful sign-in
        if newState == .authenticated {
          attemptAutoLinkPendingCredential()
        }
      }
  }

  /// Handle account conflicts - auto-resolve anonymous upgrades, store others for linking
  func handleAccountConflict(_ conflict: AccountConflictContext) {
    // Only auto-handle anonymous upgrade conflicts
    if conflict.conflictType == .anonymousUpgradeConflict {
      Task {
        do {
          // Sign out the anonymous user
          try await authService.signOut()

          // Sign in with the new credential
          _ = try await authService.signIn(credentials: conflict.credential)

          // Successfully handled - conflict is cleared automatically by reset()
        } catch {
          // Error will be shown via normal error handling
          // Credential is still stored if they want to retry
        }
      }
    } else {
      // Other conflicts: store credential for potential linking after sign-in
      pendingCredentialForLinking = conflict.credential
      // Error modal will show for user to see and handle
    }
  }

  /// Attempt to link pending credential after successful sign-in
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
}

extension View {
  /// Adds account conflict handling to the view hierarchy
  /// Should be applied at the NavigationStack level to handle conflicts throughout the auth flow
  func accountConflictHandler() -> some View {
    modifier(AccountConflictModifier())
  }
}
