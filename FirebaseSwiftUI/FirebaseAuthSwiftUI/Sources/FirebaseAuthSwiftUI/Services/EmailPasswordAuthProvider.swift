@preconcurrency import FirebaseAuth
import SwiftUI

@MainActor
public class EmailPasswordAuthProvider {
  private let authService: AuthService

  public init(authService: AuthService) {
    self.authService = authService
  }

  func signIn(withEmail email: String, password: String) async throws {
    let credential = EmailAuthProvider.credential(withEmail: email, password: password)
    try await authService.signIn(with: credential)
  }

  func createUser(withEmail email: String, password: String) async throws {
    authService.authenticationState = .authenticating
    do {
      try await authService.auth.createUser(withEmail: email, password: password)
      authService.updateAuthenticationState()
    } catch {
      authService.authenticationState = .unauthenticated
      throw error
    }
  }

  func sendPasswordRecoveryEmail(to email: String) async throws {
    do {
      try await authService.auth.sendPasswordReset(withEmail: email)
    } catch {
      throw error
    }
  }

  func sendEmailSignInLink(to email: String) async throws {
    do {
      // TODO: - how does user set action code settings? Needs configuring
      let actionCodeSettings = ActionCodeSettings()
      actionCodeSettings.handleCodeInApp = true
      try await authService.auth.sendSignInLink(
        toEmail: email,
        actionCodeSettings: actionCodeSettings
      )
    } catch {
      throw error
    }
  }
}
