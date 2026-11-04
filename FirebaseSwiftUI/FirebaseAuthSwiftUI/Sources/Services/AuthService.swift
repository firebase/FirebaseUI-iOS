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
import FirebaseAuthUIComponents
import FirebaseCore
import SwiftUI

/// Base protocol for all authentication providers
public protocol AuthProviderSwift {}

/// Protocol for providers that can directly create an AuthCredential
/// Used by Google, Apple, Twitter, Facebook, and OAuth providers
public protocol CredentialAuthProviderSwift: AuthProviderSwift {
  @MainActor func createAuthCredential() async throws -> AuthCredential
}

public protocol AuthProviderUI {
  var id: String { get }
  var displayName: String { get }
  @MainActor func authButton() -> AnyView
  var provider: AuthProviderSwift { get }
}

/// Lets ``AuthService/triggerSignIn(for:)`` start sign-in for a provider that isn't a plain
/// credential provider, such as phone or a custom flow that presents its own screens first.
///
/// When the action signs in through ``AuthService/signIn(credentials:)``, return its outcome so
/// `.mfaRequired` reaches the standard MFA handler. MFA can only be resolved for an outcome from
/// that call, so return `nil` or `.signedIn` for any other sign-in, and `nil` when the action
/// only starts a flow, such as pushing a screen.
///
/// Adopt it on a custom provider so a custom method picker layout can start its sign-in through
/// ``AuthMethodPickerState/select``. Otherwise, start sign-in from the provider's own button.
///
/// Example:
/// ```swift
/// final class MyProviderAuthUI: AuthProviderAction {
///   let authService: AuthService
///   // id, displayName, provider and authButton() as for any AuthProviderUI
///
///   @MainActor func triggerAction() async throws -> SignInOutcome? {
///     let credential = try await presentMySignInScreen()
///     return try await authService.signIn(credentials: credential)
///   }
/// }
/// ```
public protocol AuthProviderAction: AuthProviderUI {
  @MainActor func triggerAction() async throws -> SignInOutcome?
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

public enum AuthView: Hashable {
  case passwordRecovery
  /// A pushed email and password sign-in screen, ``SignInView`` by default. Reached with
  /// ``AuthMethodPickerState/goToEmailSignIn``.
  case signIn
  /// A pushed email and password sign-up screen, ``SignUpView`` by default. Reached with
  /// ``EmailAuthContentState/goToSignUp``.
  case signUp
  case emailLink
  case updatePassword
  case mfaEnrollment
  case mfaManagement
  case mfaResolution(MFARequired)
  case enterPhoneNumber
  case enterVerificationCode(verificationID: String, fullPhoneNumber: String)
}

public enum SignInOutcome: @unchecked Sendable {
  case mfaRequired(MFARequired)
  case signedIn(AuthDataResult?)
}

public struct LegacySignInOption: Identifiable, Equatable {
  public let id: String
  public let displayName: String

  public init(id: String, displayName: String) {
    self.id = id
    self.displayName = displayName
  }
}

public struct LegacySignInRecoveryContext: Identifiable, Equatable {
  public let id = UUID()
  public let email: String
  public let options: [LegacySignInOption]
  public let unavailableProviders: [String]

  public init(email: String,
              options: [LegacySignInOption],
              unavailableProviders: [String] = []) {
    self.email = email
    self.options = options
    self.unavailableProviders = unavailableProviders
  }

  public static func == (lhs: LegacySignInRecoveryContext,
                         rhs: LegacySignInRecoveryContext) -> Bool {
    lhs.id == rhs.id
  }
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

@Observable
public class Navigator {
  var routes: [AuthView] = []

  public func push(_ route: AuthView) {
    routes.append(route)
  }

  @discardableResult
  public func pop() -> AuthView? {
    routes.popLast()
  }

  public func clear() {
    routes.removeAll()
  }

  /// Removes pushed ``AuthView/signIn`` and ``AuthView/signUp`` screens, which have nothing left
  /// to do once the user is signed in.
  func removeEmailRoutes() {
    routes.removeAll { $0 == .signIn || $0 == .signUp }
  }
}

@MainActor
@Observable
public final class AuthService {
  public init(configuration: AuthConfiguration = AuthConfiguration(), auth: Auth = Auth.auth()) {
    self.auth = auth
    self.configuration = configuration
    string = StringUtils(
      bundle: configuration.customStringsBundle ?? Bundle.module,
      languageCode: configuration.languageCode
    )
    listenerManager = AuthListenerManager(auth: auth, authEnvironment: self)
    FirebaseApp.registerLibrary("firebase-ui-ios", withVersion: FirebaseAuthSwiftUIVersion.version)
  }

  @ObservationIgnored @AppStorage("email-link") public var emailLink: String?
  // Needed because provider data sign-in doesn't distinguish between email link and password
  // sign-in needed for reauthentication
  @ObservationIgnored @AppStorage("is-email-link") private var isEmailLinkSignIn: Bool = false
  // Storage for email link reauthentication (separate from sign-in)
  @ObservationIgnored @AppStorage("email-link-reauth") private var emailLinkReauth: String?
  @ObservationIgnored @AppStorage("is-reauthenticating") private(set) var isReauthenticating:
    Bool = false
  /// Identifies the last sign-in link this device sent, written on the link as `ui_sid`.
  @ObservationIgnored @AppStorage("email-link-session-id") private var emailLinkSessionID: String?

  private var currentMFAResolver: MultiFactorResolver?
  private var listenerManager: AuthListenerManager?
  private var emailLinkSignInCallback: (() -> Void)?
  /// Whether the email-link button pushes the library's ``AuthView/emailLink`` screen rather
  /// than running an app's own `onTap`.
  private var emailLinkUsesLibraryScreen = false
  /// The sign-in link being handled, and the last one that signed in, so a link delivered to
  /// several `onOpenURL` handlers is only used once.
  @ObservationIgnored private var emailLinkInFlight: URL?
  @ObservationIgnored private var lastSignedInEmailLink: URL?
  private var providers: [AuthProviderUI] = []
  private let emailLinkSignInMethod = "emailLink"

