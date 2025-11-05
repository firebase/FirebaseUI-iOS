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

@preconcurrency import FirebaseAuth
import FirebaseAuthSwiftUI
import FirebaseCore
import GoogleSignIn
import GoogleSignInSwift
import SwiftUI

public class GoogleProviderSwift: CredentialAuthProviderSwift {
  let scopes: [String]
  let clientID: String
  let providerId = "google.com"

  public init(scopes: [String] = [
    "https://www.googleapis.com/auth/userinfo.email",
    "https://www.googleapis.com/auth/userinfo.profile",
  ],
  clientID: String) {
    self.clientID = clientID
    self.scopes = scopes
  }

  @MainActor public func createAuthCredential() async throws -> AuthCredential {
    guard let presentingViewController = await (UIApplication.shared.connectedScenes
      .first as? UIWindowScene)?.windows.first?.rootViewController else {
      throw AuthServiceError
        .rootViewControllerNotFound(
          "Root View controller is not available to present Google sign-in View."
        )
    }

    let config = GIDConfiguration(clientID: clientID)
    GIDSignIn.sharedInstance.configuration = config

    return try await withCheckedThrowingContinuation { continuation in
      GIDSignIn.sharedInstance.signIn(
        withPresenting: presentingViewController
      ) { result, error in
        if let error = error {
          continuation.resume(throwing: error)
          return
        }

        guard let user = result?.user,
              let idToken = user.idToken?.tokenString else {
          continuation
            .resume(throwing: AuthServiceError
              .providerAuthenticationFailed("Failed to retrieve user or idToken."))
          return
        }

        let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                       accessToken: user.accessToken.tokenString)
        continuation.resume(returning: credential)
      }
    }
  }
}

public class GoogleProviderAuthUI: AuthProviderUI {
  public var provider: AuthProviderSwift
  public let id: String = "google.com"

  public init(provider: AuthProviderSwift) {
    self.provider = provider
  }

  @MainActor public func authButton() -> AnyView {
    AnyView(SignInWithGoogleButton(googleProvider: provider as! CredentialAuthProviderSwift))
  }
}
