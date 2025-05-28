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

let kFacebookEmailScope = "email"
let kFacebookProfileScope = "public_profile"
let kDefaultFacebookScopes = [kFacebookEmailScope, kFacebookProfileScope]

public enum FacebookProviderError: Error {
  case signInCancelled(String)
  case configurationInvalid(String)
  case limitedLoginNonce(String)
  case accessToken(String)
  case authenticationToken(String)
}

public class FacebookProviderAuthUI: FacebookProviderAuthUIProtocol {
  public let id: String = "facebook"
  let scopes: [String]
  let shortName = "Facebook"
  let providerId = "facebook.com"
  private let loginManager = LoginManager()
  private var rawNonce: String?
  private var shaNonce: String?
  // Needed for reauthentication
  var isLimitedLogin: Bool = true

  @MainActor private static var _shared: FacebookProviderAuthUI =
    .init(scopes: kDefaultFacebookScopes)

  @MainActor public static var shared: FacebookProviderAuthUI {
    return _shared
  }

  @MainActor public static func configureProvider(scopes: [String]? = nil) {
    _shared = FacebookProviderAuthUI(scopes: scopes)
  }

  private init(scopes: [String]? = nil) {
    self.scopes = scopes ?? kDefaultFacebookScopes
  }

  @MainActor public func authButton() -> AnyView {
    AnyView(SignInWithFacebookButton())
  }

  public func deleteUser(user: User) async throws {
    let operation = FacebookDeleteUserOperation(facebookProvider: self)
    try await operation(on: user)
  }

  @MainActor public func signInWithFacebook(isLimitedLogin: Bool) async throws -> AuthCredential {
    let loginType: LoginTracking = isLimitedLogin ? .limited : .enabled
    self.isLimitedLogin = isLimitedLogin

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
      throw FacebookProviderError
        .configurationInvalid("Failed to create Facebook login configuration")
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
            .resume(throwing: FacebookProviderError.signInCancelled("User cancelled sign-in"))
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
      throw FacebookProviderError
        .accessToken(
          "Access token has expired or not available. Please sign-in with Facebook before attempting to create a Facebook provider credential"
        )
    }
  }

  private func limitedLogin() throws -> AuthCredential {
    if let idToken = AuthenticationToken.current {
      guard let nonce = rawNonce else {
        throw FacebookProviderError
          .limitedLoginNonce("`rawNonce` has not been generated for Facebook limited login")
      }
      let credential = OAuthProvider.credential(withProviderID: providerId,
                                                idToken: idToken.tokenString,
                                                rawNonce: nonce)
      return credential
    } else {
      throw FacebookProviderError
        .authenticationToken(
          "Authentication is not available. Please sign-in with Facebook before attempting to create a Facebook provider credential"
        )
    }
  }
}