  public let configuration: AuthConfiguration
  public let auth: Auth
  public var isPresented: Bool = false
  public let string: StringUtils
  public var currentUser: User?
  public var authenticationState: AuthenticationState = .unauthenticated
  public var authenticationFlow: AuthenticationFlow = .signIn
  public var emailPasswordSignInEnabled = false
  /// Whether email sign-up asks for a name and saves it as the account's display name. Set
  /// with ``withEmailSignIn(requireDisplayName:allowNewEmailAccounts:)``.
  public private(set) var requireDisplayName = false
  /// Whether email sign-in offers sign-up and ``createUser(email:password:displayName:)`` may
  /// create accounts. Set with ``withEmailSignIn(requireDisplayName:allowNewEmailAccounts:)``.
  /// Email-link sign-in still creates an account for a new address, as it did in the UIKit
  /// library.
  public private(set) var allowNewEmailAccounts = true
  public var emailLinkSignInEnabled = false
  /// Whether a sign-in link only works on the device that requested it. Set with
  /// ``withEmailLinkSignIn(forceSameDevice:)``.
  public private(set) var emailLinkForceSameDevice = false
  /// A sign-in link opened on a device that didn't request it, waiting for
  /// ``confirmEmailLinkSignIn(email:)``.
  public private(set) var pendingEmailLink: URL?
  /// A sign-in link the app opened while ``EmailLinkScreen`` wasn't showing, handed to it
  /// when it appears.
  var incomingEmailLink: URL?
  public var legacySignInRecovery: LegacySignInRecoveryContext?
  public var suggestedEmailAddress: String?
  public private(set) var navigator = Navigator()

  public var authView: AuthView? {
    navigator.routes.last
  }

  public func registerProvider(providerWithButton: AuthProviderUI) {
    providers.append(providerWithButton)
  }

  /// The providers registered with ``registerProvider(providerWithButton:)``, in registration
  /// order. Email and email-link sign-in aren't included.
  public var registeredProviders: [AuthProviderUI] {
    providers
  }

  /// Starts sign-in with `provider` without rendering its button.
  ///
  /// ``AuthProviderAction`` providers run ``AuthProviderAction/triggerAction()`` and this
  /// returns its outcome. Other credential-based providers sign in through ``signIn(_:)``.
  /// Any other provider throws ``AuthServiceError/providerAuthenticationFailed(_:)``.
  public func triggerSignIn(for provider: AuthProviderUI) async throws -> SignInOutcome? {
    if let actionProvider = provider as? AuthProviderAction {
      return try await actionProvider.triggerAction()
    }
    if let credentialProvider = provider.provider as? CredentialAuthProviderSwift {
      return try await signIn(credentialProvider)
    }
    throw AuthServiceError.providerAuthenticationFailed(
      "\(provider.displayName) doesn't support starting sign-in programmatically. " +
        "Adopt AuthProviderAction on the provider, or start sign-in from its own button."
    )
  }

  /// Runs the email-link sign-in action, the same as the stock email-link button.
  func selectEmailLink() {
    if let callback = emailLinkSignInCallback {
      callback()
    } else {
      navigator.push(.emailLink)
    }
  }

  public func renderButtons(spacing: CGFloat = 16) -> AnyView {
    AnyView(
      VStack(spacing: spacing) {
        if emailLinkSignInEnabled {
          AuthProviderButton(
            label: string.signInWithEmailLinkViewTitle,
            style: .email,
            accessibilityId: "sign-in-with-email-link-button"
          ) {
            self.selectEmailLink()
          }
        }
        ForEach(providers, id: \.id) { provider in
          provider.authButton()
        }
      }
    )
  }

  public func renderLegacyRecoveryButtons(spacing: CGFloat = 16) -> AnyView {
    AnyView(
      VStack(spacing: spacing) {
        if let recovery = legacySignInRecovery {
          ForEach(recovery.options) { option in
            self.legacyRecoveryButton(for: option, email: recovery.email)
          }
        }
      }
    )
  }

  public func signIn(_ provider: CredentialAuthProviderSwift) async throws -> SignInOutcome {
    let credential = try await provider.createAuthCredential()
    let result = try await signIn(credentials: credential)
    return result
  }

  public func signOut() async throws {
    try auth.signOut()
    // Cannot wait for auth listener to change, feedback needs to be immediate
    currentUser = nil
    clearEmailLinkHandoff()
    // Clear email link sign-in flag
    isEmailLinkSignIn = false
    // Clear email link reauth state
    emailLinkReauth = nil
    isReauthenticating = false
    legacySignInRecovery = nil
    suggestedEmailAddress = nil
    navigator.clear()
    updateAuthenticationState()
  }

  public func linkAccounts(credentials: AuthCredential) async throws {
    authenticationState = .authenticating
    do {
      guard let user = currentUser else {
        throw AuthServiceError.noCurrentUser
      }

      try await user.link(with: credentials)
      updateAuthenticationState()
    } catch {
      authenticationState = .unauthenticated

      // Check for reauthentication errors first
      try await handleErrorWithReauthCheck(error: error)

      // If not a reauth error, check for conflicts
      // Possible conflicts from user.link():
      // - credentialAlreadyInUse: credential is already linked to another account
      // - emailAlreadyInUse: email from credential is already used by another account
      // - accountExistsWithDifferentCredential: account exists with different sign-in method
      try handleErrorWithConflictCheck(error: error, credential: credentials)
    }
  }

  public func signIn(credentials: AuthCredential) async throws -> SignInOutcome {
    authenticationState = .authenticating
    do {
      if shouldHandleAnonymousUpgrade {
        return try await handleAutoUpgradeAnonymousUser(credentials: credentials)
      } else {
        let result = try await auth.signIn(with: credentials)
        updateAuthenticationState()
        return .signedIn(result)
      }
    } catch let error as NSError {
      authenticationState = .unauthenticated

      // Check if this is an MFA required error
      if error.code == AuthErrorCode.secondFactorRequired.rawValue {
        if let resolver = error
          .userInfo[AuthErrorUserInfoMultiFactorResolverKey] as? MultiFactorResolver {
          return handleMFARequiredError(resolver: resolver)
        }
      }

      // Possible conflicts from auth.signIn(with:):
      // - accountExistsWithDifferentCredential: account exists with different provider
      // - credentialAlreadyInUse: credential is already linked to another account
      try handleErrorWithConflictCheck(error: error, credential: credentials)
    }
  }

  public func sendEmailVerification() async throws {
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
  }

