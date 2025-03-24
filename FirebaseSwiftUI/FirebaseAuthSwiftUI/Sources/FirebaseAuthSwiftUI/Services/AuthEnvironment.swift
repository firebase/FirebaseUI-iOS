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
  public static let shared = AuthEnvironment()

  // TODO: - need to know how we're configuring the below properties or if they should live on AuthEnvironment
  let auth: Auth = .auth()
  let language: String = "en"
  let enableAutoAnonymousLogin: Bool = true

  var currentUser: User?
  var errorMessage = ""

  private var listenerManager: AuthListenerManager?

  private init() {
    listenerManager = AuthListenerManager(auth: auth, authEnvironment: self)
  }

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
}
