import FacebookCore
import FacebookLogin
import FirebaseAuthSwiftUI

let kFacebookEmailScope = "email"
let kFacebookProfileScope = "public_profile"
let kDefaultFacebookScopes = [kFacebookEmailScope, kFacebookProfileScope]
// TODO: - need to think how to handle this
let kFacebookProviderId = "facebook.com"

public enum FacebookLoginType {
  case classic
  case limitedLogin
}

public class FacebookProviderSwift: FacebookProviderProtocol {
  let scopes: [String]
  let shortName = "Facebook"
  let providerId = "facebook.com"
  public init(scopes: [String]? = nil) {
    self.scopes = scopes ?? kDefaultFacebookScopes
  }

  public func authenticateWithClassic() {}
}
