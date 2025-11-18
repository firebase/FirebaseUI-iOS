// Copyright 2025 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import FirebaseAuth
import SwiftUI

/// Context information for reauthentication
public struct ReauthContext: Equatable {
  public let providerId: String
  public let providerName: String
  public let phoneNumber: String?
  public let email: String?

  public init(providerId: String, providerName: String, phoneNumber: String?, email: String?) {
    self.providerId = providerId
    self.providerName = providerName
    self.phoneNumber = phoneNumber
    self.email = email
  }

  public var displayMessage: String {
    switch providerId {
    case EmailAuthProviderID:
      return "Please enter your password to continue"
    case PhoneAuthProviderID:
      return "Please verify your phone number to continue"
    default:
      return "Please sign in with \(providerName) to continue"
    }
  }
}

/// Describes the specific type of account conflict that occurred
public enum AccountConflictType: Equatable {
  /// Account exists with a different provider (e.g., user signed up with Google, trying to use
  /// email)
  /// Solution: Sign in with existing provider, then link the new credential
  case accountExistsWithDifferentCredential

  /// The credential is already linked to another account
  /// Solution: User must sign in with that account or unlink the credential
  case credentialAlreadyInUse

  /// Email is already registered with another method
  /// Solution: Sign in with existing method, then link if desired
  case emailAlreadyInUse

  /// Trying to link anonymous account to an existing account
  /// Solution: Sign out of anonymous, then sign in with the credential
  case anonymousUpgradeConflict
}

public struct AccountConflictContext: LocalizedError, Identifiable, Equatable {
  public let id = UUID()
  public let conflictType: AccountConflictType
  public let credential: AuthCredential
  public let underlyingError: Error
  public let message: String
  public let email: String?

  /// Human-readable description of the conflict type
  public var conflictDescription: String {
    switch conflictType {
    case .accountExistsWithDifferentCredential:
      return "This account is already registered with a different sign-in method."
    case .credentialAlreadyInUse:
      return "This credential is already linked to another account."
    case .emailAlreadyInUse:
      return "This email address is already in use."
    case .anonymousUpgradeConflict:
      return "Cannot link anonymous account to an existing account."
    }
  }

  public var errorDescription: String? {
    return message
  }

  public static func == (lhs: AccountConflictContext, rhs: AccountConflictContext) -> Bool {
    // Compare by id since each AccountConflictContext instance is unique
    lhs.id == rhs.id
  }
}

public enum AuthServiceError: LocalizedError {
  case noCurrentUser
  case invalidEmailLink(String)
  case clientIdNotFound(String)
  case notConfiguredActionCodeSettings(String)
  
  /// Simple reauthentication required (Google, Apple, Facebook, Twitter, etc.)
  /// Can be passed directly to `reauthenticate(context:)` method
  case simpleReauthenticationRequired(context: ReauthContext)
  
  /// Email reauthentication required - user must handle password prompt externally
  case emailReauthenticationRequired(context: ReauthContext)
  
  /// Phone reauthentication required - user must handle SMS verification flow externally
  case phoneReauthenticationRequired(context: ReauthContext)
  
  case invalidCredentials(String)
  case signInFailed(underlying: Error)
  case accountConflict(AccountConflictContext)
  case providerNotFound(String)
  case multiFactorAuth(String)
  case rootViewControllerNotFound(String)
  case providerAuthenticationFailed(String)
  case signInCancelled(String)

  public var errorDescription: String? {
    switch self {
    case .noCurrentUser:
      return "No user is currently signed in."
    case let .invalidEmailLink(description):
      return description
    case let .clientIdNotFound(description):
      return description
    case let .notConfiguredActionCodeSettings(description):
      return description
    case let .simpleReauthenticationRequired(context):
      return "Please sign in again with \(context.providerName) to continue"
    case let .emailReauthenticationRequired(context):
      return "Please enter your password to continue"
    case let .phoneReauthenticationRequired(context):
      return "Please verify your phone number to continue"
    case let .invalidCredentials(description):
      return description
    // Use when failed to sign-in with Firebase
    case let .signInFailed(underlying: error):
      return "Failed to sign in: \(error.localizedDescription)"
    // Use when failed to sign-in with provider (e.g. Google, Facebook, etc.)
    case let .providerAuthenticationFailed(description):
      return description
    case let .signInCancelled(description):
      return description
    case let .accountConflict(context):
      return context.errorDescription
    case let .providerNotFound(description):
      return description
    case let .multiFactorAuth(description):
      return description
    case let .rootViewControllerNotFound(description):
      return description
    }
  }
}
