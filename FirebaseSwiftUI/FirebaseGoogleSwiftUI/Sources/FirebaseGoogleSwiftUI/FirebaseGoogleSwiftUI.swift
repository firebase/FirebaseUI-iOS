import FirebaseAuthSwiftUI

let kGoogleUserInfoEmailScope = "https://www.googleapis.com/auth/userinfo.email"
let kGoogleUserInfoProfileScope = "https://www.googleapis.com/auth/userinfo.profile"
let kDefaultScopes = [kGoogleUserInfoEmailScope, kGoogleUserInfoProfileScope]

public class GoogleProviderSwift: GoogleProviderProtocol {
  let scopes: [String]
  let shortName = "Google"
  let providerId = "google.com"
  public init(scopes _: [String] = kDefaultScopes) {
    self.scopes = scopes
  }
  
  
}