  /// Reauthenticates with an OAuth provider (Google, Apple, Facebook, Twitter, etc.)
  /// - Parameter context: The reauth context from `oauthReauthenticationRequired` error
  /// - Throws: Error if reauthentication fails or provider is not found
  /// - Note: This only works for providers that can automatically obtain credentials.
  ///         For email/phone, handle the flow externally and use `reauthenticate(with:)`
  public func reauthenticate(context: OAuthReauthContext) async throws {
    guard let user = currentUser else {
      throw AuthServiceError.noCurrentUser
    }

    // Find the provider and get credential
    guard let matchingProvider = providers.first(where: { $0.id == context.providerId }),
          let credentialProvider = matchingProvider.provider as? CredentialAuthProviderSwift else {
      throw AuthServiceError.providerNotFound("No provider found for \(context.providerId)")
    }

    let credential = try await credentialProvider.createAuthCredential()
    try await user.reauthenticate(with: credential)
    currentUser = auth.currentUser
  }

  /// Reauthenticates with a pre-obtained credential
  /// Use this when you've handled getting the credential yourself (email/phone)
  /// - Parameter credential: The authentication credential to use for reauthentication
  /// - Throws: Error if reauthentication fails
  public func reauthenticate(with credential: AuthCredential) async throws {
    guard let user = currentUser else {
      throw AuthServiceError.noCurrentUser
    }
    try await user.reauthenticate(with: credential)
    currentUser = auth.currentUser
  }
}

// MARK: - User API

public extension AuthService {
  func deleteUser() async throws {
    guard let user = auth.currentUser else {
      throw AuthServiceError.noCurrentUser
    }

    do {
      try await user.delete()
    } catch {
      try await handleErrorWithReauthCheck(error: error)
      throw error // If we reach here, it wasn't a reauth error, so rethrow
    }
  }

  func updatePassword(to password: String) async throws {
    guard let user = auth.currentUser else {
      throw AuthServiceError.noCurrentUser
    }

    do {
      try await user.updatePassword(to: password)
    } catch {
      try await handleErrorWithReauthCheck(error: error)
      throw error // If we reach here, it wasn't a reauth error, so rethrow
    }
  }

  func updateUserPhotoURL(url: URL) async throws {
    guard let user = currentUser else {
      throw AuthServiceError.noCurrentUser
    }

    let changeRequest = user.createProfileChangeRequest()
    changeRequest.photoURL = url
    try await changeRequest.commitChanges()
  }

  func updateUserDisplayName(name: String) async throws {
    guard let user = currentUser else {
      throw AuthServiceError.noCurrentUser
    }

    try await saveDisplayName(name, to: user)
  }

  /// Saves a non-blank `name` as `user`'s display name, then republishes ``currentUser`` so
  /// views reading the name see it.
  internal func saveDisplayName(_ name: String?, to user: User) async throws {
    guard let name = name?.trimmingCharacters(in: .whitespacesAndNewlines),
          !name.isEmpty else { return }

    let changeRequest = user.createProfileChangeRequest()
    changeRequest.displayName = name
    try await changeRequest.commitChanges()
    currentUser = auth.currentUser
  }
}

// MARK: - Email/Password Sign In

public extension AuthService {
  /// Enables email and password sign-in, shown directly in `AuthPickerView`.
  ///
  /// - Parameters:
  ///   - requireDisplayName: Whether sign-up asks for a name and saves it as the new account's
  ///     display name. Defaults to `false`, so the stock form is unchanged unless you opt in;
  ///     the UIKit library and FirebaseUI-Android default to `true`.
  ///   - allowNewEmailAccounts: Whether users may create accounts. When `false`, the sign-up
  ///     switch is hidden and ``createUser(email:password:displayName:)`` throws
  ///     `AuthErrorCode.adminRestrictedOperation`, the error Firebase returns when a project
  ///     turns sign-up off. Defaults to `true`.
  func withEmailSignIn(requireDisplayName: Bool = false,
                       allowNewEmailAccounts: Bool = true) -> AuthService {
    emailPasswordSignInEnabled = true
    self.requireDisplayName = requireDisplayName
    self.allowNewEmailAccounts = allowNewEmailAccounts
    if !allowNewEmailAccounts {
      authenticationFlow = .signIn
    }
    return self
  }

  func signIn(email: String, password: String) async throws -> SignInOutcome {
    let credential = EmailAuthProvider.credential(withEmail: email, password: password)
    do {
      return try await signIn(credentials: credential)
    } catch {
      if await tryPresentLegacySignInRecovery(
        email: email,
        attemptedProviderId: EmailAuthProviderID
      ) {
        throw AuthServiceError.legacySignInRecoveryPresented
      }
      throw error
    }
  }

  /// Creates an email and password account, or links the credential to the signed-in anonymous
  /// user when anonymous upgrade is on, then saves `displayName` to the account's profile.
  ///
  /// - Parameters:
  ///   - displayName: The name to save as the account's display name. Ignored when `nil` or
  ///     blank.
  /// - Throws: `AuthErrorCode.adminRestrictedOperation` when
  ///   ``withEmailSignIn(requireDisplayName:allowNewEmailAccounts:)`` turned sign-up off.
  func createUser(email: String,
                  password: String,
                  displayName: String? = nil) async throws -> SignInOutcome {
    guard allowNewEmailAccounts else {
      throw NSError(
        domain: AuthErrorDomain,
        code: AuthErrorCode.adminRestrictedOperation.rawValue,
        userInfo: [NSLocalizedDescriptionKey: "Creating new accounts with email is turned off."]
      )
    }
    authenticationState = .authenticating
    let credential = EmailAuthProvider.credential(withEmail: email, password: password)

    let result: AuthDataResult?
    do {
      if shouldHandleAnonymousUpgrade {
        result = try await currentUser?.link(with: credential)
      } else {
        result = try await auth.createUser(withEmail: email, password: password)
      }
    } catch {
      // Possible conflicts from auth.createUser():
      // - emailAlreadyInUse: email is already registered with another account
      authenticationState = .unauthenticated
      try handleErrorWithConflictCheck(error: error, credential: credential)
    }

    // The account exists and is signed in now. Save the name before this method reports the
    // sign-in; the auth listener may report it first, and `saveDisplayName` republishes
    // `currentUser` so views reading the name update. A failure is reported without signing
    // out, as the UIKit library did.
    defer { updateAuthenticationState() }
    if let user = result?.user {
      try await saveDisplayName(displayName, to: user)
    }
    return .signedIn(result)
  }

