import SwiftUI

public struct FUIEmailProvider: FUIAuthProvider {
  public var providerId: String {
    return "email"
  }

  public var shortName: String {
    return "Email"
  }

  public var accessToken: String? {
    // Email Auth token is matched by FirebaseUI User Access Token
    return nil
  }

  public var idToken: String? {
    // Email Auth Token Secret is matched by FirebaseUI User Id Token
    return nil
  }

  public var credential: AuthCredential? = nil

  public var error: Error? = nil

  public var userInfo: [String: Any]? = nil

  public var isAuthenticated: Bool = false

  public init() {}

  public func signOut() {}

  public func email() -> String {
    // Return the email associated with the provider, if available
    return userInfo?["email"] as? String ?? ""
  }
}
