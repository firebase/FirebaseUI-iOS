//
//  AccountService+Twitter.swift
//  FirebaseUI
//
//  Created by Russell Wheatley on 10/10/2025.
//

@preconcurrency import FirebaseAuth
import FirebaseAuthSwiftUI
import Observation

protocol GoogleOperationReauthentication {
  var twitterProvider: TwitterProviderSwift { get }
}

extension GoogleOperationReauthentication {
  @MainActor func reauthenticate() async throws -> AuthenticationToken {
    guard let user = Auth.auth().currentUser else {
      throw AuthServiceError.reauthenticationRequired("No user currently signed-in")
    }

    do {
      let credential = try await twitterProvider.createAuthCredential()
      try await user.reauthenticate(with: credential)

      return .firebase("")
    } catch {
      throw AuthServiceError.signInFailed(underlying: error)
    }
  }
}

@MainActor
class TwitterDeleteUserOperation: AuthenticatedOperation,
  @preconcurrency GoogleOperationReauthentication {
  let twitterProvider: TwitterProviderSwift
  init(twitterProvider: TwitterProviderSwift) {
    self.twitterProvider = twitterProvider
  }

  func callAsFunction(on user: User) async throws {
    try await callAsFunction(on: user) {
      try await user.delete()
    }
  }
}
