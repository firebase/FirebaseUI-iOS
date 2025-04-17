import FirebaseAuth
import FirebaseAuthSwiftUI

public class TwitterProviderSwift: TwitterProviderProtocol {
  let scopes: [String]
  let shortName = "Twitter"
  let providerId = "twitter.com"

  public init(scopes: [String]? = nil) {
    self.scopes = scopes ?? ["user.readwrite"]
  }

  @MainActor public func signInWithTwitter() async throws -> AuthCredential {}
}
