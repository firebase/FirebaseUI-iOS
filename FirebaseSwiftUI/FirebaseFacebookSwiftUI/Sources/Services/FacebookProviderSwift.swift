import FacebookCore
import FacebookLogin
import FirebaseAuthSwiftUI

public enum FacebookLoginType {
  case classic
  case limitedLogin
}

public class FacebookProviderSwift: FacebookProviderProtocol {
  let shortName = "Facebook"
  let providerId = "facebook.com"
  public init() {}

  public func authenticateWithClassic() {}
}
