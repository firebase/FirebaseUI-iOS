@preconcurrency import FirebaseAuth
import FirebaseAuthSwiftUI
import GoogleSignIn

let kGoogleUserInfoEmailScope = "https://www.googleapis.com/auth/userinfo.email"
let kGoogleUserInfoProfileScope = "https://www.googleapis.com/auth/userinfo.profile"
let kDefaultScopes = [kGoogleUserInfoEmailScope, kGoogleUserInfoProfileScope]

public class GoogleProviderSwift: GoogleProviderProtocol {
  let scopes: [String]
  let shortName = "Google"
  let providerId = "google.com"
  public init(scopes: [String]? = nil) {
    self.scopes = scopes ?? kDefaultScopes
  }

  public func handleUrl(_ url: URL) -> Bool {
    return GIDSignIn.sharedInstance.handle(url)
  }

  @MainActor public func signInWithGoogle(clientID: String) {
    guard let presentingViewController = (UIApplication.shared.connectedScenes
      .first as? UIWindowScene)?.windows.first?.rootViewController else {
//      "Error: Unable to get the presenting view controller."
      return
    }

    let config = GIDConfiguration(clientID: clientID)
    GIDSignIn.sharedInstance.configuration = config

    GIDSignIn.sharedInstance.signIn(
      withPresenting: presentingViewController
    ) { result, error in
      guard error == nil else {
        // Handle error
        return
      }

      guard let user = result?.user,
            let idToken = user.idToken?.tokenString else {
        // Handle error
        return
      }

      let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                     accessToken: user.accessToken
                                                       .tokenString)

    }
  }
}
