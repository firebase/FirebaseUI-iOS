// Copyright 2025 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

@preconcurrency import FirebaseAuth
import SwiftUI

public protocol AuthProviderSwift {
  @MainActor func createAuthCredential() async throws -> AuthCredential
}

public protocol AuthProviderUI {
  var id: String { get }
  @MainActor func authButton() -> AnyView
  var provider: AuthProviderSwift { get }
}

public protocol DeleteUserSwift {
  @MainActor func deleteUser(user: User) async throws
}

public protocol PhoneAuthProviderAuthUIProtocol: AuthProviderSwift {
  @MainActor func verifyPhoneNumber(phoneNumber: String) async throws -> String
}

public enum AuthenticationState {
  case unauthenticated
  case authenticating
  case authenticated
}

public enum AuthenticationFlow {
  case signIn
  case signUp
}

public enum AuthView {
  case authPicker
  case passwordRecovery
  case emailLink
  case updatePassword
}

public enum SignInOutcome: @unchecked Sendable {
  case signedIn(AuthDataResult?)
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
  public var authenticationFlow: AuthenticationFlow = .signIn
  public var errorMessage = ""
  public let passwordPrompt: PasswordPromptCoordinator = .init()

  // MARK: - AuthPickerView Modal APIs

  public var isShowingAuthModal = false

  public enum AuthModalContentType {
    case phoneAuth
  }

  public var currentModal: AuthModalContentType?

  public var authModalViewBuilderRegistry: [AuthModalContentType: () -> AnyView] = [:]

  public func registerModalView(for type: AuthModalContentType,
                                @ViewBuilder builder: @escaping () -> AnyView) {
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

  private var listenerManager: AuthListenerManager?
  public var signedInCredential: AuthCredential?

  var emailSignInEnabled = false

  private var providers: [AuthProviderUI] = []
  public func registerProvider(provider: AuthProviderUI) {
    providers.append(provider)
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

  public func signIn(_ provider: AuthProviderSwift) async throws -> SignInOutcome {
    let credential = try await provider.createAuthCredential()
    let result = try await signIn(credentials: credential)
    return result
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

  public func handleAutoUpgradeAnonymousUser(credentials: AuthCredential) async throws -> SignInOutcome {
    if currentUser == nil {
      throw AuthServiceError.noCurrentUser
    }
    do {
      let result = try await currentUser?.link(with: credentials)
      updateAuthenticationState()
      return .signedIn(result)
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

  public func signIn(credentials: AuthCredential) async throws -> SignInOutcome {
    authenticationState = .authenticating
    do {
      if shouldHandleAnonymousUpgrade {
        return try await handleAutoUpgradeAnonymousUser(credentials: credentials)
      } else {
        let result = try await auth.signIn(with: credentials)
        signedInCredential = result.credential ?? credentials
        updateAuthenticationState()
        return .signedIn(result)
      }
    } catch {
      authenticationState = .unauthenticated
      errorMessage = string.localizedErrorMessage(
        for: error
      )
      throw error
    }
  }

  func sendEmailVerification() async throws {
    do {
      if let user = currentUser {
        // Requires running on MainActor as passing to sendEmailVerification() which is non-isolated
        let settings: ActionCodeSettings? = await MainActor.run {
          configuration.verifyEmailActionCodeSettings
        }

        if let settings = settings {
          try await user.sendEmailVerification(with: settings)
        } else {
          try await user.sendEmailVerification()
        }
      }
    } catch {
      errorMessage = string.localizedErrorMessage(
        for: error
      )
      throw error
    }
  }
}

// MARK: - User API

public extension AuthService {
  func deleteUser() async throws {
    do {
      if let user = auth.currentUser, let providerId = signedInCredential?.provider {
        if providerId == EmailAuthProviderID {
          let operation = EmailPasswordDeleteUserOperation(passwordPrompt: passwordPrompt)
          try await operation(on: user)
        } else {
          // Find provider by matching ID and ensure it can delete users
          guard let matchingProvider = providers.first(where: { $0.id == providerId }),
                let provider = matchingProvider.provider as? DeleteUserSwift else {
            throw AuthServiceError.providerNotFound("No provider found for \(providerId)")
          }
          
          try await provider.deleteUser(user: user)
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

  func signIn(withEmail email: String, password: String) async throws -> SignInOutcome {
    let credential = EmailAuthProvider.credential(withEmail: email, password: password)
    return try await signIn(credentials: credential)
  }

  func createUser(withEmail email: String, password: String) async throws -> SignInOutcome {
    authenticationState = .authenticating

    do {
      if shouldHandleAnonymousUpgrade {
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        return try await handleAutoUpgradeAnonymousUser(credentials: credential)
      } else {
        let result = try await auth.createUser(withEmail: email, password: password)
        signedInCredential = result.credential
        updateAuthenticationState()
        return .signedIn(result)
      }
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


// MARK: - Phone Auth Sign In

public extension AuthService {
  func verifyPhoneNumber(phoneNumber: String) async throws -> String {
    return try await withCheckedThrowingContinuation { continuation in
      PhoneAuthProvider.provider()
        .verifyPhoneNumber(phoneNumber, uiDelegate: nil) { verificationID, error in
          if let error = error {
            continuation.resume(throwing: error)
            return
          }
          continuation.resume(returning: verificationID!)
        }
    }
  }

  func signInWithPhoneNumber(verificationID: String, verificationCode: String) async throws {
    let credential = PhoneAuthProvider.provider()
      .credential(withVerificationID: verificationID, verificationCode: verificationCode)
    try await signIn(credentials: credential)
  }
}