  func sendPasswordRecoveryEmail(email: String) async throws {
    try await auth.sendPasswordReset(withEmail: email)
  }
}

// MARK: - Email Link Sign In

public extension AuthService {
  /// Enables email-link sign-in. Its button pushes ``AuthView/emailLink``.
  ///
  /// - Parameter forceSameDevice: Whether a link only works on the device that requested it.
  ///   When `false`, a link opened on another device asks the user to confirm their email
  ///   first. Defaults to `false`.
  func withEmailLinkSignIn(forceSameDevice: Bool = false) -> AuthService {
    _ = withEmailLinkSignIn(forceSameDevice: forceSameDevice) { [weak self] in
      self?.navigator.push(.emailLink)
    }
    emailLinkUsesLibraryScreen = true
    return self
  }

  /// Enables email-link sign-in with a custom action for its button.
  ///
  /// - Parameters:
  ///   - forceSameDevice: Whether a link only works on the device that requested it. Defaults
  ///     to `false`.
  ///   - onTap: Runs when the email-link button is tapped.
  func withEmailLinkSignIn(forceSameDevice: Bool = false,
                           onTap: @escaping () -> Void) -> AuthService {
    emailLinkSignInEnabled = true
    emailLinkForceSameDevice = forceSameDevice
    emailLinkSignInCallback = onTap
    emailLinkUsesLibraryScreen = false
    return self
  }

  /// Send email link for sign-in or reauthentication
  /// - Parameters:
  ///   - email: Email address to send link to
  ///   - isReauth: Whether this is for reauthentication (default: false)
  func sendEmailSignInLink(email: String, isReauth: Bool = false) async throws {
    let sessionID = isReauth ? nil : String(Int.random(in: 0 ... 999_999_999))
    let actionCodeSettings = try updateActionCodeSettings(sessionID: sessionID)
    try await auth.sendSignInLink(
      toEmail: email,
      actionCodeSettings: actionCodeSettings
    )

    // Store email based on context
    if isReauth {
      emailLinkReauth = email
      isReauthenticating = true
    } else {
      emailLink = email
      emailLinkSessionID = sessionID
      pendingEmailLink = nil
    }
  }

  /// Signs in with a sign-in link the app opened, or reauthenticates when
  /// ``sendEmailSignInLink(email:isReauth:)`` sent it for reauthentication.
  ///
  /// A link opened on a device that didn't request it throws
  /// ``AuthServiceError/invalidEmailLink(_:)`` as before, and also sets ``pendingEmailLink`` for
  /// ``confirmEmailLinkSignIn(email:)`` unless ``withEmailLinkSignIn(forceSameDevice:)`` is
  /// set. A link that is already being handled, or already signed in, is ignored.
  func handleSignInLink(url: URL) async throws {
    if isReauthenticating {
      try await handleEmailLinkReauthentication(url: url)
      return
    }

    guard url != emailLinkInFlight, url != lastSignedInEmailLink else { return }
    emailLinkInFlight = url
    defer { emailLinkInFlight = nil }

    let link = try Self.emailSignInLink(from: url)
    guard auth.isSignIn(withEmailLink: link) else { return }

    guard let continueURL = try Self.continueURL(from: url) else {
      throw AuthServiceError
        .invalidEmailLink("`continueUrl` parameter is missing from the email link URL")
    }
    let parameter = { CommonUtils.getQueryParamValue(from: continueURL, paramName: $0) }

    // A link without `ui_sid`, sent before it existed, counts as this device's only when this
    // device hasn't sent a link since.
    let linkSessionID = parameter("ui_sid")
    guard let email = emailLink, linkSessionID == emailLinkSessionID else {
      if parameter("ui_sd") == "1" {
        throw AuthServiceError.invalidEmailLink(string.emailLinkDifferentDeviceMessage)
      }
      pendingEmailLink = url
      throw AuthServiceError
        .invalidEmailLink("email address is missing from app storage. Is this the same device?")
    }

    try await signInWithEmailLink(email: email, link: link, anonymousUserID: parameter("ui_auid"))
    lastSignedInEmailLink = url
  }

  /// Finishes signing in with ``pendingEmailLink`` once the user confirms the email address the
  /// link was sent to. Never upgrades an anonymous user, since that user is on another device.
  func confirmEmailLinkSignIn(email: String) async throws {
    guard let url = pendingEmailLink else {
      throw AuthServiceError.invalidEmailLink("No sign-in link is waiting for confirmation")
    }
    let link = try Self.emailSignInLink(from: url)
    do {
      try await signInWithEmailLink(email: email, link: link, anonymousUserID: nil)
      lastSignedInEmailLink = url
    } catch {
      // A used or expired link can't succeed with any email, so stop asking for one.
      let code = AuthErrorCode(rawValue: (error as NSError).code)
      if code == .invalidActionCode || code == .expiredActionCode {
        pendingEmailLink = nil
      }
      throw error
    }
  }

  /// Drops ``pendingEmailLink`` so the email-link screen offers to send a new link instead of
  /// asking to confirm the email.
  func cancelEmailLinkConfirmation() {
    pendingEmailLink = nil
  }

  /// Forgets links waiting for the email-link screen, when the sheet closes or the user signs
  /// out.
  internal func clearEmailLinkHandoff() {
    pendingEmailLink = nil
    incomingEmailLink = nil
  }

  /// Hands a sign-in link the app opened to ``EmailLinkScreen``, presenting the sheet and pushing
  /// ``AuthView/emailLink`` when that screen isn't already showing to handle it itself. An app
  /// that shows its own screen through `withEmailLinkSignIn(onTap:)` handles links there.
  internal func presentEmailLinkScreen(for url: URL) {
    guard emailLinkSignInEnabled, emailLinkUsesLibraryScreen, !isReauthenticating,
          authenticationState != .authenticated,
          !(isPresented && authView == .emailLink),
          let link = try? Self.emailSignInLink(from: url),
          auth.isSignIn(withEmailLink: link) else { return }

    incomingEmailLink = url
    isPresented = true
    navigator.push(.emailLink)
  }

  private func signInWithEmailLink(email: String,
                                   link: String,
                                   anonymousUserID: String?) async throws {
    let credential = EmailAuthProvider.credential(withEmail: email, link: link)
    do {
      if let anonymousUserID, shouldHandleAnonymousUpgrade,
         anonymousUserID == currentUser?.uid {
        _ = try await handleAutoUpgradeAnonymousUser(credentials: credential)
      } else {
        _ = try await auth.signIn(withEmail: email, link: link)
      }
    } catch {
      // Possible conflicts from auth.signIn(withEmail:link:):
      // - accountExistsWithDifferentCredential: account exists with different provider
      // - credentialAlreadyInUse: credential is already linked to another account
      try handleErrorWithConflictCheck(error: error, credential: credential)
    }
    updateAuthenticationState()
    // Track that user signed in with email link
    isEmailLinkSignIn = true
    emailLink = nil
    emailLinkSessionID = nil
    pendingEmailLink = nil
  }

