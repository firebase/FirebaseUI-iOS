@preconcurrency import FirebaseAuth
import SwiftUI

public protocol ExternalAuthProvider {
  var id: String { get }
  @MainActor func authButton() -> AnyView
}

public protocol GoogleProviderAuthUIProtocol: ExternalAuthProvider {
  @MainActor func signInWithGoogle(clientID: String) async throws -> AuthCredential
}

public protocol FacebookProviderAuthUIProtocol: ExternalAuthProvider {
  @MainActor func signInWithFacebook(isLimitedLogin: Bool) async throws -> AuthCredential
  @MainActor func deleteUser(user: User) async throws
}

public protocol PhoneAuthProviderAuthUIProtocol: ExternalAuthProvider {
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

  // MARK: - AuthPickerView Modal APIs

  public var isShowingAuthModal = false

  public enum AuthModalContentType {
    case phoneAuth
  }

  public var currentModal: AuthModalContentType?

  public var authModalViewBuilderRegistry: [AuthModalContentType: () -> AnyView] = [:]

  public func registerModalView(for type: AuthModalContentType, builder: @escaping () -> AnyView) {
    authModalViewBuilderRegistry[type] = builder
  }

  public func viewForCurrentModal() -> AnyView? {
    guard let type = currentModal,
          let builder = authModalViewBuilderRegistry[type] else {
      return nil
    }
    return builder()
  }

  public func presentModal(for type: AuthModalContentType) {
    currentModal = type
    isShowingAuthModal = true
  }

  public func dismissModal() {
    isShowingAuthModal = false
  }

  // MARK: - End AuthPickerView Modal APIs

  // MARK: - Provider APIs

  private var unsafeGoogleProvider: (any GoogleProviderAuthUIProtocol)?
  private var unsafeFacebookProvider: (any FacebookProviderAuthUIProtocol)?
  private var unsafePhoneAuthProvider: (any PhoneAuthProviderAuthUIProtocol)?

  private var listenerManager: AuthListenerManager?
  private var signedInCredential: AuthCredential?

  var emailSignInEnabled = false

  private var providers: [ExternalAuthProvider] = []
  public func register(provider: ExternalAuthProvider) {
    switch provider {
    case let google as GoogleProviderAuthUIProtocol:
      unsafeGoogleProvider = google
      providers.append(provider)
    case let facebook as FacebookProviderAuthUIProtocol:
      unsafeFacebookProvider = facebook
      providers.append(provider)
    case let phone as PhoneAuthProviderAuthUIProtocol:
      unsafePhoneAuthProvider = phone
      providers.append(provider)
    default:
      break
    }
  }

  public func renderButtons(spacing: CGFloat = 16) -> AnyView {
    AnyView(
      VStack(spacing: spacing) {
        ForEach(providers, id: \.id) { provider in
          provider.authButton()
        }
      }
    )
  }

  private var googleProvider: any GoogleProviderAuthUIProtocol {
    get throws {
      guard let provider = unsafeGoogleProvider else {
        fatalError("`GoogleProviderAuthUI` has not been configured")
      }
      return provider
    }
  }

  private var facebookProvider: any FacebookProviderAuthUIProtocol {
    get throws {
      guard let provider = unsafeFacebookProvider else {
        fatalError("`FacebookProviderAuthUI` has not been configured")
      }
      return provider
    }
  }

  private var phoneAuthProvider: any PhoneAuthProviderAuthUIProtocol {
    get throws {
      guard let provider = unsafePhoneAuthProvider else {
        fatalError("`PhoneAuthProviderAuthUI` has not been configured")
      }
      return provider
    }
  }

  // MARK: - End Provider APIs

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

  public func handleAutoUpgradeAnonymousUser(credentials: AuthCredential) async throws {
    if currentUser == nil {
      throw AuthServiceError.noCurrentUser
    }
    do {
      try await currentUser?.link(with: credentials)
    } catch let error as NSError {
      if error.code == AuthErrorCode.emailAlreadyInUse.rawValue {
        let context = AccountMergeConflictContext(
          credential: credentials,
          underlyingError: error,
          message: "Unable to merge accounts. Use the credential in the context to resolve the conflict.",
          uid: currentUser?.uid
        )
        throw AuthServiceError.accountMergeConflict(context: context)
      }
      throw error
    }
  }

