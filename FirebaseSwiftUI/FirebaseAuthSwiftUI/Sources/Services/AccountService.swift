import AuthenticationServices
import FirebaseAuth

extension NSError {
  var requiresReauthentication: Bool {
    domain == AuthErrorDomain && code == AuthErrorCode.requiresRecentLogin.rawValue
  }

  var credentialAlreadyInUse: Bool {
    domain == AuthErrorDomain && code == AuthErrorCode.credentialAlreadyInUse.rawValue
  }
}

enum AuthenticationToken {
  case apple(ASAuthorizationAppleIDCredential, String)
  case firebase(String)
}

protocol AuthenticatedOperation {
  func callAsFunction(on user: User) async throws
  func reauthenticate() async throws -> AuthenticationToken
}

extension AuthenticatedOperation {
  func callAsFunction(on _: User,
                      _ performOperation: () async throws -> Void) async throws {
    do {
      try await performOperation()
    } catch let error as NSError where error.requiresReauthentication {
      let token = try await reauthenticate()
      try await performOperation()
    } catch AuthServiceError.reauthenticationRequired {
      let token = try await reauthenticate()
      try await performOperation()
    }
  }
}
