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
  func performOperation(on user: User, with token: AuthenticationToken?) async throws
}

extension AuthenticatedOperation {
  func callAsFunction(on user: User) async throws {
    do {
      try await performOperation(on: user, with: nil)
    } catch let error as NSError where error.requiresReauthentication {
      let token = try await reauthenticate()
      try await performOperation(on: user, with: token)
    } catch AuthServiceError.reauthenticationRequired {
      let token = try await reauthenticate()
      try await performOperation(on: user, with: token)
    }
  }
}

protocol DeleteUserOperation: AuthenticatedOperation {}

extension DeleteUserOperation {
  func performOperation(on user: User, with _: AuthenticationToken? = nil) async throws {
    try await user.delete()
  }
}
