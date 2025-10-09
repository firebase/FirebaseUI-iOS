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

public struct AccountMergeConflictContext: LocalizedError {
  public let credential: AuthCredential
  public let underlyingError: Error
  public let message: String
  // TODO: - should make this User type once fixed upstream in firebase-ios-sdk. See: https://github.com/firebase/FirebaseUI-iOS/pull/1247#discussion_r2085455355
  public let uid: String?

  public var errorDescription: String? {
    return message
  }
}

public enum AuthServiceError: LocalizedError {
  case noCurrentUser
  case invalidEmailLink(String)
  case clientIdNotFound(String)
  case notConfiguredActionCodeSettings(String)
  case reauthenticationRequired(String)
  case invalidCredentials(String)
  case signInFailed(underlying: Error)
  case accountMergeConflict(context: AccountMergeConflictContext)
  case invalidPhoneAuthenticationArguments(String)
  case providerNotFound(String)
  case multiFactorAuth(String)
  

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
    case let .reauthenticationRequired(description):
      return description
    case let .invalidCredentials(description):
      return description
    case let .signInFailed(underlying: error):
      return "Failed to sign in: \(error.localizedDescription)"
    case let .accountMergeConflict(context):
      return context.errorDescription
    case let .providerNotFound(description):
      return description
    case let .invalidPhoneAuthenticationArguments(description):
        return description
    case let .multiFactorAuth(description):
      return description
    }
  }
}
