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

let kGoogleUserInfoEmailScope = "https://www.googleapis.com/auth/userinfo.email"
let kGoogleUserInfoProfileScope = "https://www.googleapis.com/auth/userinfo.profile"
let kDefaultScopes = [kGoogleUserInfoEmailScope, kGoogleUserInfoProfileScope]

public enum GoogleProviderError: Error {
  case rootViewControllerNotFound(String)
  case authenticationToken(String)
  case user(String)
}

public class GoogleProviderAuthUI: @preconcurrency GoogleProviderAuthUIProtocol {
  public let id: String = "google"
  let scopes: [String]
  let shortName = "Google"
  let providerId = "google.com"
  let clientID: String
  public init(scopes: [String]? = nil, clientID: String = FirebaseApp.app()!.options.clientID!) {
    self.scopes = scopes ?? kDefaultScopes
    self.clientID = clientID
  }

  @MainActor public func authButton() -> AnyView {
    let customViewModel = GoogleSignInButtonViewModel(
      scheme: .light,
      style: .wide,
      state: .normal
    )
    return AnyView(GoogleSignInButton(viewModel: customViewModel) {
      Task {
        try await self.signInWithGoogle(clientID: self.clientID)
      }
    })
  }

  @MainActor public func signInWithGoogle(clientID: String) async throws -> AuthCredential {
    guard let presentingViewController = await (UIApplication.shared.connectedScenes
      .first as? UIWindowScene)?.windows.first?.rootViewController else {
      throw GoogleProviderError
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
            .resume(throwing: GoogleProviderError.user("Failed to retrieve user or idToken."))
          return
        }

        let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                       accessToken: user.accessToken.tokenString)
        continuation.resume(returning: credential)
      }
    }
  }
}
