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

  @MainActor private static var _shared: FacebookProviderAuthUI?

  @MainActor public static var shared: FacebookProviderAuthUI {
    guard let instance = _shared else {
      fatalError("`FacebookProviderAuthUI` has not been configured")
    }
    return instance
  }

  @MainActor public static func configureSharedInstance(scopes: [String]? = nil) {
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
      let credential = OAuthProvider.credential(withProviderID: providerId,
                                                idToken: idToken.tokenString,
                                                rawNonce: rawNonce!)
      return credential
    } else {
      throw FacebookProviderError
        .authenticationToken(
          "Authentication is not available. Please sign-in with Facebook before attempting to create a Facebook provider credential"
        )
    }
  }
}
