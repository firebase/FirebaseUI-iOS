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

import AppTrackingTransparency
import FacebookCore
import FacebookLogin
import FirebaseAuth
import FirebaseAuthSwiftUI
import SwiftUI

public class FacebookProviderSwift: CredentialAuthProviderSwift {
  let scopes: [String]
  let providerId = "facebook.com"
  private let loginManager = LoginManager()
  private var rawNonce: String?
  private var shaNonce: String?
  // Needed for reauthentication
  private var isLimitedLogin: Bool = true

  public init(scopes: [String] = ["email", "public_profile"]) {
    self.scopes = scopes
    isLimitedLogin = ATTrackingManager.trackingAuthorizationStatus != .authorized
  }

  @MainActor public func createAuthCredential() async throws -> AuthCredential {
    let loginType: LoginTracking = isLimitedLogin ? .limited : .enabled

    guard let configuration: LoginConfiguration = {
      if loginType == .limited {
        rawNonce = CommonUtils.randomNonce()
        shaNonce = CommonUtils.sha256Hash(of: rawNonce!)
        return LoginConfiguration(
          permissions: scopes,
          tracking: loginType,
          nonce: shaNonce!
        )
      } else {
        return LoginConfiguration(
          permissions: scopes,
          tracking: loginType
        )
      }
    }() else {
      throw AuthServiceError
        .providerAuthenticationFailed("Failed to create Facebook login configuration")
    }

    let result = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<
      Void,
      Error
    >) in
      loginManager.logIn(
        configuration: configuration
      ) { result in
        switch result {
        case .cancelled:
          continuation
            .resume(throwing: AuthServiceError
              .signInCancelled("User cancelled sign-in for Facebook"))
        case let .failed(error):
          continuation.resume(throwing: error)
        case .success:
          continuation.resume()
        }
      }
    }
    if isLimitedLogin {
      return try limitedLogin()
    } else {
      return try classicLogin()
    }
  }

  private func classicLogin() throws -> AuthCredential {
    if let token = AccessToken.current,
       !token.isExpired {
      let credential = FacebookAuthProvider
        .credential(withAccessToken: token.tokenString)

      return credential
    } else {
      throw AuthServiceError
        .providerAuthenticationFailed(
          "Access token has expired or not available. Please sign-in with Facebook before attempting to create a Facebook provider credential"
        )
    }
  }

  private func limitedLogin() throws -> AuthCredential {
    if let idToken = AuthenticationToken.current {
      guard let nonce = rawNonce else {
        throw AuthServiceError
          .providerAuthenticationFailed(
            "`rawNonce` has not been generated for Facebook limited login"
          )
      }
      let credential = OAuthProvider.credential(withProviderID: providerId,
                                                idToken: idToken.tokenString,
                                                rawNonce: nonce)
      return credential
    } else {
      throw AuthServiceError
        .providerAuthenticationFailed(
          "Authentication is not available. Please sign-in with Facebook before attempting to create a Facebook provider credential"
        )
    }
  }
}

public class FacebookProviderAuthUI: AuthProviderUI {
  public var provider: AuthProviderSwift
  public let id: String = "facebook.com"

  public init(provider: AuthProviderSwift) {
    self.provider = provider
  }

  @MainActor public func authButton() -> AnyView {
    AnyView(SignInWithFacebookButton(facebookProvider: provider as! FacebookProviderSwift))
  }
}
