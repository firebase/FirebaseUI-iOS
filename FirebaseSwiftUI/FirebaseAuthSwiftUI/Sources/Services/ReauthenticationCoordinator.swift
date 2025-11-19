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
import Observation

/// Coordinator for handling reauthentication flows
@MainActor
@Observable
public final class ReauthenticationCoordinator {
  public var isReauthenticating = false
  public var reauthContext: ReauthenticationType?
  public var showingPhoneReauth = false
  public var showingPhoneReauthAlert = false
  public var showingEmailPasswordPrompt = false

  private var continuation: CheckedContinuation<Void, Error>?

  public init() {}

  /// Request reauthentication from the user
  public func requestReauth(context: ReauthenticationType) async throws {
    return try await withCheckedThrowingContinuation { continuation in
      self.continuation = continuation
      self.reauthContext = context

      // Route to appropriate flow based on context type
      switch context {
      case .phone:
        self.showingPhoneReauthAlert = true
      case .email:
        self.showingEmailPasswordPrompt = true
      case .oauth:
        // For OAuth providers (Google, Apple, etc.)
        self.isReauthenticating = true
      }
    }
  }

  /// Called when user confirms phone reauth alert
  public func confirmPhoneReauth() {
    showingPhoneReauthAlert = false
    showingPhoneReauth = true
  }

  /// Called when reauthentication completes successfully
  public func reauthCompleted() {
    continuation?.resume()
    cleanup()
  }

  /// Called when reauthentication is cancelled
  public func reauthCancelled() {
    continuation?.resume(throwing: AuthServiceError.signInCancelled("Reauthentication cancelled"))
    cleanup()
  }

  private func cleanup() {
    continuation = nil
    isReauthenticating = false
    showingPhoneReauth = false
    showingPhoneReauthAlert = false
    showingEmailPasswordPrompt = false
    reauthContext = nil
  }
}
