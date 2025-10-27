//
//  AccountService+Apple.swift
//  FirebaseUI
//
//  Created by Russell Wheatley on 21/10/2025.
//

@preconcurrency import FirebaseAuth
import FirebaseAuthSwiftUI
import Observation

protocol AppleOperationReauthentication {
  var appleProvider: AppleProviderSwift { get }
}

extension AppleOperationReauthentication {
  @MainActor func reauthenticate() async throws {
    guard let user = Auth.auth().currentUser else {
      throw AuthServiceError.reauthenticationRequired("No user currently signed-in")
    }

    do {
      let credential = try await appleProvider.createAuthCredential()
      try await user.reauthenticate(with: credential)
    } catch {
      throw AuthServiceError.signInFailed(underlying: error)
    }
  }
}

@MainActor
class AppleDeleteUserOperation: AuthenticatedOperation,
  @preconcurrency AppleOperationReauthentication {
  let appleProvider: AppleProviderSwift
  init(appleProvider: AppleProviderSwift) {
    self.appleProvider = appleProvider
  }

  func callAsFunction(on user: User) async throws {
    try await callAsFunction(on: user) {
      try await user.delete()
    }
  }
}
