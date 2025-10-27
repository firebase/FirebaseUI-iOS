//
//  AccountService+OAuth.swift
//  FirebaseUI
//
//  Created by Russell Wheatley on 21/10/2025.
//

@preconcurrency import FirebaseAuth
import FirebaseAuthSwiftUI
import Observation

protocol OAuthOperationReauthentication: ProviderOperationReauthentication {
  var oauthProvider: OAuthProviderSwift { get }
}

extension OAuthOperationReauthentication {
  var authProvider: AuthProviderSwift { oauthProvider }
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
