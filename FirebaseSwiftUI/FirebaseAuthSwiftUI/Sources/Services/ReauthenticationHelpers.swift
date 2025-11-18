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
/// Automatically handles reauth errors by presenting UI and retrying
/// - Parameters:
///   - authService: The auth service managing authentication
///   - coordinator: The coordinator managing reauthentication UI
///   - operation: The operation to execute
/// - Throws: Rethrows errors from the operation or reauthentication process
@MainActor
public func withReauthenticationIfNeeded(authService _: AuthService,
                                         coordinator: ReauthenticationCoordinator,
                                         operation: @escaping () async throws
                                           -> Void) async throws {
  do {
    try await operation()
  } catch let error as AuthServiceError {
    // Check if this is a reauthentication error
    let context: ReauthContext?

    switch error {
    case let .emailReauthenticationRequired(ctx):
      context = ctx
    case let .phoneReauthenticationRequired(ctx):
      context = ctx
    case let .simpleReauthenticationRequired(ctx):
      context = ctx
    default:
      // Not a reauth error, rethrow
      throw error
    }

    guard let reauthContext = context else {
      throw error
    }

    // Request reauthentication through coordinator (shows UI)
    try await coordinator.requestReauth(context: reauthContext)

    // After successful reauth, retry the operation
    try await operation()
  }
}
