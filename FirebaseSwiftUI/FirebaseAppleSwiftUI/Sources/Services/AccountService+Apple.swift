//
//  AccountService+Apple.swift
//  FirebaseUI
//
//  Created by Russell Wheatley on 21/10/2025.
//

@preconcurrency import FirebaseAuth
import FirebaseAuthSwiftUI
import Observation

@MainActor
class AppleDeleteUserOperation: AuthenticatedOperation,
  @preconcurrency ProviderOperationReauthentication {
  let appleProvider: AppleProviderSwift
  
  var authProvider: AuthProviderSwift { appleProvider }
  
  init(appleProvider: AppleProviderSwift) {
    self.appleProvider = appleProvider
  }

  func callAsFunction(on user: User) async throws {
    try await callAsFunction(on: user) {
      try await user.delete()
    }
  }
}
