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

public class TwitterProviderAuthUI: AuthProviderSwift, AuthProviderUI {
  @MainActor public func createAuthCredential() async throws -> AuthCredential {
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
              .invalidCredentials("Twitter did not provide a valid AuthCredential"))
        }
      }
    }
  }

  public var provider: AuthProviderSwift { self }
  public let id: String = "twitter"
  let providerId = "twitter.com"

  @MainActor public func authButton() -> AnyView {
    AnyView(SignInWithTwitterButton())
  }

// TODO: need to implement delete user protocol
//  @MainActor public func deleteUser(user _: User) async throws {
//    <#code#>
//  }

  public init() {}
}
