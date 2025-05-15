//
//  AccountService+Facebook.swift
//  FirebaseUI
//
//  Created by Russell Wheatley on 14/05/2025.
//

@preconcurrency import FirebaseAuth
import FirebaseAuthSwiftUI
import Observation

protocol FacebookOperationReauthentication {}

extension FacebookOperationReauthentication {
  func reauthenticate() async throws -> AuthenticationToken {
    guard let user = Auth.auth().currentUser else {
      throw AuthServiceError.reauthenticationRequired("No user currently signed-in")
    }

    do {
      let credential = try await FacebookProviderAuthUI.shared
        .signInWithFacebook(isLimitedLogin: FacebookProviderAuthUI.shared.isLimitedLogin)
      try await user.reauthenticate(with: credential)

      return .firebase("")
    } catch {
      throw AuthServiceError.signInFailed(underlying: error)
    }
  }
}

class FacebookDeleteUserOperation: AuthenticatedOperation, FacebookOperationReauthentication {
  init() {}

  func callAsFunction(on user: User) async throws {
    try await callAsFunction(on: user) {
      try await user.delete()
    }
  }
}
