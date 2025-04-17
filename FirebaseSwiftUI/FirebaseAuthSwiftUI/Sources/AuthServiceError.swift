
import SwiftUI

public enum AuthServiceError: LocalizedError {
  case invalidEmailLink
  case notConfiguredProvider(String)
  case clientIdNotFound(String)
  case notConfiguredActionCodeSettings
  case reauthenticationRequired(String)
  case invalidCredentials(String)
  case signInFailed(underlying: Error)

  public var errorDescription: String? {
    switch self {
    case .invalidEmailLink:
      return "Invalid sign in link. Most likely, the link you used has expired. Try signing in again."
    case let .notConfiguredProvider(description):
      return description
    case let .clientIdNotFound(description):
      return description
    case .notConfiguredActionCodeSettings:
      return "ActionCodeSettings has not been configured for `AuthConfiguration.emailLinkSignInActionCodeSettings`"
    case let .reauthenticationRequired(description):
      return description
    case let .invalidCredentials(description):
      return description
    case let .signInFailed(underlying: error):
      return "Failed to sign in: \(error.localizedDescription)"
    }
  }
}
