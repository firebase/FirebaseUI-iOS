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

import AuthenticationServices
import CryptoKit
import FirebaseAuth
import FirebaseAuthSwiftUI
import FirebaseCore
import SwiftUI

// MARK: - Data Extensions

extension Data {
  var utf8String: String? {
    return String(data: self, encoding: .utf8)
  }
}

extension ASAuthorizationAppleIDCredential {
  var authorizationCodeString: String? {
    return authorizationCode?.utf8String
  }

  var idTokenString: String? {
    return identityToken?.utf8String
  }
}

// MARK: - Authenticate With Apple Dialog

private func authenticateWithApple(scopes: [ASAuthorization.Scope]) async throws -> (
  ASAuthorizationAppleIDCredential,
  String
) {
  return try await AuthenticateWithAppleDialog(scopes: scopes).authenticate()
}

private class AuthenticateWithAppleDialog: NSObject {
  private var continuation: CheckedContinuation<(ASAuthorizationAppleIDCredential, String), Error>?
  private var currentNonce: String?
  private let scopes: [ASAuthorization.Scope]

  init(scopes: [ASAuthorization.Scope]) {
    self.scopes = scopes
    super.init()
  }

  func authenticate() async throws -> (ASAuthorizationAppleIDCredential, String) {
    return try await withCheckedThrowingContinuation { continuation in
      self.continuation = continuation

      let appleIDProvider = ASAuthorizationAppleIDProvider()
      let request = appleIDProvider.createRequest()
      request.requestedScopes = scopes

      do {
        let nonce = try CryptoUtils.randomNonceString()
        currentNonce = nonce
        request.nonce = CryptoUtils.sha256(nonce)
      } catch {
        continuation.resume(throwing: AuthServiceError.signInFailed(underlying: error))
        return
      }

      let authorizationController = ASAuthorizationController(authorizationRequests: [request])
      authorizationController.delegate = self
      authorizationController.performRequests()
    }
  }
}

extension AuthenticateWithAppleDialog: ASAuthorizationControllerDelegate {
  func authorizationController(controller _: ASAuthorizationController,
                               didCompleteWithAuthorization authorization: ASAuthorization) {
    if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
      if let nonce = currentNonce {
        continuation?.resume(returning: (appleIDCredential, nonce))
      } else {
        continuation?.resume(
          throwing: AuthServiceError.signInFailed(
            underlying: NSError(
              domain: "AppleSignIn",
              code: -1,
              userInfo: [NSLocalizedDescriptionKey: "Missing nonce"]
            )
          )
        )
      }
    } else {
      continuation?.resume(
        throwing: AuthServiceError.invalidCredentials("Missing Apple ID credential")
      )
    }
    continuation = nil
  }

  func authorizationController(controller _: ASAuthorizationController,
                               didCompleteWithError error: Error) {
    continuation?.resume(throwing: AuthServiceError.signInFailed(underlying: error))
    continuation = nil
  }
}

// MARK: - Apple Provider Swift

public class AppleProviderSwift: CredentialAuthProviderSwift {
  public let scopes: [ASAuthorization.Scope]
  let providerId = "apple.com"

  public init(scopes: [ASAuthorization.Scope] = [.fullName, .email]) {
    self.scopes = scopes
  }

  @MainActor public func createAuthCredential() async throws -> AuthCredential {
    let (appleIDCredential, nonce) = try await authenticateWithApple(scopes: scopes)

    guard let idTokenString = appleIDCredential.idTokenString else {
      throw AuthServiceError.invalidCredentials("Unable to fetch identity token from Apple")
    }

    let credential = OAuthProvider.appleCredential(
      withIDToken: idTokenString,
      rawNonce: nonce,
      fullName: appleIDCredential.fullName
    )

    return credential
  }
}

public class AppleProviderAuthUI: AuthProviderUI {
  private let typedProvider: AppleProviderSwift
  public var provider: AuthProviderSwift { typedProvider }
  public let id: String = "apple.com"

  public init(provider: AppleProviderSwift) {
    typedProvider = provider
  }

  @MainActor public func authButton() -> AnyView {
    AnyView(SignInWithAppleButton(provider: typedProvider))
  }
}
