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

public enum AuthView {
  case authPicker
  case passwordRecovery
  case emailLink
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
  public var authView: AuthView = .authPicker
  public let string: StringUtils
  public var currentUser: User?
  public var authenticationState: AuthenticationState = .unauthenticated
  public var authenticationFlow: AuthenticationFlow = .login
  public var errorMessage = ""
  public let passwordPrompt: PasswordPromptCoordinator = .init()

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

  public var shouldHandleAnonymousUpgrade: Bool {
    currentUser?.isAnonymous == true && configuration.shouldAutoUpgradeAnonymousUsers
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

  public func handleAutoUpgradeAnonymousUser(credentials credentials: AuthCredential) async throws {
    do {
      try await currentUser?.link(with: credentials)
    } catch let error as NSError {
      if error.code == AuthErrorCode.emailAlreadyInUse.rawValue {
        let context = AccountMergeConflictContext(
          credential: credentials,
          underlyingError: error,
          message: "Unable to merge accounts. Use the credential in the context to resolve the conflict."
        )
        throw AuthServiceError.accountMergeConflict(context: context)
      }
      throw error
    }
  }

  public func signIn(credentials credentials: AuthCredential) async throws {
    authenticationState = .authenticating
    do {
      if shouldHandleAnonymousUpgrade {
        try await handleAutoUpgradeAnonymousUser(credentials: credentials)
      } else {
        try await auth.signIn(with: credentials)
      }
      updateAuthenticationState()
    } catch {
      authenticationState = .unauthenticated
      errorMessage = string.localizedErrorMessage(
        for: error
      )
      throw error
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
      if shouldHandleAnonymousUpgrade {
        // TODO: - check this works. This is how it is done in previous implementation, but I wonder if this would fail
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        try await handleAutoUpgradeAnonymousUser(credentials: credential)
      } else {
        try await auth.createUser(withEmail: email, password: password)
      }
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
      // TODO: - get anonymous id here and check against current user before linking accounts
      // put anonymous uid on link and get it back: https://github.com/firebase/FirebaseUI-iOS/blob/main/FirebaseEmailAuthUI/Sources/FUIEmailAuth.m#L822
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
