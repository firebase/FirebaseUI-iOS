//
//  AccountService+Twitter.swift
//  FirebaseUI
//
//  Created by Russell Wheatley on 10/10/2025.
//

@preconcurrency import FirebaseAuth
import FirebaseAuthSwiftUI
import Observation

@MainActor
class TwitterDeleteUserOperation: AuthenticatedOperation,
  @preconcurrency ProviderOperationReauthentication {
  let twitterProvider: TwitterProviderSwift
  
  var authProvider: AuthProviderSwift { twitterProvider }
  
  init(twitterProvider: TwitterProviderSwift) {
    self.twitterProvider = twitterProvider
  }

  func callAsFunction(on user: User) async throws {
    try await callAsFunction(on: user) {
      try await user.delete()
    }
  }
}
