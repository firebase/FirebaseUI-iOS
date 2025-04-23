@preconcurrency import FirebaseAuth
import Observation

protocol EmailPasswordOperationReauthentication {
  var passwordPrompt: PasswordPromptCoordinator { get }
}

extension EmailPasswordOperationReauthentication {
  func reauthenticate() async throws -> AuthenticationToken {
    guard let user = Auth.auth().currentUser else {
      throw AuthServiceError.reauthenticationRequired("No user currently signed-in")
    }

    guard let email = user.email else {
      throw AuthServiceError.invalidCredentials("User does not have an email address")
    }

    do {
      let password = try await passwordPrompt.confirmPassword()

      let credential = EmailAuthProvider.credential(withEmail: email, password: password)
      try await Auth.auth().currentUser?.reauthenticate(with: credential)

      return .firebase("")
    } catch {
      throw AuthServiceError.signInFailed(underlying: error)
    }
  }
}

class EmailPasswordDeleteUserOperation: DeleteUserOperation,
  EmailPasswordOperationReauthentication {
  let passwordPrompt: PasswordPromptCoordinator

  init(passwordPrompt: PasswordPromptCoordinator) {
    self.passwordPrompt = passwordPrompt
  }
}

@MainActor
@Observable
public final class PasswordPromptCoordinator {
  var isPromptingPassword = false
  private var continuation: CheckedContinuation<String, Error>?

  func confirmPassword() async throws -> String {
    return try await withCheckedThrowingContinuation { continuation in
      self.continuation = continuation
      self.isPromptingPassword = true
    }
  }

  func submit(password: String) {
    continuation?.resume(returning: password)
    cleanup()
  }

  func cancel() {
    continuation?
      .resume(throwing: AuthServiceError.reauthenticationRequired("Password entry cancelled"))
    cleanup()
  }

  private func cleanup() {
    continuation = nil
    isPromptingPassword = false
  }
}
