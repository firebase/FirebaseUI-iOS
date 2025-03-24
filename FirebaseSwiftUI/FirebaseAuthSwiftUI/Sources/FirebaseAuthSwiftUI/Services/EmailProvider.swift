@preconcurrency import FirebaseAuth
import SwiftUI

@MainActor
public class EmailAuthProvider {
  private let authEnvironment: AuthEnvironment

  public init(authEnvironment: AuthEnvironment) {
    self.authEnvironment = authEnvironment
  }

  func signIn(withEmail email: String, password: String) async throws {
    let credential = FirebaseAuth.EmailAuthProvider.credential(withEmail: email, password: password)
    try await authEnvironment.signIn(with: credential)
  }

  func createUser(withEmail email: String, password: String) async throws {
    authEnvironment.authenticationState = .authenticating
    do {
      try await authEnvironment.auth.createUser(withEmail: email, password: password)
      authEnvironment.updateAuthenticationState()
    } catch {
      authEnvironment.authenticationState = .unauthenticated
      throw error
    }
  }
}
