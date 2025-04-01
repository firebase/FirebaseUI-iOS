@preconcurrency import FirebaseAuth
import FirebaseAuthSwiftUI
import GoogleSignIn

let kGoogleUserInfoEmailScope = "https://www.googleapis.com/auth/userinfo.email"
let kGoogleUserInfoProfileScope = "https://www.googleapis.com/auth/userinfo.profile"
let kDefaultScopes = [kGoogleUserInfoEmailScope, kGoogleUserInfoProfileScope]

public class GoogleProviderSwift: @preconcurrency GoogleProviderProtocol {
  let scopes: [String]
  let shortName = "Google"
  let providerId = "google.com"
  public init(scopes: [String]? = nil) {
    self.scopes = scopes ?? kDefaultScopes
  }

  public func handleUrl(_ url: URL) -> Bool {
    return GIDSignIn.sharedInstance.handle(url)
  }

  @MainActor public func signInWithGoogle(clientID: String) async throws -> AuthCredential {
    guard let presentingViewController = await (UIApplication.shared.connectedScenes
      .first as? UIWindowScene)?.windows.first?.rootViewController else {
      throw NSError(
        domain: "GoogleProviderSwiftErrorDomain",
        code: 1,
        userInfo: [
          NSLocalizedDescriptionKey: "Root View controller is not available to present Google sign-in View.",
        ]
      )
    }

    let config = GIDConfiguration(clientID: clientID)
    GIDSignIn.sharedInstance.configuration = config

    return try await withCheckedThrowingContinuation { continuation in
      GIDSignIn.sharedInstance.signIn(
        withPresenting: presentingViewController
      ) { result, error in
        if let error = error {
          continuation.resume(throwing: error)
          return
        }

        guard let user = result?.user,
              let idToken = user.idToken?.tokenString else {
          continuation.resume(throwing: NSError(
            domain: "GoogleProviderSwiftErrorDomain",
            code: 2,
            userInfo: [
              NSLocalizedDescriptionKey: "Failed to retrieve user or idToken.",
            ]
          ))
          return
        }

        let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                       accessToken: user.accessToken.tokenString)
        continuation.resume(returning: credential)
      }
    }
  }
}
