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
import FirebaseCore
import SwiftUI

@MainActor
public struct AuthPickerView<Content: View> {
  public init(
    initialPath: AuthView = .authPicker,
    @ViewBuilder content: @escaping () -> Content = { EmptyView() }
  ) {
    self.initialPath = initialPath
    self.content = content
  }
  
  @Environment(AuthService.self) private var authService
  private let initialPath: AuthView
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
          initialPath.destination()
            .navigationDestination(for: AuthView.self) { path in
              path.destination()
            }
        }
        .interactiveDismissDisabled(authService.configuration.interactiveDismissEnabled)
      }
    // View-layer logic: Handle account conflicts (auto-handle anonymous upgrade, store others for
    // linking)
      .onChange(of: authService.currentAccountConflict) { _, conflict in
        handleAccountConflict(conflict)
      }
    // View-layer logic: Auto-link pending credential after successful sign-in
      .onChange(of: authService.authenticationState) { _, newState in
        if newState == .authenticated {
          attemptAutoLinkPendingCredential()
        }
      }
  }
  
  /// View-layer logic: Handle account conflicts with type-specific behavior
  private func handleAccountConflict(_ conflict: AccountConflictContext?) {
    guard let conflict = conflict else { return }
    
    // Only auto-handle anonymous upgrade conflicts
    if conflict.conflictType == .anonymousUpgradeConflict {
      Task {
        do {
          // Sign out the anonymous user
          try await authService.signOut()
          
          // Sign in with the new credential
          _ = try await authService.signIn(credentials: conflict.credential)
          
          // Successfully handled - conflict and error are cleared automatically by reset()
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
}

#Preview {
  FirebaseOptions.dummyConfigurationForPreview()
  let authService = AuthService()
    .withEmailSignIn()
  return AuthPickerView().environment(authService)
}
