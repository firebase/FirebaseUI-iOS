
import FirebaseAuth
import SwiftUI

public struct AccountMergeConflictContext: LocalizedError {
  public let credential: AuthCredential
  public let underlyingError: Error
  public let message: String

  public var errorDescription: String? {
    return message
  }
}

public enum AuthServiceError: LocalizedError {
  case noCurrentUser
  case invalidEmailLink(String)
  case notConfiguredProvider(String)
  case clientIdNotFound(String)
  case notConfiguredActionCodeSettings(String)
  case reauthenticationRequired(String)
  case invalidCredentials(String)
  case signInFailed(underlying: Error)
  case accountMergeConflict(context: AccountMergeConflictContext)

  public var errorDescription: String? {
    switch self {
    case .noCurrentUser:
      return "No user is currently signed in."
    case let .invalidEmailLink(description):
      return description
    case let .notConfiguredProvider(description):
      return description
    case let .clientIdNotFound(description):
      return description
    case let .notConfiguredActionCodeSettings(description):
      return description
    case let .reauthenticationRequired(description):
      return description
    case let .invalidCredentials(description):
      return description
    case let .signInFailed(underlying: error):
      return "Failed to sign in: \(error.localizedDescription)"
    case let .accountMergeConflict(context):
      return context.errorDescription
    }
  }
}
