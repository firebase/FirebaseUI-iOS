//
//  AccountService+Apple.swift
//  FirebaseUI
//
//  Created by Russell Wheatley on 21/10/2025.
//

@preconcurrency import FirebaseAuth
import FirebaseAuthSwiftUI
import Observation

protocol AppleOperationReauthentication: ProviderOperationReauthentication {
  var appleProvider: AppleProviderSwift { get }
}

extension AppleOperationReauthentication {
  var authProvider: AuthProviderSwift { appleProvider }
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
