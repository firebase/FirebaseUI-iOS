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

/// Execute an operation that may require reauthentication
/// - Parameters:
///   - authService: The auth service managing authentication
///   - coordinator: The coordinator managing reauthentication UI
///   - operation: The operation to execute
/// - Throws: Rethrows errors from the operation or reauthentication process
@MainActor
public func withReauthenticationIfNeeded(authService: AuthService,
                                         coordinator: ReauthenticationCoordinator,
                                         operation: @escaping () async throws
                                           -> Void) async throws {
  do {
    try await operation()
  } catch let error as NSError {
    // Check if reauthentication is needed
    if error.domain == AuthErrorDomain,
       error.code == AuthErrorCode.requiresRecentLogin.rawValue ||
       error.code == AuthErrorCode.userTokenExpired.rawValue {
      // Determine the provider context
      let providerId = try await authService.getCurrentSignInProvider()
      let context = ReauthContext(
        providerId: providerId,
        providerName: getProviderDisplayName(providerId),
        phoneNumber: authService.currentUser?.phoneNumber,
        email: authService.currentUser?.email
      )

      // Request reauthentication from user with context
      try await coordinator.requestReauth(context: context)

      // Retry the operation after successful reauth
      try await operation()
    } else {
      throw error
    }
  }
}

/// Get a user-friendly display name for a provider ID
/// - Parameter providerId: The provider ID from Firebase Auth
/// - Returns: A user-friendly name for the provider
public func getProviderDisplayName(_ providerId: String) -> String {
  switch providerId {
  case EmailAuthProviderID:
    return "Email"
  case PhoneAuthProviderID:
    return "Phone"
  case "google.com":
    return "Google"
  case "apple.com":
    return "Apple"
  case "facebook.com":
    return "Facebook"
  case "twitter.com":
    return "Twitter"
  default:
    return providerId
  }
}
