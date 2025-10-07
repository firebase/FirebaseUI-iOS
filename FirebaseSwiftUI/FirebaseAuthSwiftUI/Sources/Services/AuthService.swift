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
  case mfaEnrollment
  case mfaManagement
  case mfaResolution
}

public enum SignInOutcome: @unchecked Sendable {
  case mfaRequired(MFARequired)
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
  public var currentMFARequired: MFARequired?
  private var currentMFAResolver: MultiFactorResolver?

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
      signedInCredential = credentials
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
    }  catch let error as NSError {
      authenticationState = .unauthenticated
      errorMessage = string.localizedErrorMessage(for: error)

      // Check if this is an MFA required error
      if error.code == AuthErrorCode.secondFactorRequired.rawValue {
        if let resolver = error
          .userInfo[AuthErrorUserInfoMultiFactorResolverKey] as? MultiFactorResolver {
          return handleMFARequiredError(resolver: resolver)
        }
      }

      throw error
    }
  }

  public func sendEmailVerification() async throws {
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

  func signIn(email: String, password: String) async throws -> SignInOutcome {
    let credential = EmailAuthProvider.credential(withEmail: email, password: password)
    return try await signIn(credentials: credential)
  }

  func createUser(email email: String, password: String) async throws -> SignInOutcome {
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

  func sendPasswordRecoveryEmail(email: String) async throws {
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
  func sendEmailSignInLink(email: String) async throws {
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

// MARK: - User Profile Management

public extension AuthService {
  func updateUserPhotoURL(url: URL) async throws {
    guard let user = currentUser else {
      throw AuthServiceError.noCurrentUser
    }
    
    do {
      let changeRequest = user.createProfileChangeRequest()
      changeRequest.photoURL = url
      try await changeRequest.commitChanges()
    } catch {
      errorMessage = string.localizedErrorMessage(for: error)
      throw error
    }
  }
  
  func updateUserDisplayName(name: String) async throws {
    guard let user = currentUser else {
      throw AuthServiceError.noCurrentUser
    }
    
    do {
      let changeRequest = user.createProfileChangeRequest()
      changeRequest.displayName = name
      try await changeRequest.commitChanges()
    } catch {
      errorMessage = string.localizedErrorMessage(for: error)
      throw error
    }
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
      throw AuthServiceError.multiFactorAuth("MFA is not enabled in configuration, please enable `AuthConfiguration.mfaEnabled`")
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
          continuation.resume(throwing: AuthServiceError.multiFactorAuth("Failed to get MFA session for '\(type)'"))
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

  func completeEnrollment(session: EnrollmentSession, verificationId: String?,
                          verificationCode: String, displayName: String) async throws {
    // Validate session state
    guard session.canProceed else {
      if session.isExpired {
        throw AuthServiceError.multiFactorAuth("Enrollment session has expired, cannot complete enrollment")
      } else {
        throw AuthServiceError.multiFactorAuth("Enrollment session is not in a valid state for completion")
      }
    }

    // Validate verification code
    guard !verificationCode.isEmpty else {
      throw AuthServiceError.multiFactorAuth("Verification code cannot be empty")
    }

    guard let user = auth.currentUser else {
      throw AuthServiceError.noCurrentUser
    }

    let multiFactorUser = user.multiFactor

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
      guard let totpInfo = session.totpInfo else {
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
    try await user.multiFactor.enroll(with: assertion, displayName: displayName)
    currentUser = auth.currentUser
  }

  func reauthenticateCurrentUser(on user: User) async throws {
    if let providerId = signedInCredential?.provider {
      if providerId == EmailAuthProviderID {
        guard let email = user.email else {
          throw AuthServiceError.invalidCredentials("User does not have an email address")
        }
        let password = try await passwordPrompt.confirmPassword()
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        try await user.reauthenticate(with: credential)
      } else if let matchingProvider = providers.first(where: { $0.id == providerId }) {
        let credential = try await matchingProvider.provider.createAuthCredential()
        try await user.reauthenticate(with: credential)
      } else {
        throw AuthServiceError.providerNotFound("No provider found for \(providerId)")
      }
    } else {
      throw AuthServiceError
        .reauthenticationRequired("Recent login required to perform this operation.")
    }
  }

  func unenrollMFA(_ factorUid: String) async throws -> [MultiFactorInfo] {
    guard let user = auth.currentUser else {
      throw AuthServiceError.noCurrentUser
    }

    let multiFactorUser = user.multiFactor

    do {
      try await multiFactorUser.unenroll(withFactorUID: factorUid)
    } catch let error as NSError {
      if error.domain == AuthErrorDomain,
         error.code == AuthErrorCode.requiresRecentLogin.rawValue || error.code == AuthErrorCode
         .userTokenExpired.rawValue {
        try await reauthenticateCurrentUser(on: user)
        try await multiFactorUser.unenroll(withFactorUID: factorUid)
      } else {
        throw AuthServiceError
          .multiFactorAuth(
            "Invalid second factor: \(error.localizedDescription)"
          )
      }
    }

    // This is the only we to get the actual latest enrolledFactors
    currentUser = Auth.auth().currentUser
    let freshFactors = currentUser?.multiFactor.enrolledFactors ?? []

    return freshFactors
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
    currentMFARequired = MFARequired(hints: hints)
    currentMFAResolver = resolver
    authView = .mfaResolution
    return .mfaRequired(MFARequired(hints: hints))
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
      let result = try await resolver.resolveSignIn(with: assertion)
      signedInCredential = result.credential
      updateAuthenticationState()

      // Clear MFA resolution state
      currentMFARequired = nil
      currentMFAResolver = nil

    } catch {
      throw AuthServiceError
        .multiFactorAuth("Failed to resolve MFA challenge: \(error.localizedDescription)")
    }
  }
}
