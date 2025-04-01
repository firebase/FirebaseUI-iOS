@preconcurrency import FirebaseAuth
import SwiftUI

public protocol GoogleProviderProtocol {
  func handleUrl(_ url: URL) -> Bool
}

public enum AuthenticationProvider {
  case email
  case google
}

public enum AuthenticationOperationType: String {
  case signIn
  case signUp
  case deleteAccount
}

public enum AuthenticationState {
  case unauthenticated
  case authenticating
  case authenticated
}

public enum AuthenticationFlow {
  case login
  case signUp
}

@MainActor
final class AuthListenerManager {
  private var authStateHandle: AuthStateDidChangeListenerHandle?
  private let auth: Auth
  private weak var authEnvironment: AuthService?

  init(auth: Auth, authEnvironment: AuthService) {
    self.auth = auth
    self.authEnvironment = authEnvironment
    setupAuthenticationListener()
  }

  deinit {
    if let handle = authStateHandle {
      auth.removeStateDidChangeListener(handle)
    }
  }

  private func setupAuthenticationListener() {
    authStateHandle = auth.addStateDidChangeListener { [weak self] _, user in
      self?.authEnvironment?.currentUser = user
      self?.authEnvironment?.updateAuthenticationState()
    }
  }
}

@MainActor
@Observable
public final class AuthService {
  public let configuration: AuthConfiguration
  public let auth: Auth
  private var listenerManager: AuthListenerManager?
  private let googleProvider: GoogleProviderProtocol?

  public init(configuration: AuthConfiguration = AuthConfiguration(), auth: Auth = Auth.auth(),
              googleProvider: GoogleProviderProtocol? = nil) {
    self.auth = auth
    self.configuration = configuration
    self.googleProvider = googleProvider
    listenerManager = AuthListenerManager(auth: auth, authEnvironment: self)
  }

  public var currentUser: User?
  public var authenticationState: AuthenticationState = .unauthenticated
  public var authenticationFlow: AuthenticationFlow = .login

  private var safeGoogleProvider: GoogleProviderProtocol {
    get throws {
      guard let provider = googleProvider else {
        throw NSError(
          domain: "AuthEnvironmentErrorDomain",
          code: 1,
          userInfo: [
            NSLocalizedDescriptionKey: "`GoogleProviderSwift` has not been configured",
          ]
        )
      }
      return provider
    }
  }

  func updateAuthenticationState() {
    authenticationState =
      (currentUser == nil || currentUser?.isAnonymous == true)
        ? .unauthenticated
        : .authenticated
  }

  public func signOut() async throws {
    try await auth.signOut()
    updateAuthenticationState()
  }

  func signIn(with credentials: AuthCredential) async throws {
    authenticationState = .authenticating
    do {
      try await auth.signIn(with: credentials)
      updateAuthenticationState()
    } catch {
      authenticationState = .unauthenticated
      throw error
    }
  }

  func sendEmailVerification() async throws {
    if currentUser != nil {
      do {
        // TODO: - can use set user action code settings?
        try await currentUser!.sendEmailVerification()
      } catch {
        throw error
      }
    }
  }

  func signIn(withEmail email: String, password: String) async throws {
    let credential = EmailAuthProvider.credential(withEmail: email, password: password)
    try await auth.signIn(with: credential)
  }

  func createUser(withEmail email: String, password: String) async throws {
    authenticationState = .authenticating
    do {
      try await auth.createUser(withEmail: email, password: password)
      updateAuthenticationState()
    } catch {
      authenticationState = .unauthenticated
      throw error
    }
  }

  func sendPasswordRecoveryEmail(to email: String) async throws {
    do {
      try await auth.sendPasswordReset(withEmail: email)
    } catch {
      throw error
    }
  }

  func sendEmailSignInLink(to email: String) async throws {
    do {
      // TODO: - how does user set action code settings? Needs configuring
      let actionCodeSettings = ActionCodeSettings()
      actionCodeSettings.handleCodeInApp = true
      try await auth.sendSignInLink(
        toEmail: email,
        actionCodeSettings: actionCodeSettings
      )
    } catch {
      throw error
    }
  }
}
