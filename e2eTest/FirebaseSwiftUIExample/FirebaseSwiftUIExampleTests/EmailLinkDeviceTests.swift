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

import FirebaseAuth
@testable import FirebaseAuthSwiftUI
import Foundation
import Testing

/// Email-link sign-in when the link is opened on the device that sent it or on another one.
@Suite(.serialized)
@MainActor
struct EmailLinkDeviceTests {
  private func makeService(continueURL: String = "https://flutterfire-e2e-tests.firebaseapp.com",
                           forceSameDevice: Bool = false) async throws -> AuthService {
    configureFirebaseIfNeeded()
    try await clearAuthEmulatorState()
    let settings = makeEmailLinkActionCodeSettings()
    settings.url = URL(string: continueURL)
    return AuthService(
      configuration: AuthConfiguration(emailLinkSignInActionCodeSettings: settings)
    )
    .withEmailLinkSignIn(forceSameDevice: forceSameDevice)
  }

  private func continueURLItems(of url: URL) throws -> [URLQueryItem] {
    let link = try #require(
      URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems?
        .first { $0.name == "link" }?.value
    )
    let continueURL = try #require(
      URLComponents(string: link)?.queryItems?.first { $0.name == "continueUrl" }?.value
    )
    return URLComponents(string: continueURL)?.queryItems ?? []
  }

  @Test
  func continueURLKeepsAppQueryItems() async throws {
    let service = try await makeService(
      continueURL: "https://flutterfire-e2e-tests.firebaseapp.com/?app=1"
    )
    let email = createEmail()

    // The configured settings are reused, so a second link must not repeat the first's items.
    try await service.sendEmailSignInLink(email: createEmail())
    try await service.sendEmailSignInLink(email: email)

    let link = try await fetchEmailSignInLinkFromEmulator(email: email)
    let items = try continueURLItems(of: link)
    #expect(items.filter { $0.name == "app" }.map(\.value) == ["1"])
    #expect(items.filter { $0.name == "ui_sid" }.count == 1)
    #expect(items.first { $0.name == "ui_sd" }?.value == "0")
  }

  @Test
  func linkFromAnotherDeviceWaitsForEmailConfirmation() async throws {
    let service = try await makeService()
    let email = createEmail()
    try await service.sendEmailSignInLink(email: email)
    let link = try await fetchEmailSignInLinkFromEmulator(email: email)

    // Another device has no stored email for the link.
    service.emailLink = nil
    try await service.handleSignInLink(url: link)
    // Waits instead of signing in. Other tests share `Auth`, so its state isn't checked here.
    #expect(service.pendingEmailLink == link)

    try await service.confirmEmailLinkSignIn(email: email)
    try await waitForStateChange {
      service.currentUser?.email?.caseInsensitiveCompare(email) == .orderedSame
    }
    #expect(service.pendingEmailLink == nil)
    try await service.signOut()
  }

  @Test
  func linkFromAnotherSessionWaitsAndCanBeCancelled() async throws {
    let service = try await makeService()
    let email = createEmail()
    try await service.sendEmailSignInLink(email: email)
    let link = try await fetchEmailSignInLinkFromEmulator(email: email)

    // This device sent a newer link since, so the stored email may not be this link's.
    try await service.sendEmailSignInLink(email: createEmail())
    service.emailLink = email
    try await service.handleSignInLink(url: link)
    #expect(service.pendingEmailLink == link)

    service.cancelEmailLinkConfirmation()
    #expect(service.pendingEmailLink == nil)
  }

  @Test
  func signingOutForgetsPendingLink() async throws {
    let service = try await makeService()
    let email = createEmail()
    try await service.sendEmailSignInLink(email: email)
    let link = try await fetchEmailSignInLinkFromEmulator(email: email)
    service.emailLink = nil
    try await service.handleSignInLink(url: link)
    #expect(service.pendingEmailLink == link)

    try await service.signOut()

    #expect(service.pendingEmailLink == nil)
    #expect(service.incomingEmailLink == nil)
  }

  @Test
  func forcedSameDeviceRejectsLinkFromAnotherDevice() async throws {
    let service = try await makeService(forceSameDevice: true)
    let email = createEmail()
    try await service.sendEmailSignInLink(email: email)
    let link = try await fetchEmailSignInLinkFromEmulator(email: email)
    #expect(try continueURLItems(of: link).first { $0.name == "ui_sd" }?.value == "1")

    service.emailLink = nil
    await #expect(throws: AuthServiceError.self) {
      try await service.handleSignInLink(url: link)
    }
    #expect(service.pendingEmailLink == nil)
  }

  @Test
  func openedLinkPresentsEmailLinkScreen() throws {
    configureFirebaseIfNeeded()
    let service = AuthService().withEmailLinkSignIn()
    var link = try #require(URLComponents(string: "https://example.com/"))
    link.queryItems = [URLQueryItem(
      name: "link",
      value: "https://flutterfire-e2e-tests.firebaseapp.com/__/auth/action?apiKey=key"
        + "&mode=signIn&oobCode=code&continueUrl=https://example.com"
    )]
    let url = try #require(link.url)

    service.presentEmailLinkScreen(for: url)

    #expect(service.isPresented)
    #expect(service.authView == .emailLink)
    #expect(service.incomingEmailLink == url)

    // Already showing: the screen's own handler takes the link.
    service.incomingEmailLink = nil
    service.presentEmailLinkScreen(for: url)
    #expect(service.incomingEmailLink == nil)
    #expect(service.navigator.routes == [.emailLink])
  }

  @Test
  func openedLinkIsLeftToAppsOwnEmailLinkScreen() throws {
    configureFirebaseIfNeeded()
    let service = AuthService().withEmailLinkSignIn(onTap: {})
    var link = try #require(URLComponents(string: "https://example.com/"))
    link.queryItems = [URLQueryItem(
      name: "link",
      value: "https://flutterfire-e2e-tests.firebaseapp.com/__/auth/action?apiKey=key"
        + "&mode=signIn&oobCode=code&continueUrl=https://example.com"
    )]

    let url = try #require(link.url)
    service.presentEmailLinkScreen(for: url)

    #expect(!service.isPresented)
    #expect(service.incomingEmailLink == nil)
  }

  @Test
  func openedLinkIsIgnoredWithoutEmailLinkSignIn() throws {
    configureFirebaseIfNeeded()
    let service = AuthService()
    let url = try #require(URL(string: "https://example.com/?link=https://example.com"))

    service.presentEmailLinkScreen(for: url)

    #expect(!service.isPresented)
    #expect(service.navigator.routes.isEmpty)
  }
}
