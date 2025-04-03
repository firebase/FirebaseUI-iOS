// @preconcurrency import FirebaseAuth
import FirebaseAuthSwiftUI

public enum FacebookLoginType {
  case classic
  case limitedLogin
}

public class FacebookProviderSwift: FacebookProviderProtocol {
  let shortName = "Facebook"
  let providerId = "facebook.com"
  var loginType: FacebookLoginType
  public init(loginType: FacebookLoginType = FacebookLoginType.classic) {
    self.loginType = loginType
  }

  public func signInWithFacebook() {}
}
