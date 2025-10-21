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
import FirebaseAuthSwiftUI
import FirebaseCore
import SwiftUI

public class AppleProviderSwift: AuthProviderSwift, DeleteUserSwift {
  public let scopes: [String]
  let providerId = "apple.com"

  public init(scopes: [String] = []) {
    self.scopes = scopes
  }

  @MainActor public func createAuthCredential() async throws -> AuthCredential {
    // TODO: Implement Apple Sign In credential creation
    // This will need to use ASAuthorizationAppleIDProvider
    let provider = OAuthProvider(providerID: providerId)
    return try await withCheckedThrowingContinuation { continuation in
      provider.getCredentialWith(nil) { credential, error in
        if let error {
          continuation
            .resume(throwing: AuthServiceError.signInFailed(underlying: error))
        } else if let credential {
          continuation.resume(returning: credential)
        } else {
          continuation
            .resume(throwing: AuthServiceError
              .invalidCredentials("Apple did not provide a valid AuthCredential"))
        }
      }
    }
  }

  public func deleteUser(user: User) async throws {
    // TODO: Implement delete user functionality
    let operation = AppleDeleteUserOperation(appleProvider: self)
    try await operation(on: user)
  }
}

public class AppleProviderAuthUI: AuthProviderUI {
  public var provider: AuthProviderSwift

  public init(provider: AuthProviderSwift) {
    self.provider = provider
  }

  public let id: String = "apple.com"

  @MainActor public func authButton() -> AnyView {
    AnyView(SignInWithAppleButton(provider: provider))
  }
}