  public func signIn(credentials: AuthCredential) async throws {
    authenticationState = .authenticating
    do {
      if shouldHandleAnonymousUpgrade {
        try await handleAutoUpgradeAnonymousUser(credentials: credentials)
      } else {
        let result = try await auth.signIn(with: credentials)
        signedInCredential = result.credential
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
      if let user = auth.currentUser, let providerId = signedInCredential?.provider {
        if providerId == "password" {
          let operation = EmailPasswordDeleteUserOperation(passwordPrompt: passwordPrompt)
          try await operation(on: user)
        } else if providerId == "facebook.com" {
          try await facebookProvider.deleteUser(user: user)
        }
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
  func withEmailSignIn() -> AuthService {
    emailSignInEnabled = true
    return self
  }

  func signIn(withEmail email: String, password: String) async throws {
    let credential = EmailAuthProvider.credential(withEmail: email, password: password)
    try await signIn(credentials: credential)
  }

  func createUser(withEmail email: String, password: String) async throws {
    authenticationState = .authenticating

    do {
      if shouldHandleAnonymousUpgrade {
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        try await handleAutoUpgradeAnonymousUser(credentials: credential)
      } else {
        let result = try await auth.createUser(withEmail: email, password: password)
        signedInCredential = result.credential
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
      let actionCodeSettings = try updateActionCodeSettings()
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
        throw AuthServiceError
          .invalidEmailLink("email address is missing from app storage. Is this the same device?")
      }
      let link = url.absoluteString
      guard let continueUrl = CommonUtils.getQueryParamValue(from: link, paramName: "continueUrl")
      else {
        throw AuthServiceError
          .invalidEmailLink("`continueUrl` parameter is missing from the email link URL")
      }

      if auth.isSignIn(withEmailLink: link) {
        let anonymousUserID = CommonUtils.getQueryParamValue(
          from: continueUrl,
          paramName: "ui_auid"
        )
        if shouldHandleAnonymousUpgrade, anonymousUserID == currentUser?.uid {
          let credential = EmailAuthProvider.credential(withEmail: email, link: link)
          try await handleAutoUpgradeAnonymousUser(credentials: credential)
        } else {
          let result = try await auth.signIn(withEmail: email, link: link)
        }
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

  private func updateActionCodeSettings() throws -> ActionCodeSettings {
    let actionCodeSettings = try safeActionCodeSettings()
    guard var urlComponents = URLComponents(string: actionCodeSettings.url!.absoluteString) else {
      throw AuthServiceError
        .notConfiguredActionCodeSettings(
          "ActionCodeSettings.url has not been configured for `AuthConfiguration.emailLinkSignInActionCodeSettings`"
        )
    }

    var queryItems: [URLQueryItem] = []

    if shouldHandleAnonymousUpgrade {
      if let currentUser = currentUser {
        let anonymousUID = currentUser.uid
        let auidItem = URLQueryItem(name: "ui_auid", value: anonymousUID)
        queryItems.append(auidItem)
      }
    }

    urlComponents.queryItems = queryItems
    if let finalURL = urlComponents.url {
      actionCodeSettings.url = finalURL
    }

    return actionCodeSettings
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
    let credential = try await googleProvider.signInWithGoogle(clientID: clientID)

    try await signIn(credentials: credential)
  }
}

// MARK: - Facebook Sign In

public extension AuthService {
  func signInWithFacebook(limitedLogin: Bool = true) async throws {
    let credential = try await facebookProvider
      .signInWithFacebook(isLimitedLogin: limitedLogin)
    try await signIn(credentials: credential)
  }
}

// MARK: - Phone Auth Sign In

public extension AuthService {
  func verifyPhoneNumber(phoneNumber: String) async throws -> String {
    do {
      return try await phoneAuthProvider.verifyPhoneNumber(phoneNumber: phoneNumber)
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
