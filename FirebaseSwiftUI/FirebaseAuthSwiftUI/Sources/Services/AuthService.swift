@preconcurrency import FirebaseAuth
import SwiftUI

public protocol GoogleProviderProtocol {
  func handleUrl(_ url: URL) -> Bool
  @MainActor func signInWithGoogle(clientID: String) async throws -> AuthCredential
}

public protocol FacebookProviderProtocol {
  @MainActor func signInWithFacebook(isLimitedLogin: Bool) async throws -> AuthCredential
}

public protocol PhoneAuthProviderProtocol {
  @MainActor func verifyPhoneNumber(phoneNumber: String) async throws -> String
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

public enum AuthServiceError: Error {
  case invalidEmailLink(String)
  case notConfiguredProvider(String)
  case clientIdNotFound(String)
  case notConfiguredActionCodeSettings(String)
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
  public init(configuration: AuthConfiguration = AuthConfiguration(), auth: Auth = Auth.auth(),
              googleProvider: GoogleProviderProtocol? = nil,
              facebookProvider: FacebookProviderProtocol? = nil,
              phoneAuthProvider: PhoneAuthProviderProtocol? = nil) {
    self.auth = auth
    self.configuration = configuration
    self.googleProvider = googleProvider
    self.facebookProvider = facebookProvider
    self.phoneAuthProvider = phoneAuthProvider
    string = StringUtils(bundle: configuration.customStringsBundle ?? Bundle.module)
    listenerManager = AuthListenerManager(auth: auth, authEnvironment: self)
  }

  @ObservationIgnored @AppStorage("email-link") public var emailLink: String?
  public let configuration: AuthConfiguration
  public let auth: Auth

  public let string: StringUtils
  public var currentUser: User?
  public var authenticationState: AuthenticationState = .unauthenticated
  public var authenticationFlow: AuthenticationFlow = .login

  private var listenerManager: AuthListenerManager?
  private let googleProvider: GoogleProviderProtocol?
  private let facebookProvider: FacebookProviderProtocol?
  private let phoneAuthProvider: PhoneAuthProviderProtocol?

  private var safeGoogleProvider: GoogleProviderProtocol {
    get throws {
      guard let provider = googleProvider else {
        throw AuthServiceError
          .notConfiguredProvider("`GoogleProviderSwift` has not been configured")
      }
      return provider
    }
  }

  private var safeFacebookProvider: FacebookProviderProtocol {
    get throws {
      guard let provider = facebookProvider else {
        throw AuthServiceError
          .notConfiguredProvider("`FacebookProviderSwift` has not been configured")
      }
      return provider
    }
  }

  private var safePhoneAuthProvider: PhoneAuthProviderProtocol {
    get throws {
      guard let provider = phoneAuthProvider else {
        throw AuthServiceError
          .notConfiguredProvider("`PhoneAuthProviderSwift` has not been configured")
      }
      return provider
    }
  }

  private func safeActionCodeSettings() throws -> ActionCodeSettings {
    // email sign-in requires action code settings
    guard let actionCodeSettings = configuration
      .emailLinkSignInActionCodeSettings else {
      throw AuthServiceError
        .notConfiguredActionCodeSettings(
          "ActionCodeSettings has not been configured for `AuthConfiguration.emailLinkSignInActionCodeSettings`"
        )
    }
    return actionCodeSettings
  }

  public func updateAuthenticationState() {
    authenticationState =
      (currentUser == nil || currentUser?.isAnonymous == true)
        ? .unauthenticated
        : .authenticated
  }

  public func signOut() async throws {
    try await auth.signOut()
    updateAuthenticationState()
  }

  public func linkAccounts(credentials credentials: AuthCredential) async throws {
    authenticationState = .authenticating
    do {
      try await currentUser?.link(with: credentials)
      updateAuthenticationState()
    } catch {
      authenticationState = .unauthenticated
      throw error
    }
  }

  public func signIn(credentials credentials: AuthCredential) async throws {
    authenticationState = .authenticating
    if currentUser?.isAnonymous == true, configuration.shouldAutoUpgradeAnonymousUsers {
      try await linkAccounts(credentials: credentials)
    } else {
      do {
        try await auth.signIn(with: credentials)
        updateAuthenticationState()
      } catch {
        authenticationState = .unauthenticated
        throw error
      }
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

// MARK: - Email/Password Sign In

public extension AuthService {
  func signIn(withEmail email: String, password: String) async throws {
    let credential = EmailAuthProvider.credential(withEmail: email, password: password)
    try await signIn(credentials: credential)
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
}

// MARK: - Email Link Sign In

public extension AuthService {
  func sendEmailSignInLink(to email: String) async throws {
    do {
      let actionCodeSettings = try safeActionCodeSettings()
      try await auth.sendSignInLink(
        toEmail: email,
        actionCodeSettings: actionCodeSettings
      )
    } catch {
      throw error
    }
  }

  func handleSignInLink(url url: URL) async throws {
    do {
      guard let email = emailLink else {
        throw AuthServiceError.invalidEmailLink(
          "Invalid email address. Most likely, the link you used has expired. Try signing in again."
        )
      }
      let link = url.absoluteString
      if auth.isSignIn(withEmailLink: link) {
        let result = try await auth.signIn(withEmail: email, link: link)
        updateAuthenticationState()
        emailLink = nil
      }
    } catch {
      throw error
    }
  }
}

// MARK: - Google Sign In

public extension AuthService {
  func signInWithGoogle() async throws {
    authenticationState = .authenticating
    do {
      guard let clientID = auth.app?.options.clientID else {
        throw AuthServiceError
          .clientIdNotFound(
            "OAuth client ID not found. Please make sure Google Sign-In is enabled in the Firebase console. You may have to download a new GoogleService-Info.plist file after enabling Google Sign-In."
          )
      }
      let credential = try await safeGoogleProvider.signInWithGoogle(clientID: clientID)

      try await signIn(credentials: credential)
      updateAuthenticationState()
    } catch {
      authenticationState = .unauthenticated
      throw error
    }
  }
}

// MARK: - Facebook Sign In

public extension AuthService {
  func signInWithFacebook(limitedLogin: Bool = true) async throws {
    authenticationState = .authenticating
    do {
      let credential = try await safeFacebookProvider
        .signInWithFacebook(isLimitedLogin: limitedLogin)
      try await signIn(credentials: credential)
      updateAuthenticationState()
    } catch {
      authenticationState = .unauthenticated
      throw error
    }
  }
}

// MARK: - Phone Auth Sign In

public extension AuthService {
  func verifyPhoneNumber(phoneNumber: String) async throws -> String {
    return try await safePhoneAuthProvider.verifyPhoneNumber(phoneNumber: phoneNumber)
  }

  func signInWithPhoneNumber(verificationID: String, verificationCode: String) async throws {
    authenticationState = .authenticating
    do {
      let credential = PhoneAuthProvider.provider()
        .credential(withVerificationID: verificationID, verificationCode: verificationCode)
      try await signIn(credentials: credential)
      updateAuthenticationState()
    } catch {
      authenticationState = .unauthenticated
      throw error
    }
  }
}
