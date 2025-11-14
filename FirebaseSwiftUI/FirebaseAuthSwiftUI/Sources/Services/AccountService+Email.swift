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

import Observation

/// Coordinator for prompting users to enter their password during reauthentication flows
@MainActor
@Observable
public final class PasswordPromptCoordinator {
  public var isPromptingPassword = false
  private var continuation: CheckedContinuation<String, Error>?

  public init() {}

  public func confirmPassword() async throws -> String {
    return try await withCheckedThrowingContinuation { continuation in
      self.continuation = continuation
      self.isPromptingPassword = true
    }
  }

  public func submit(password: String) {
    continuation?.resume(returning: password)
    cleanup()
  }

  public func cancel() {
    continuation?
      .resume(throwing: AuthServiceError
        .signInCancelled("Password entry cancelled for Email provider"))
    cleanup()
  }

  private func cleanup() {
    continuation = nil
    isPromptingPassword = false
  }
}
