import FirebaseAuth
import FirebaseAuthSwiftUI

public class TwitterProviderSwift: TwitterProviderProtocol {
  let scopes: [String]
  let shortName = "Twitter"
  let providerId = "twitter.com"

  public init(scopes: [String]? = nil) {
    self.scopes = scopes ?? ["user.readwrite"]
  }

  @MainActor public func signInWithTwitter() async throws -> AuthCredential {
    let provider = OAuthProvider(providerID: providerId)
    return try await withCheckedThrowingContinuation { continuation in
      provider.getCredentialWith(nil) { credential, error in
        if let error {
          continuation
            .resume(throwing: AuthServiceError.signInFailed(underlying: error))
        } else if let credential {
          continuation.resume(returning: credential)
        } else {
          continuation
            .resume(throwing: AuthServiceError
              .invalidCredentials("Twitter did not provide a valid AuthCredential"))
        }
      }
    }
  }
}
