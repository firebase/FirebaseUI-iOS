@preconcurrency import FirebaseAuth
import SwiftUI

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
  private weak var authEnvironment: AuthEnvironment?

  init(auth: Auth, authEnvironment: AuthEnvironment) {
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
public final class AuthEnvironment {
  public let configuration: AuthConfiguration
  public let auth: Auth
  private var listenerManager: AuthListenerManager?
  private let emailAuthProvider: EmailPasswordAuthProvider?

  public var safeEmailProvider: EmailPasswordAuthProvider {
    get throws {
      guard let provider = emailAuthProvider else {
        throw NSError(
          domain: "AuthEnvironmentErrorDomain",
          code: 1,
          userInfo: [
            NSLocalizedDescriptionKey: "`EmailPasswordAuthProvider` has not been configured",
          ]
        )
      }
      return provider
    }
  }

  public init(configuration: AuthConfiguration = AuthConfiguration(), auth: Auth = Auth.auth(),
              emailAuthProvider: EmailPasswordAuthProvider) {
    self.auth = auth
    self.configuration = configuration
    self.emailAuthProvider = emailAuthProvider
    listenerManager = AuthListenerManager(auth: auth, authEnvironment: self)
  }

  public var currentUser: User?
  public var authenticationState: AuthenticationState = .unauthenticated
  public var authenticationFlow: AuthenticationFlow = .login

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

  func signIn(withEmail email: String, password: String) async throws {
    authenticationState = .authenticating
    do {
      try await safeEmailProvider.signIn(auth: auth, email: email, password: password)
      updateAuthenticationState()
    } catch {
      authenticationState = .unauthenticated
      throw error
    }
  }

  func createUser(withEmail email: String, password: String) async throws {
    authenticationState = .authenticating
    do {
      try await safeEmailProvider.createUser(auth: auth, email: email, password: password)
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
}
