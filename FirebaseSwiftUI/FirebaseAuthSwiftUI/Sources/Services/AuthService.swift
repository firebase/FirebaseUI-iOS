@preconcurrency import FirebaseAuth
import SwiftUI

public protocol ExternalAuthProvider: Identifiable {
  var id: String { get }
  associatedtype ButtonType: View
  @MainActor func authButton() -> AnyView
  @MainActor var authButtonView: Self.ButtonType { get }
}

public protocol GoogleProviderProtocol: ExternalAuthProvider {
  @MainActor func signInWithGoogle(clientID: String) async throws -> AuthCredential
}

public protocol FacebookProviderProtocol: ExternalAuthProvider {
  @MainActor func signInWithFacebook(isLimitedLogin: Bool) async throws -> AuthCredential
}

public protocol PhoneAuthProviderProtocol: ExternalAuthProvider {
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

public enum AuthView {
  case authPicker
  case passwordRecovery
  case emailLink
  case updatePassword
}

@MainActor
private final class AuthListenerManager {
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
  public init(configuration: AuthConfiguration = AuthConfiguration(), auth: Auth = Auth.auth()) {
    self.auth = auth
    self.configuration = configuration
    string = StringUtils(bundle: configuration.customStringsBundle ?? Bundle.module)
    listenerManager = AuthListenerManager(auth: auth, authEnvironment: self)
  }

  @ObservationIgnored @AppStorage("email-link") public var emailLink: String?
  public let configuration: AuthConfiguration
  public let auth: Auth
  public var authView: AuthView = .authPicker
  public let string: StringUtils
  public var currentUser: User?
  public var authenticationState: AuthenticationState = .unauthenticated
  public var authenticationFlow: AuthenticationFlow = .login
  public var errorMessage = ""
  public let passwordPrompt: PasswordPromptCoordinator = .init()

  public var googleProvider: (any GoogleProviderProtocol)?
  public var facebookProvider: (any FacebookProviderProtocol)?
  public var phoneAuthProvider: (any PhoneAuthProviderProtocol)?

  private var listenerManager: AuthListenerManager?
  private var signedInCredential: AuthCredential?

  private var providers: [any ExternalAuthProvider] = []
  public func register(provider: any ExternalAuthProvider) {
    providers.append(provider)
  }

  var availableProviders: [any ExternalAuthProvider] {
    return providers
  }

  private var safeGoogleProvider: any GoogleProviderProtocol {
    get throws {
      guard let provider = googleProvider else {
        throw AuthServiceError
          .notConfiguredProvider("`GoogleProviderSwift` has not been configured")
      }
      return provider
    }
  }

  private var safeFacebookProvider: any FacebookProviderProtocol {
    get throws {
      guard let provider = facebookProvider else {
        throw AuthServiceError
          .notConfiguredProvider("`FacebookProviderSwift` has not been configured")
      }
      return provider
    }
  }

  private var safePhoneAuthProvider: any PhoneAuthProviderProtocol {
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
        .notConfiguredActionCodeSettings
    }
    return actionCodeSettings
  }

  public func updateAuthenticationState() {
    reset()
    authenticationState =
      (currentUser == nil || currentUser?.isAnonymous == true)
        ? .unauthenticated
        : .authenticated
  }

  func reset() {
    errorMessage = ""
  }

  public func signOut() async throws {
    do {
      try await auth.signOut()
      updateAuthenticationState()
    } catch {
      errorMessage = string.localizedErrorMessage(
        for: error
      )
      throw error
    }
  }

  public func linkAccounts(credentials credentials: AuthCredential) async throws {
    authenticationState = .authenticating
    do {
      try await currentUser?.link(with: credentials)
      updateAuthenticationState()
    } catch {
      authenticationState = .unauthenticated
      errorMessage = string.localizedErrorMessage(
        for: error
      )
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
        errorMessage = string.localizedErrorMessage(
          for: error
        )
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
        errorMessage = string.localizedErrorMessage(
          for: error
        )
        throw error
      }
    }
  }
}

// MARK: - User API

public extension AuthService {
  func deleteUser() async throws {
    do {
      if let user = auth.currentUser {
        let operation = EmailPasswordDeleteUserOperation(passwordPrompt: passwordPrompt)
        try await operation(on: user)
      }

    } catch {
      errorMessage = string.localizedErrorMessage(
        for: error
      )
      throw error
    }
  }

  func updatePassword(to password: String) async throws {
    do {
      if let user = auth.currentUser {
        let operation = EmailPasswordUpdatePasswordOperation(
          passwordPrompt: passwordPrompt,
          newPassword: password
        )
        try await operation(on: user)
      }

    } catch {
      errorMessage = string.localizedErrorMessage(
        for: error
      )
      throw error
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
      errorMessage = string.localizedErrorMessage(
        for: error
      )
      throw error
    }
  }

  func sendPasswordRecoveryEmail(to email: String) async throws {
    do {
      try await auth.sendPasswordReset(withEmail: email)
    } catch {
      errorMessage = string.localizedErrorMessage(
        for: error
      )
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
      errorMessage = string.localizedErrorMessage(
        for: error
      )
      throw error
    }
  }

  func handleSignInLink(url url: URL) async throws {
    do {
      guard let email = emailLink else {
        throw AuthServiceError.invalidEmailLink
      }
      let link = url.absoluteString
      if auth.isSignIn(withEmailLink: link) {
        let result = try await auth.signIn(withEmail: email, link: link)
        updateAuthenticationState()
        emailLink = nil
      }
    } catch {
      errorMessage = string.localizedErrorMessage(
        for: error
      )
      throw error
    }
  }
}

// MARK: - Google Sign In

public extension AuthService {
  func signInWithGoogle() async throws {
    guard let clientID = auth.app?.options.clientID else {
      throw AuthServiceError
        .clientIdNotFound(
          "OAuth client ID not found. Please make sure Google Sign-In is enabled in the Firebase console. You may have to download a new GoogleService-Info.plist file after enabling Google Sign-In."
        )
    }
    let credential = try await safeGoogleProvider.signInWithGoogle(clientID: clientID)

    try await signIn(credentials: credential)
  }
}

// MARK: - Facebook Sign In

public extension AuthService {
  func signInWithFacebook(limitedLogin: Bool = true) async throws {
    let credential = try await safeFacebookProvider
      .signInWithFacebook(isLimitedLogin: limitedLogin)
    try await signIn(credentials: credential)
  }
}

// MARK: - Phone Auth Sign In

public extension AuthService {
  func verifyPhoneNumber(phoneNumber: String) async throws -> String {
    do {
      return try await safePhoneAuthProvider.verifyPhoneNumber(phoneNumber: phoneNumber)
    } catch {
      errorMessage = string.localizedErrorMessage(
        for: error
      )
      throw error
    }
  }

  func signInWithPhoneNumber(verificationID: String, verificationCode: String) async throws {
    let credential = PhoneAuthProvider.provider()
      .credential(withVerificationID: verificationID, verificationCode: verificationCode)
    try await signIn(credentials: credential)
  }
}
