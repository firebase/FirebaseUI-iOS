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
  func defaultAuthConfigurationInjection() async throws {
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
  func customAuthConfigurationInjection() async throws {
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
  func createEmailPasswordUser() async throws {
    let service = try await prepareFreshAuthService()

    #expect(service.authenticationState == .unauthenticated)
    #expect(service.authView == nil)
    #expect(service.currentUser == nil)
    try await service.createUser(email: createEmail(), password: kPassword)

    try await waitForStateChange {
      service.authenticationState == .authenticated
    }
    #expect(service.authenticationState == .authenticated)

    try await waitForStateChange {
      service.currentUser != nil
    }
    #expect(service.currentUser != nil)
    #expect(service.authView == nil)
  }

  @Test
  @MainActor
  func signInUser() async throws {
    let service = try await prepareFreshAuthService()
    let email = createEmail()
    try await service.createUser(email: email, password: kPassword)
    try await service.signOut()

    try await waitForStateChange {
      service.authenticationState == .unauthenticated
    }
    #expect(service.authenticationState == .unauthenticated)

    try await waitForStateChange {
      service.currentUser == nil
    }
    #expect(service.currentUser == nil)
    #expect(service.authView == nil)

    try await service.signIn(email: email, password: kPassword)

    try await waitForStateChange {
      service.authenticationState == .authenticated
    }
    #expect(service.authenticationState == .authenticated)

    try await waitForStateChange {
      service.currentUser != nil
    }
    #expect(service.currentUser != nil)
    #expect(service.authView == nil)
  }
}
