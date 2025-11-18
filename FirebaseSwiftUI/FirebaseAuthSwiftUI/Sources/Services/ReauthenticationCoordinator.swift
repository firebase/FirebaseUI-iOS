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

/// Context information for reauthentication UI
public struct ReauthContext {
  public let providerId: String
  public let providerName: String
  public let phoneNumber: String?
  public let email: String?

  public init(providerId: String, providerName: String, phoneNumber: String?, email: String?) {
    self.providerId = providerId
    self.providerName = providerName
    self.phoneNumber = phoneNumber
    self.email = email
  }

  public var displayMessage: String {
    switch providerId {
    case EmailAuthProviderID:
      return "Please enter your password to continue"
    case PhoneAuthProviderID:
      return "Please verify your phone number to continue"
    default:
      return "Please sign in with \(providerName) to continue"
    }
  }
}

/// Coordinator for handling reauthentication flows
@MainActor
@Observable
public final class ReauthenticationCoordinator {
  public var isReauthenticating = false
  public var reauthContext: ReauthContext?
  public var showingPhoneReauth = false

  private var continuation: CheckedContinuation<Void, Error>?

  public init() {}

  /// Request reauthentication from the user
  public func requestReauth(context: ReauthContext) async throws {
    return try await withCheckedThrowingContinuation { continuation in
      self.continuation = continuation
      self.reauthContext = context

      // Show different UI based on provider
      if context.providerId == PhoneAuthProviderID {
        self.showingPhoneReauth = true
      } else {
        self.isReauthenticating = true
      }
    }
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
    reauthContext = nil
  }
}