  private func handleEmailLinkReauthentication(url: URL) async throws {
    guard let email = emailLinkReauth else {
      throw AuthServiceError.invalidEmailLink("Email address is missing for reauthentication")
    }
    let link = try Self.emailSignInLink(from: url)
    guard auth.isSignIn(withEmailLink: link) else { return }

    try await reauthenticate(with: EmailAuthProvider.credential(withEmail: email, link: link))
    emailLinkReauth = nil
    isReauthenticating = false
  }

  /// The continue URL of the sign-in link inside a URL the app opened. Read before
  /// ``emailSignInLink(from:)`` decodes the link a second time, which would split the continue
  /// URL's own query items off onto the link.
  private static func continueURL(from url: URL) throws -> String? {
    guard let originalLink = CommonUtils.getQueryParamValue(
      from: url.absoluteString,
      paramName: "link"
    ) else {
      throw AuthServiceError
        .invalidEmailLink("'link' parameter is missing from the email link URL")
    }
    return CommonUtils.getQueryParamValue(from: originalLink, paramName: "continueUrl")
      ?? CommonUtils.getQueryParamValue(
        from: originalLink.removingPercentEncoding ?? originalLink,
        paramName: "continueUrl"
      )
  }

  /// The Firebase sign-in link inside the `link` query parameter of a URL the app opened.
  private static func emailSignInLink(from url: URL) throws -> String {
    guard let originalLink = CommonUtils.getQueryParamValue(
      from: url.absoluteString,
      paramName: "link"
    ) else {
      throw AuthServiceError
        .invalidEmailLink("'link' parameter is missing from the email link URL")
    }
    guard let link = originalLink.removingPercentEncoding else {
      throw AuthServiceError.invalidEmailLink("Failed to decode Link URL")
    }
    return link
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
    _ = try await signIn(credentials: credential)
  }
}

// MARK: - MFA Methods

public extension AuthService {
  func startMfaEnrollment(type: SecondFactorType, accountName: String? = nil,
                          issuer: String? = nil) async throws -> EnrollmentSession {
    guard let user = auth.currentUser else {
      throw AuthServiceError.noCurrentUser
    }

    // Check if MFA is enabled in configuration
    guard configuration.mfaEnabled else {
      throw AuthServiceError
        .multiFactorAuth(
          "MFA is not enabled in configuration, please enable `AuthConfiguration.mfaEnabled`"
        )
    }

    // Check if the requested factor type is allowed
    guard configuration.allowedSecondFactors.contains(type) else {
      throw AuthServiceError
        .multiFactorAuth(
          "The requested MFA factor type '\(type)' is not allowed in AuthConfiguration.allowedSecondFactors"
        )
    }

    let multiFactorUser = user.multiFactor

    // Get the multi-factor session
    let session = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<
      MultiFactorSession,
      Error
    >) in
      multiFactorUser.getSessionWithCompletion { session, error in
        if let error = error {
          continuation.resume(throwing: error)
        } else if let session = session {
          continuation.resume(returning: session)
        } else {
          continuation
            .resume(throwing: AuthServiceError
              .multiFactorAuth("Failed to get MFA session for '\(type)'"))
        }
      }
    }

    switch type {
    case .sms:
      // For SMS, we just return the session - phone number will be provided in
      // sendSmsVerificationForEnrollment
      return EnrollmentSession(
        type: .sms,
        session: session,
        status: .initiated
      )

    case .totp:
      // For TOTP, generate the secret and QR code
      let totpSecret = try await TOTPMultiFactorGenerator.generateSecret(with: session)

      // Generate QR code URL
      let resolvedAccountName = accountName ?? user.email ?? "User"
      let resolvedIssuer = issuer ?? configuration.mfaIssuer

      let qrCodeURL = totpSecret.generateQRCodeURL(
        withAccountName: resolvedAccountName,
        issuer: resolvedIssuer
      )

      let totpInfo = TOTPEnrollmentInfo(
        sharedSecretKey: totpSecret.sharedSecretKey(),
        qrCodeURL: URL(string: qrCodeURL),
        accountName: resolvedAccountName,
        issuer: resolvedIssuer,
        verificationStatus: .pending
      )

      return EnrollmentSession(
        type: .totp,
        session: session,
        totpInfo: totpInfo,
        status: .initiated,
        _totpSecret: totpSecret
      )
    }
  }

