import FirebaseAuthSwiftUI

let kGoogleUserInfoEmailScope = "https://www.googleapis.com/auth/userinfo.email";
let kGoogleUserInfoProfileScope = "https://www.googleapis.com/auth/userinfo.profile"

public class GoogleProviderSwift: GoogleProviderProtocol {
  let scopes: [String]
  public init(scopes: [String] = [kGoogleUserInfoEmailScope, kGoogleUserInfoProfileScope]) {}
}
