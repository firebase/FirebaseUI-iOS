@preconcurrency import FirebaseAuth
import SwiftUI

@MainActor
public class EmailPasswordAuthProvider {
  private let authEnvironment: AuthEnvironment

  public init(authEnvironment: AuthEnvironment) {
    self.authEnvironment = authEnvironment
  }

  func signIn(withEmail email: String, password: String) async throws {
    let credential = EmailAuthProvider.credential(withEmail: email, password: password)
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

  func sendPasswordRecoveryEmail(to email: String) async throws {
    do {
      try await authEnvironment.auth.sendPasswordReset(withEmail: email)
    } catch {
      throw error
    }
  }

  func sendEmailSignInLink(to email: String) async throws {
    do {
      // TODO: - how does user set action code settings? Needs configuring
      let actionCodeSettings = ActionCodeSettings()
      actionCodeSettings.handleCodeInApp = true
      try await authEnvironment.auth.sendSignInLink(
        toEmail: email,
        actionCodeSettings: actionCodeSettings
      )
    } catch {
      throw error
    }
  }
}
