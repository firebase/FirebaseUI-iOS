//
//  AccountService+Twitter.swift
//  FirebaseUI
//
//  Created by Russell Wheatley on 10/10/2025.
//

@preconcurrency import FirebaseAuth
import FirebaseAuthSwiftUI
import Observation

protocol TwitterOperationReauthentication: ProviderOperationReauthentication {
  var twitterProvider: TwitterProviderSwift { get }
}

extension TwitterOperationReauthentication {
  var authProvider: AuthProviderSwift { twitterProvider }
}

@MainActor
class TwitterDeleteUserOperation: AuthenticatedOperation,
  @preconcurrency TwitterOperationReauthentication {
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
