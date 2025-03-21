@preconcurrency import FirebaseAuth
import SwiftUI

@MainActor
class EmailAuthProvider {
  @Environment(AuthEnvironment.self) private var authEnvironment

  public init() {}

  func signIn(withEmail email: String, password: String) async throws {
    authEnvironment.authenticationState = .authenticating
    do {
      try await Auth.auth().createUser(withEmail: email, password: password)
    } catch {
      authEnvironment.authenticationState = .unauthenticated
      throw error
    }
  }

  func signUp(withEmail email: String, password: String) async throws {
    authEnvironment.authenticationState = .authenticating
    do {
      try await Auth.auth().createUser(withEmail: email, password: password)
    } catch {
      authEnvironment.authenticationState = .unauthenticated
      throw error
    }
  }
}
