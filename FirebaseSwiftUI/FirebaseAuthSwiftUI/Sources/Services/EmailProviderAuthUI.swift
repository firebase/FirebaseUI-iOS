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

/// Email/Password authentication provider
/// This provider is special and doesn't render in the button list
@MainActor
public class EmailProviderSwift: AuthProviderSwift {
  public let passwordPrompt: PasswordPromptCoordinator
  public let providerId = EmailAuthProviderID

  public init(passwordPrompt: PasswordPromptCoordinator = .init()) {
    self.passwordPrompt = passwordPrompt
  }

  /// Create credential for reauthentication
  func createReauthCredential(email: String) async throws -> AuthCredential {
    let password = try await passwordPrompt.confirmPassword()
    return EmailAuthProvider.credential(withEmail: email, password: password)
  }
}