  func sendSmsVerificationForEnrollment(session: EnrollmentSession,
                                        phoneNumber: String) async throws -> String {
    // Validate session
    guard session.type == .sms else {
      throw AuthServiceError.multiFactorAuth("Session is not configured for SMS enrollment")
    }

    guard session.canProceed else {
      if session.isExpired {
        throw AuthServiceError.multiFactorAuth("Enrollment session has expired")
      } else {
        throw AuthServiceError
          .multiFactorAuth("Session is not in a valid state for SMS verification")
      }
    }

    // Validate phone number format
    guard !phoneNumber.isEmpty else {
      throw AuthServiceError.multiFactorAuth("Phone number cannot be empty for SMS enrollment")
    }

    // Send SMS verification using Firebase Auth PhoneAuthProvider
    let verificationID =
      try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<
        String,
        Error
      >) in
        PhoneAuthProvider.provider().verifyPhoneNumber(
          phoneNumber,
          uiDelegate: nil,
          multiFactorSession: session.session
        ) { verificationID, error in
          if let error = error {
            continuation.resume(throwing: error)
          } else if let verificationID = verificationID {
            continuation.resume(returning: verificationID)
          } else {
            continuation
              .resume(throwing: AuthServiceError
                .multiFactorAuth("Failed to send SMS verification code to verify phone number"))
          }
        }
      }

    return verificationID
  }

  func resolveSignIn(code: String, hintIndex: Int, verificationId: String? = nil) async throws {
    guard let resolver = currentMFAResolver else {
      throw AuthServiceError.multiFactorAuth("No MFA resolver available")
    }

    guard hintIndex < resolver.hints.count else {
      throw AuthServiceError.multiFactorAuth("Invalid hint index")
    }

    let hint = resolver.hints[hintIndex]
    let assertion: MultiFactorAssertion

    // Create the appropriate assertion based on the hint type
    if hint.factorID == PhoneMultiFactorID {
      guard let verificationId = verificationId else {
        throw AuthServiceError.multiFactorAuth("Verification ID is required for SMS MFA")
      }

      let credential = PhoneAuthProvider.provider().credential(
        withVerificationID: verificationId,
        verificationCode: code
      )
      assertion = PhoneMultiFactorGenerator.assertion(with: credential)

    } else if hint.factorID == TOTPMultiFactorID {
      assertion = TOTPMultiFactorGenerator.assertionForSignIn(
        withEnrollmentID: hint.uid,
        oneTimePassword: code
      )

    } else {
      throw AuthServiceError.multiFactorAuth("Unsupported MFA hint type")
    }

    do {
      _ = try await resolver.resolveSignIn(with: assertion)
      updateAuthenticationState()

      // Clear MFA resolution state
      currentMFAResolver = nil

    } catch {
      throw AuthServiceError
        .multiFactorAuth("Failed to resolve MFA challenge: \(error.localizedDescription)")
    }
  }

  func completeEnrollment(session: EnrollmentSession, verificationId: String?,
                          verificationCode: String, displayName: String) async throws {
    // Validate session state
    guard session.canProceed else {
      if session.isExpired {
        throw AuthServiceError
          .multiFactorAuth("Enrollment session has expired, cannot complete enrollment")
      } else {
        throw AuthServiceError
          .multiFactorAuth("Enrollment session is not in a valid state for completion")
      }
    }

    // Validate verification code
    guard !verificationCode.isEmpty else {
      throw AuthServiceError.multiFactorAuth("Verification code cannot be empty")
    }

    guard let user = auth.currentUser else {
      throw AuthServiceError.noCurrentUser
    }

    // Create the appropriate assertion based on factor type
    let assertion: MultiFactorAssertion

    switch session.type {
    case .sms:
      // For SMS, we need the verification ID
      guard let verificationId = verificationId else {
        throw AuthServiceError
          .multiFactorAuth("Verification ID is required for SMS enrollment")
      }

      // Create phone credential and assertion
      let credential = PhoneAuthProvider.provider().credential(
        withVerificationID: verificationId,
        verificationCode: verificationCode
      )
      assertion = PhoneMultiFactorGenerator.assertion(with: credential)

    case .totp:
      // For TOTP, we need the secret from the session
      guard session.totpInfo != nil else {
        throw AuthServiceError
          .multiFactorAuth("TOTP info is missing from enrollment session")
      }

      // Use the stored TOTP secret from the enrollment session
      guard let secret = session._totpSecret else {
        throw AuthServiceError
          .multiFactorAuth("TOTP secret is missing from enrollment session")
      }

      // The concrete type is FirebaseAuth.TOTPSecret (kept as AnyObject to avoid exposing it)
      guard let totpSecret = secret as? TOTPSecret else {
        throw AuthServiceError
          .multiFactorAuth("Invalid TOTP secret type in enrollment session")
      }

      assertion = TOTPMultiFactorGenerator.assertionForEnrollment(
        with: totpSecret,
        oneTimePassword: verificationCode
      )
    }

    // Complete the enrollment
    do {
      try await user.multiFactor.enroll(with: assertion, displayName: displayName)
      currentUser = auth.currentUser
    } catch {
      try await handleErrorWithReauthCheck(error: error)
      throw error // If we reach here, it wasn't a reauth error, so rethrow
    }
  }

  func unenrollMFA(_ factorUid: String) async throws -> [MultiFactorInfo] {
    guard let user = auth.currentUser else {
      throw AuthServiceError.noCurrentUser
    }

    let multiFactorUser = user.multiFactor

    do {
      try await multiFactorUser.unenroll(withFactorUID: factorUid)

      // This is the only we to get the actual latest enrolledFactors
      currentUser = Auth.auth().currentUser
      let freshFactors = currentUser?.multiFactor.enrolledFactors ?? []

      return freshFactors
    } catch {
      try await handleErrorWithReauthCheck(error: error)
      throw error // If we reach here, it wasn't a reauth error, so rethrow
    }
  }

  func resolveSmsChallenge(hintIndex: Int) async throws -> String {
    guard let resolver = currentMFAResolver else {
      throw AuthServiceError.multiFactorAuth("No MFA resolver available")
    }

    guard hintIndex < resolver.hints.count else {
      throw AuthServiceError.multiFactorAuth("Invalid hint index")
    }

    let hint = resolver.hints[hintIndex]
    guard hint.factorID == PhoneMultiFactorID else {
      throw AuthServiceError.multiFactorAuth("Selected hint is not a phone hint")
    }
    let phoneHint = hint as! PhoneMultiFactorInfo

    return try await withCheckedThrowingContinuation { continuation in
      PhoneAuthProvider.provider().verifyPhoneNumber(
        with: phoneHint,
        uiDelegate: nil,
        multiFactorSession: resolver.session
      ) { verificationId, error in
        if let error = error {
          continuation
            .resume(throwing: AuthServiceError.multiFactorAuth(error.localizedDescription))
        } else if let verificationId = verificationId {
          continuation.resume(returning: verificationId)
        } else {
          continuation
            .resume(throwing: AuthServiceError.multiFactorAuth("Unknown error occurred"))
        }
      }
    }
  }
}

// MARK: - Internal Helper Methods

extension AuthService {
  func updateAuthenticationState() {
    authenticationState =
      (currentUser == nil || currentUser?.isAnonymous == true)
        ? .unauthenticated
        : .authenticated

    if authenticationState == .authenticated {
      legacySignInRecovery = nil
    }
  }
}

// MARK: - Private Helper Methods

private extension AuthService {
  var shouldHandleAnonymousUpgrade: Bool {
    currentUser?.isAnonymous == true && configuration.shouldAutoUpgradeAnonymousUsers
  }

  private func handleAutoUpgradeAnonymousUser(credentials: AuthCredential) async throws
    -> SignInOutcome {
    if currentUser == nil {
      throw AuthServiceError.noCurrentUser
    }
    do {
      let result = try await currentUser?.link(with: credentials)
      updateAuthenticationState()
      return .signedIn(result)
    } catch {
      throw error
    }
  }

  // MARK: - Action Code Settings Helper Methods

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

