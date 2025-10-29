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

@MainActor
public protocol AuthenticatedOperation {
  func callAsFunction(on user: User) async throws
  func reauthenticate() async throws
}

public extension AuthenticatedOperation {
  func callAsFunction(on _: User,
                      _ performOperation: @MainActor () async throws -> Void) async throws {
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

@MainActor
public protocol ProviderOperationReauthentication {
  var authProvider: AuthProviderSwift { get }
}

public extension ProviderOperationReauthentication {
  func reauthenticate() async throws {
    guard let user = Auth.auth().currentUser else {
      throw AuthServiceError.reauthenticationRequired("No user currently signed-in")
    }

    do {
      let credential = try await authProvider.createAuthCredential()
      _ = try await user.reauthenticate(with: credential)
    } catch {
      throw AuthServiceError.signInFailed(underlying: error)
    }
  }
}

@MainActor
public class ProviderDeleteUserOperation<Provider: AuthProviderSwift>: AuthenticatedOperation,
  @preconcurrency ProviderOperationReauthentication {
  let provider: Provider

  public var authProvider: AuthProviderSwift { provider }

  public init(provider: Provider) {
    self.provider = provider
  }

  public func callAsFunction(on user: User) async throws {
    try await callAsFunction(on: user) {
      try await user.delete()
    }
  }
}
