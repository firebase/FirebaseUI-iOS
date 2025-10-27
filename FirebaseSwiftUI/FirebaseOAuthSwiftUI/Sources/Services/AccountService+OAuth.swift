//
//  AccountService+OAuth.swift
//  FirebaseUI
//
//  Created by Russell Wheatley on 21/10/2025.
//

@preconcurrency import FirebaseAuth
import FirebaseAuthSwiftUI
import Observation

protocol OAuthOperationReauthentication {
  var oauthProvider: OAuthProviderSwift { get }
}

extension OAuthOperationReauthentication {
  @MainActor func reauthenticate() async throws {
    guard let user = Auth.auth().currentUser else {
      throw AuthServiceError.reauthenticationRequired("No user currently signed-in")
    }

    do {
      let credential = try await oauthProvider.createAuthCredential()
      try await user.reauthenticate(with: credential)
    } catch {
      throw AuthServiceError.signInFailed(underlying: error)
    }
  }
}

@MainActor
class OAuthDeleteUserOperation: AuthenticatedOperation,
  @preconcurrency OAuthOperationReauthentication {
  let oauthProvider: OAuthProviderSwift
  init(oauthProvider: OAuthProviderSwift) {
    self.oauthProvider = oauthProvider
  }

  func callAsFunction(on user: User) async throws {
    try await callAsFunction(on: user) {
      try await user.delete()
    }
  }
}
