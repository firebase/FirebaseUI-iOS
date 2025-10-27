//
//  AccountService+OAuth.swift
//  FirebaseUI
//
//  Created by Russell Wheatley on 21/10/2025.
//

@preconcurrency import FirebaseAuth
import FirebaseAuthSwiftUI
import Observation

@MainActor
class OAuthDeleteUserOperation: AuthenticatedOperation,
  @preconcurrency ProviderOperationReauthentication {
  let oauthProvider: OAuthProviderSwift
  
  var authProvider: AuthProviderSwift { oauthProvider }
  
  init(oauthProvider: OAuthProviderSwift) {
    self.oauthProvider = oauthProvider
  }

  func callAsFunction(on user: User) async throws {
    try await callAsFunction(on: user) {
      try await user.delete()
    }
  }
}
