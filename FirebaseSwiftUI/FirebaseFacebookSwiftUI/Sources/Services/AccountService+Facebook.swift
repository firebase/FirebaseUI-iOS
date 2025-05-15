//
//  AccountService+Facebook.swift
//  FirebaseUI
//
//  Created by Russell Wheatley on 14/05/2025.
//

@preconcurrency import FirebaseAuth
import FirebaseAuthSwiftUI
import Observation

protocol FacebookOperationReauthentication {
  var facebookProvider: FacebookProviderAuthUI { get }
}

extension FacebookOperationReauthentication {
  @MainActor func reauthenticate() async throws -> AuthenticationToken {
    guard let user = Auth.auth().currentUser else {
      throw AuthServiceError.reauthenticationRequired("No user currently signed-in")
    }

    do {
      let credential = try await facebookProvider
        .signInWithFacebook(isLimitedLogin: facebookProvider.isLimitedLogin)
      try await user.reauthenticate(with: credential)

      return .firebase("")
    } catch {
      throw AuthServiceError.signInFailed(underlying: error)
    }
  }
}

@MainActor
class FacebookDeleteUserOperation: AuthenticatedOperation,
  @preconcurrency FacebookOperationReauthentication {
  let facebookProvider: FacebookProviderAuthUI
  init(facebookProvider: FacebookProviderAuthUI) {
    self.facebookProvider = facebookProvider
  }

  func callAsFunction(on user: User) async throws {
    try await callAsFunction(on: user) {
      try await user.delete()
    }
  }
}
