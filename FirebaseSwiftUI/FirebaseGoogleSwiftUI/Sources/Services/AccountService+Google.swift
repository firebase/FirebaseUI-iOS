//
//  AccountService+Google.swift
//  FirebaseUI
//
//  Created by Russell Wheatley on 22/05/2025.
//

//
//  AccountService+Facebook.swift
//  FirebaseUI
//
//  Created by Russell Wheatley on 14/05/2025.
//

@preconcurrency import FirebaseAuth
import FirebaseAuthSwiftUI
import Observation

protocol GoogleOperationReauthentication {
  var googleProvider: GoogleProviderAuthUI { get }
}

extension GoogleOperationReauthentication {
  @MainActor func reauthenticate() async throws -> AuthenticationToken {
    guard let user = Auth.auth().currentUser else {
      throw AuthServiceError.reauthenticationRequired("No user currently signed-in")
    }

    do {
      let credential = try await googleProvider
        .signInWithGoogle(clientID: googleProvider.clientID)
      try await user.reauthenticate(with: credential)

      return .firebase("")
    } catch {
      throw AuthServiceError.signInFailed(underlying: error)
    }
  }
}

@MainActor
class GoogleDeleteUserOperation: AuthenticatedOperation,
  @preconcurrency GoogleOperationReauthentication {
  let googleProvider: GoogleProviderAuthUI
  init(googleProvider: GoogleProviderAuthUI) {
    self.googleProvider = googleProvider
  }

  func callAsFunction(on user: User) async throws {
    try await callAsFunction(on: user) {
      try await user.delete()
    }
  }
}
