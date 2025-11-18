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
      // Alert for non-phone providers
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
        if let phoneNumber = coordinator.reauthContext?.phoneNumber {
          Text("For security, we need to verify your phone number: \(phoneNumber)")
        }
      }
      // Sheet for phone reauthentication (shown after alert confirmation)
      .sheet(isPresented: $coordinator.showingPhoneReauth) {
        if let phoneNumber = coordinator.reauthContext?.phoneNumber {
          PhoneReauthView(
            phoneNumber: phoneNumber,
            coordinator: coordinator
          )
        }
      }
  }

  private func performReauth() {
    Task {
      do {
        try await authService.reauthenticate()
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
