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

/// View modifier for handling reauthentication flows
struct ReauthenticationModifier: ViewModifier {
  @Environment(AuthService.self) private var authService
  @Bindable var coordinator: ReauthenticationCoordinator

  func body(content: Content) -> some View {
    content
      // Alert for OAuth providers only (Google, Apple, etc.)
      .alert(
        "Authentication Required",
        isPresented: $coordinator.isReauthenticating
      ) {
        Button("Continue") {
          performReauth()
        }
        Button("Cancel", role: .cancel) {
          coordinator.reauthCancelled()
        }
      } message: {
        if let context = coordinator.reauthContext {
          Text(context.displayMessage)
        }
      }
      // Alert for phone provider
      .alert(
        "Phone Verification Required",
        isPresented: $coordinator.showingPhoneReauthAlert
      ) {
        Button("Proceed") {
          coordinator.confirmPhoneReauth()
        }
        Button("Cancel", role: .cancel) {
          coordinator.reauthCancelled()
        }
      } message: {
        if case let .phone(context) = coordinator.reauthContext {
          Text("For security, we need to verify your phone number: \(context.phoneNumber)")
        }
      }
      // Sheet for phone reauthentication
      .sheet(isPresented: $coordinator.showingPhoneReauth) {
        if case let .phone(context) = coordinator.reauthContext {
          PhoneReauthView(
            phoneNumber: context.phoneNumber,
            coordinator: coordinator
          )
        }
      }
      // Sheet for email reauthentication
      .sheet(isPresented: $coordinator.showingEmailPasswordPrompt) {
        if case let .email(context) = coordinator.reauthContext {
          EmailReauthView(
            email: context.email,
            coordinator: coordinator
          )
        }
      }
      // Alert for email link reauthentication
      .alert(
        "Email Verification Required",
        isPresented: $coordinator.showingEmailLinkReauthAlert
      ) {
        Button("Send Verification Email") {
          coordinator.confirmEmailLinkReauth()
        }
        Button("Cancel", role: .cancel) {
          coordinator.reauthCancelled()
        }
      } message: {
        if case let .emailLink(context) = coordinator.reauthContext {
          Text("We'll send a verification link to \(context.email). Tap the link to continue.")
        }
      }
      // Sheet for email link reauthentication
      .sheet(isPresented: $coordinator.showingEmailLinkReauth) {
        if case let .emailLink(context) = coordinator.reauthContext {
          EmailLinkReauthView(
            email: context.email,
            coordinator: coordinator
          )
        }
      }
  }

  private func performReauth() {
    Task {
      do {
        guard case let .oauth(context) = coordinator.reauthContext else { return }

        // For OAuth providers (Google, Apple, etc.), call reauthenticate with context
        try await authService.reauthenticate(context: context)
        coordinator.reauthCompleted()
      } catch {
        coordinator.reauthCancelled()
      }
    }
  }
}

public extension View {
  /// Adds reauthentication handling to the view
  /// - Parameter coordinator: The coordinator managing the reauthentication state
  /// - Returns: A view that can handle reauthentication flows
  func withReauthentication(coordinator: ReauthenticationCoordinator) -> some View {
    modifier(ReauthenticationModifier(coordinator: coordinator))
  }
}
