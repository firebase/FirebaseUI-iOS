//
//  FirebaseSwiftUIExampleTests.swift
//  FirebaseSwiftUIExampleTests
//
//  Created by Russell Wheatley on 18/02/2025.
//
import FirebaseAuth
import FirebaseAuthSwiftUI
import FirebaseCore
@testable import FirebaseSwiftUIExample
import Testing

let kPassword = "123456"

struct FirebaseSwiftUIExampleTests {
  @MainActor
  func prepareFreshAuthService(configuration: AuthConfiguration? = nil) async throws
    -> AuthService {
    configureFirebaseIfNeeded()
    try await clearAuthEmulatorState()

    let resolvedConfiguration = configuration ?? AuthConfiguration()

    return AuthService(configuration: resolvedConfiguration)
  }

  @Test
  @MainActor
  func testDefaultAuthConfigurationInjection() async throws {
    let config = AuthConfiguration()
    let service = AuthService(configuration: config)

    let actual = service.configuration

    #expect(actual.shouldHideCancelButton == false)
    #expect(actual.interactiveDismissEnabled == true)
    #expect(actual.shouldAutoUpgradeAnonymousUsers == false)
    #expect(actual.customStringsBundle == nil)
    #expect(actual.tosUrl == nil)
    #expect(actual.privacyPolicyUrl == nil)
    #expect(actual.emailLinkSignInActionCodeSettings == nil)
    #expect(actual.verifyEmailActionCodeSettings == nil)
  }

  @Test
  @MainActor
  func testCustomAuthConfigurationInjection() async throws {
    let emailSettings = ActionCodeSettings()
    emailSettings.handleCodeInApp = true
    emailSettings.url = URL(string: "https://example.com/email-link")
    emailSettings.setIOSBundleID("com.example.test")

    let verifySettings = ActionCodeSettings()
    verifySettings.handleCodeInApp = true
    verifySettings.url = URL(string: "https://example.com/verify-email")
    verifySettings.setIOSBundleID("com.example.test")

    let config = AuthConfiguration(
      shouldHideCancelButton: true,
      interactiveDismissEnabled: false,
      shouldAutoUpgradeAnonymousUsers: true,
      customStringsBundle: .main,
      tosUrl: URL(string: "https://example.com/tos"),
      privacyPolicyUrl: URL(string: "https://example.com/privacy"),
      emailLinkSignInActionCodeSettings: emailSettings,
      verifyEmailActionCodeSettings: verifySettings
    )

    let service = AuthService(configuration: config)

    let actual = service.configuration
    #expect(actual.shouldHideCancelButton == true)
    #expect(actual.interactiveDismissEnabled == false)
    #expect(actual.shouldAutoUpgradeAnonymousUsers == true)
    #expect(actual.customStringsBundle === Bundle.main)
    #expect(actual.tosUrl == URL(string: "https://example.com/tos"))
    #expect(actual.privacyPolicyUrl == URL(string: "https://example.com/privacy"))

    // Optional action code settings checks
    #expect(actual.emailLinkSignInActionCodeSettings?.url == emailSettings.url)
    #expect(actual.verifyEmailActionCodeSettings?.url == verifySettings.url)
  }

  @Test
  @MainActor
  func testCreateEmailPasswordUser() async throws {
    let service = try await prepareFreshAuthService()

    #expect(service.authenticationState == .unauthenticated)
    #expect(service.authView == .authPicker)
    #expect(service.errorMessage.isEmpty)
    #expect(service.signedInCredential == nil)
    #expect(service.currentUser == nil)
    try await service.createUser(withEmail: createEmail(), password: kPassword)
    try await Task.sleep(nanoseconds: 4_000_000_000)
    #expect(service.authenticationState == .authenticated)
    #expect(service.authView == .authPicker)
    #expect(service.errorMessage.isEmpty)
    #expect(service.currentUser != nil)
    // TODO: - reinstate once this PR is merged: https://github.com/firebase/FirebaseUI-iOS/pull/1256
//    #expect(service.signedInCredential is AuthCredential)
  }

  @Test
  @MainActor
  func testSignInUser() async throws {
    let service = try await prepareFreshAuthService()
    let email = createEmail()
    try await service.createUser(withEmail: email, password: kPassword)
    try await service.signOut()
    try await Task.sleep(nanoseconds: 2_000_000_000)
    #expect(service.authenticationState == .unauthenticated)
    #expect(service.authView == .authPicker)
    #expect(service.errorMessage.isEmpty)
    #expect(service.signedInCredential == nil)
    #expect(service.currentUser == nil)

    try await service.signIn(withEmail: email, password: kPassword)

    #expect(service.authenticationState == .authenticated)
    #expect(service.authView == .authPicker)
    #expect(service.errorMessage.isEmpty)
    #expect(service.currentUser != nil)
    // TODO: - reinstate once this PR is merged: https://github.com/firebase/FirebaseUI-iOS/pull/1256
    //    #expect(service.signedInCredential is AuthCredential)
  }
}
