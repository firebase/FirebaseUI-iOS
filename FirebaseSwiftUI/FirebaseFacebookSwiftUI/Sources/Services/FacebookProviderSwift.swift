import AppTrackingTransparency
import FacebookCore
import FacebookLogin
import FirebaseAuth
import FirebaseAuthSwiftUI
import SwiftUI

let kFacebookEmailScope = "email"
let kFacebookProfileScope = "public_profile"
let kDefaultFacebookScopes = [kFacebookEmailScope, kFacebookProfileScope]

public enum FacebookLoginType {
  case classic
  case limitedLogin
}

public enum FacebookProviderError: Error {
  case signInCancelled(String)
  case configurationInvalid(String)
  case accessToken(String)
  case authenticationToken(String)
}

public class FacebookProviderSwift: FacebookProviderProtocol {
  let scopes: [String]
  let shortName = "Facebook"
  let providerId = "facebook.com"
  private let loginManager = LoginManager()
  private var rawNonce: String
  private var shaNonce: String

  public init(scopes: [String]? = nil) {
    self.scopes = scopes ?? kDefaultFacebookScopes
    rawNonce = CommonUtils.randomNonce()
    shaNonce = CommonUtils.sha256Hash(of: rawNonce)
  }

  @MainActor public var authButton: any View {
    return FacebookButtonView()
  }

  @MainActor public func signInWithFacebook(isLimitedLogin: Bool) async throws -> AuthCredential {
    let trackingStatus = ATTrackingManager.trackingAuthorizationStatus
    let tracking: LoginTracking = trackingStatus != .authorized ? .limited :
      (isLimitedLogin ? .limited : .enabled)

    guard let configuration: LoginConfiguration = {
      if tracking == .limited {
        return LoginConfiguration(
          permissions: scopes,
          tracking: tracking,
          nonce: shaNonce
        )
      } else {
        return LoginConfiguration(
          permissions: scopes,
          tracking: tracking
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
        //          showCanceledAlert = true
        case let .failed(error):
          continuation.resume(throwing: error)
        //          errorMessage = authService.string.localizedErrorMessage(for: error)
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
      let credential = OAuthProvider.credential(withProviderID: providerId,
                                                idToken: idToken.tokenString,
                                                rawNonce: rawNonce)
      return credential
    } else {
      throw FacebookProviderError
        .authenticationToken(
          "Authentication is not available. Please sign-in with Facebook before attempting to create a Facebook provider credential"
        )
    }
  }
}