  /// The continue-URL query items the library writes on email sign-in links.
  static let emailLinkQueryItemNames: Set<String> = ["ui_auid", "ui_sid", "ui_sd"]

  private func updateActionCodeSettings(sessionID: String?) throws -> ActionCodeSettings {
    let actionCodeSettings = try safeActionCodeSettings()
    guard var urlComponents = URLComponents(string: actionCodeSettings.url!.absoluteString) else {
      throw AuthServiceError
        .notConfiguredActionCodeSettings(
          "ActionCodeSettings.url has not been configured for `AuthConfiguration.emailLinkSignInActionCodeSettings`"
        )
    }

    // Keep the app's own query items. The configured settings object is reused for every
    // link, so drop the items an earlier link added before adding this link's.
    var queryItems = (urlComponents.queryItems ?? []).filter {
      !Self.emailLinkQueryItemNames.contains($0.name)
    }

    if shouldHandleAnonymousUpgrade {
      if let currentUser = currentUser {
        let anonymousUID = currentUser.uid
        let auidItem = URLQueryItem(name: "ui_auid", value: anonymousUID)
        queryItems.append(auidItem)
      }
    }

    // Lets the device that opens the link tell whether it sent it, as the UIKit library did.
    if let sessionID {
      queryItems.append(URLQueryItem(name: "ui_sid", value: sessionID))
      queryItems.append(URLQueryItem(name: "ui_sd", value: emailLinkForceSameDevice ? "1" : "0"))
    }

    urlComponents.queryItems = queryItems.isEmpty ? nil : queryItems
    if let finalURL = urlComponents.url {
      actionCodeSettings.url = finalURL
    }

    return actionCodeSettings
  }

  // MARK: - Reauth Error Helper Methods

  /// Checks if an error requires reauthentication and handles it appropriately
  /// - Parameter error: The error to check
  /// - Throws: Only if it's a reauthentication error (via requireReauthentication())
  private func handleErrorWithReauthCheck(error: Error) async throws {
    if let nsError = error as NSError?,
       nsError.domain == AuthErrorDomain,
       nsError.code == AuthErrorCode.requiresRecentLogin.rawValue ||
       nsError.code == AuthErrorCode.userTokenExpired.rawValue {
      try await requireReauthentication()
    }
    // If not a reauth error, return normally so caller can handle it
  }

  /// Internal helper to create reauth context and throw appropriate error
  /// - Throws: Appropriate `AuthServiceError` based on the provider type
  private func requireReauthentication() async throws -> Never {
    let providerId = try await getCurrentSignInProvider()

    // Try to find display name from registered provider
    let providerDisplayName: String
    if let registeredProvider = providers.first(where: { $0.id == providerId }) {
      providerDisplayName = registeredProvider.displayName
    } else {
      // Fallback for built-in providers (email/password) that don't have AuthProviderUI
      providerDisplayName = getProviderDisplayName(providerId)
    }

    switch providerId {
    case EmailAuthProviderID:
      guard let email = currentUser?.email else {
        throw AuthServiceError.noCurrentUser
      }
      // Check if user signed in with email link or password
      if isEmailLinkSignIn {
        let context = EmailLinkReauthContext(email: email)
        throw AuthServiceError.emailLinkReauthenticationRequired(context: context)
      } else {
        let context = EmailReauthContext(email: email)
        throw AuthServiceError.emailReauthenticationRequired(context: context)
      }
    case PhoneAuthProviderID:
      guard let phoneNumber = currentUser?.phoneNumber else {
        throw AuthServiceError.noCurrentUser
      }
      let context = PhoneReauthContext(phoneNumber: phoneNumber)
      throw AuthServiceError.phoneReauthenticationRequired(context: context)
    default:
      let context = OAuthReauthContext(providerId: providerId, providerName: providerDisplayName)
      throw AuthServiceError.oauthReauthenticationRequired(context: context)
    }
  }

  /// Gets the provider ID that was used for the current sign-in session
  private func getCurrentSignInProvider() async throws -> String {
    guard let user = currentUser else {
      throw AuthServiceError.noCurrentUser
    }

    // Get the ID token result which contains the signInProvider claim
    let tokenResult = try await user.getIDTokenResult(forcingRefresh: false)

    // The signInProvider property tells us which provider was used for this session
    let signInProvider = tokenResult.signInProvider

    // If signInProvider is not empty, use it
    if !signInProvider.isEmpty {
      return signInProvider
    }

    // Fallback: if signInProvider is empty, try to infer from providerData
    // Prefer non-password providers as they're more specific
    let providerId = user.providerData.first(where: { $0.providerID != "password" })?.providerID
      ?? user.providerData.first?.providerID

    guard let providerId = providerId else {
      throw AuthServiceError.invalidCredentials(
        "Unable to determine sign-in provider for reauthentication"
      )
    }

    return providerId
  }

  /// Get a user-friendly display name for built-in providers without AuthProviderUI
  /// (email/password). Other providers should be registered and provide their own display names.
  /// - Parameter providerId: The provider ID from Firebase Auth
  /// - Returns: A user-friendly name for the provider
  private func getProviderDisplayName(_ providerId: String) -> String {
    switch providerId {
    case EmailAuthProviderID:
      return "Email"
    case PhoneAuthProviderID:
      return "Phone"
    case emailLinkSignInMethod:
      return "Email Link"
    default:
      // Shouldn't reach here if provider is registered
      return providerId
    }
  }

  private func normalizeLegacyOptionId(_ providerId: String) -> String {
    switch providerId {
    case PhoneAuthProviderID:
      return "phone"
    default:
      return providerId
    }
  }

  private func buildLegacySignInRecovery(email: String,
                                         signInMethods: [String],
                                         attemptedProviderId: String?)
    -> LegacySignInRecoveryContext? {
    let attemptedOptionId = attemptedProviderId.map(normalizeLegacyOptionId)
    var options: [LegacySignInOption] = []
    var unavailableProviders: [String] = []

    for method in signInMethods {
      if let option = resolveLegacyOption(for: method) {
        if !options.contains(where: { $0.id == option.id }) {
          options.append(option)
        }
      } else {
        unavailableProviders.append(getProviderDisplayName(method))
      }
    }

    guard !options.isEmpty else {
      return nil
    }

    if let attemptedOptionId,
       options.count == 1,
       options.first?.id == attemptedOptionId {
      return nil
    }

    return LegacySignInRecoveryContext(
      email: email,
      options: options,
      unavailableProviders: unavailableProviders
    )
  }

  private func resolveLegacyOption(for signInMethod: String) -> LegacySignInOption? {
    switch signInMethod {
    case EmailAuthProviderID:
      guard emailPasswordSignInEnabled else { return nil }
      return LegacySignInOption(
        id: EmailAuthProviderID,
        displayName: string.legacyEmailPasswordOptionLabel
      )
    case emailLinkSignInMethod:
      guard emailLinkSignInEnabled else { return nil }
      return LegacySignInOption(
        id: emailLinkSignInMethod,
        displayName: string.legacyEmailLinkOptionLabel
      )
    default:
      guard let provider = providers.first(where: {
        $0.id == normalizeLegacyOptionId(signInMethod)
      }) else {
        return nil
      }
      return LegacySignInOption(id: provider.id, displayName: provider.displayName)
    }
  }
}

extension AuthService {
  @discardableResult
  func tryPresentLegacySignInRecovery(email: String?,
                                      attemptedProviderId: String?) async -> Bool {
    guard configuration.legacyFetchSignInWithEmail,
          let email,
          !email.isEmpty else {
      return false
    }

    do {
      let signInMethods = try await auth.fetchSignInMethods(forEmail: email)
      guard let recovery = buildLegacySignInRecovery(
        email: email,
        signInMethods: signInMethods,
        attemptedProviderId: attemptedProviderId
      ) else {
        return false
      }
      legacySignInRecovery = recovery
      return true
    } catch {
      return false
    }
  }

  func dismissLegacySignInRecovery() {
    legacySignInRecovery = nil
  }

  func startLegacyRecovery(option: LegacySignInOption, email: String) {
    suggestedEmailAddress = email
    dismissLegacySignInRecovery()
    authenticationFlow = .signIn

    switch option.id {
    case EmailAuthProviderID:
      // An app whose first screen has no email form reached email sign-in through a pushed
      // route, so return to that screen for the suggested address.
      let usedEmailRoute = navigator.routes.contains { $0 == .signIn || $0 == .signUp }
      navigator.clear()
      if usedEmailRoute {
        navigator.push(.signIn)
      }
    case emailLinkSignInMethod:
      navigator.clear()
      navigator.push(.emailLink)
    case "phone":
      navigator.clear()
      navigator.push(.enterPhoneNumber)
    default:
      break
    }
  }

  @ViewBuilder
  private func legacyRecoveryButton(for option: LegacySignInOption,
                                    email: String) -> some View {
    switch option.id {
    case EmailAuthProviderID:
      AuthProviderButton(
        label: option.displayName,
        style: .email,
        accessibilityId: "legacy-sign-in-with-email-button"
      ) {
        self.startLegacyRecovery(option: option, email: email)
      }
    case emailLinkSignInMethod:
      AuthProviderButton(
        label: option.displayName,
        style: .email,
        accessibilityId: "legacy-sign-in-with-email-link-button"
      ) {
        self.startLegacyRecovery(option: option, email: email)
      }
    case "phone":
      AuthProviderButton(
        label: option.displayName,
        style: .phone,
        accessibilityId: "legacy-sign-in-with-phone-button"
      ) {
        self.startLegacyRecovery(option: option, email: email)
      }
    default:
      if let provider = providers.first(where: { $0.id == option.id }) {
        provider.authButton()
      }
    }
  }
}

private extension AuthService {
  // MARK: - Account Conflict Helper Methods

  private func determineConflictType(from error: NSError) -> AccountConflictType? {
    switch error.code {
    case AuthErrorCode.accountExistsWithDifferentCredential.rawValue:
      return shouldHandleAnonymousUpgrade ? .anonymousUpgradeConflict :
        .accountExistsWithDifferentCredential
    case AuthErrorCode.credentialAlreadyInUse.rawValue:
      return shouldHandleAnonymousUpgrade ? .anonymousUpgradeConflict : .credentialAlreadyInUse
    case AuthErrorCode.emailAlreadyInUse.rawValue:
      return shouldHandleAnonymousUpgrade ? .anonymousUpgradeConflict : .emailAlreadyInUse
    default:
      return nil
    }
  }

  private func createConflictContext(from error: NSError,
                                     conflictType: AccountConflictType,
                                     credential: AuthCredential) -> AccountConflictContext {
    let updatedCredential = error
      .userInfo[AuthErrorUserInfoUpdatedCredentialKey] as? AuthCredential ?? credential
    let email = error.userInfo[AuthErrorUserInfoEmailKey] as? String

    return AccountConflictContext(
      conflictType: conflictType,
      credential: updatedCredential,
      underlyingError: error,
      message: string.localizedErrorMessage(for: error),
      email: email
    )
  }

  /// Handles account conflict errors by creating context and throwing structured error
  /// - Parameters:
  ///   - error: The error to check and handle
  ///   - credential: The credential that caused the conflict
  /// - Throws: AuthServiceError.accountConflict if it's a conflict error, otherwise rethrows the
  /// original error
  private func handleErrorWithConflictCheck(error: Error,
                                            credential: AuthCredential) throws -> Never {
    // Check for account conflict errors
    if let error = error as NSError?,
       let conflictType = determineConflictType(from: error) {
      let context = createConflictContext(
        from: error,
        conflictType: conflictType,
        credential: credential
      )

      throw AuthServiceError.accountConflict(context)
    } else {
      throw error
    }
  }

  // MARK: - MFA Helper Methods

  private func extractMFAHints(from resolver: MultiFactorResolver) -> [MFAHint] {
    return resolver.hints.map { hint -> MFAHint in
      if hint.factorID == PhoneMultiFactorID {
        let phoneHint = hint as! PhoneMultiFactorInfo
        return .phone(
          displayName: phoneHint.displayName,
          uid: phoneHint.uid,
          phoneNumber: phoneHint.phoneNumber
        )
      } else if hint.factorID == TOTPMultiFactorID {
        return .totp(
          displayName: hint.displayName,
          uid: hint.uid
        )
      } else {
        // Fallback for unknown hint types
        return .totp(displayName: hint.displayName, uid: hint.uid)
      }
    }
  }

  private func handleMFARequiredError(resolver: MultiFactorResolver) -> SignInOutcome {
    let hints = extractMFAHints(from: resolver)
    currentMFAResolver = resolver
    return .mfaRequired(MFARequired(hints: hints))
  }
}
