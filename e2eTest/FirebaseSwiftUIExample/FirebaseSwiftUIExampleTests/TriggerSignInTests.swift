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
import FirebaseCore
import FirebasePhoneAuthSwiftUI
import SwiftUI
import Testing

private struct TestCredentialError: Error {}

private final class FailingCredentialProvider: CredentialAuthProviderSwift {
  func createAuthCredential() async throws -> AuthCredential {
    throw TestCredentialError()
  }
}

private final class PlainProvider: AuthProviderSwift {}

private class TestProviderUI: AuthProviderUI {
  let id: String
  let displayName: String
  let provider: AuthProviderSwift

  init(id: String, provider: AuthProviderSwift) {
    self.id = id
    displayName = id
    self.provider = provider
  }

  @MainActor func authButton() -> AnyView {
    AnyView(EmptyView())
  }
}

private class TestActionProviderUI: TestProviderUI, AuthProviderAction {
  var actionCount = 0

  @MainActor func triggerAction() async throws {
    actionCount += 1
  }
}

@MainActor
struct TriggerSignInTests {
  private func makeService() -> AuthService {
    configureFirebaseIfNeeded()
    return AuthService()
  }

  @Test
  func registeredProvidersKeepRegistrationOrder() {
    let service = makeService()
    service.registerProvider(providerWithButton: TestProviderUI(id: "a", provider: PlainProvider()))
    service.registerProvider(providerWithButton: TestProviderUI(id: "b", provider: PlainProvider()))

    #expect(service.registeredProviders.map(\.id) == ["a", "b"])
  }

  @Test
  func credentialProviderSignsInThroughItsCredential() async {
    let service = makeService()
    let provider = TestProviderUI(id: "credential", provider: FailingCredentialProvider())

    await #expect(throws: TestCredentialError.self) {
      try await service.triggerSignIn(for: provider)
    }
  }

  @Test
  func actionTakesPrecedenceOverCredential() async throws {
    let service = makeService()
    let provider = TestActionProviderUI(id: "both", provider: FailingCredentialProvider())

    let outcome = try await service.triggerSignIn(for: provider)

    #expect(outcome == nil)
    #expect(provider.actionCount == 1)
  }

  @Test
  func actionProviderRunsItsAction() async throws {
    let service = makeService()
    let provider = TestActionProviderUI(id: "action", provider: PlainProvider())

    let outcome = try await service.triggerSignIn(for: provider)

    #expect(outcome == nil)
    #expect(provider.actionCount == 1)
  }

  @Test
  func unsupportedProviderThrows() async {
    let service = makeService()
    let provider = TestProviderUI(id: "custom", provider: PlainProvider())

    await #expect {
      try await service.triggerSignIn(for: provider)
    } throws: { error in
      guard case AuthServiceError.providerAuthenticationFailed = error else { return false }
      return true
    }
  }

  @Test
  func phoneProviderRunsItsTapAction() async throws {
    let service = makeService()
    var tapCount = 0
    let provider = PhoneAuthProviderAuthUI { tapCount += 1 }

    let outcome = try await service.triggerSignIn(for: provider)

    #expect(outcome == nil)
    #expect(tapCount == 1)
  }

  @Test
  func selectEmailLinkRunsCustomCallback() {
    let service = makeService()
    var callbackCount = 0
    _ = service.withEmailLinkSignIn { callbackCount += 1 }

    service.selectEmailLink()

    #expect(callbackCount == 1)
    #expect(service.authView == nil)
  }

  @Test
  func selectEmailLinkPushesEmailLinkScreenByDefault() {
    let service = makeService()
    _ = service.withEmailLinkSignIn()

    service.selectEmailLink()

    #expect(service.authView == .emailLink)
  }
}

@MainActor
struct AuthMethodPickerStateRouteTests {
  private final class Calls {
    var mfa: [MFARequired] = []
    var conflicts: [AccountConflictContext] = []
    var errors: [Error] = []
  }

  private func route(_ result: Result<SignInOutcome?, Error>,
                     withConflictHandler: Bool = true) -> Calls {
    let calls = Calls()
    AuthMethodPickerState.route(
      result,
      mfaHandler: { calls.mfa.append($0) },
      accountConflictHandler: withConflictHandler ? { calls.conflicts.append($0) } : nil,
      reportError: { calls.errors.append($0) }
    )
    return calls
  }

  private func conflictError() -> AuthServiceError {
    .accountConflict(AccountConflictContext(
      conflictType: .accountExistsWithDifferentCredential,
      credential: EmailAuthProvider.credential(withEmail: "a@b.com", password: "123456"),
      underlyingError: TestCredentialError(),
      message: "conflict",
      email: "a@b.com"
    ))
  }

  @Test
  func mfaRequiredGoesToMFAHandler() {
    let calls = route(.success(.mfaRequired(MFARequired(hints: []))))

    #expect(calls.mfa.count == 1)
    #expect(calls.conflicts.isEmpty)
    #expect(calls.errors.isEmpty)
  }

  @Test
  func successAndNoOutcomeCallNothing() {
    for result: Result<SignInOutcome?, Error> in [.success(nil), .success(.signedIn(nil))] {
      let calls = route(result)

      #expect(calls.mfa.isEmpty)
      #expect(calls.conflicts.isEmpty)
      #expect(calls.errors.isEmpty)
    }
  }

  @Test
  func accountConflictGoesToConflictHandler() {
    let calls = route(.failure(conflictError()))

    #expect(calls.conflicts.count == 1)
    #expect(calls.errors.isEmpty)
  }

  @Test
  func accountConflictWithoutHandlerIsReported() {
    let calls = route(.failure(conflictError()), withConflictHandler: false)

    #expect(calls.errors.count == 1)
  }

  @Test
  func otherErrorsAreReported() {
    let calls = route(.failure(TestCredentialError()))

    #expect(calls.errors.first is TestCredentialError)
    #expect(calls.mfa.isEmpty)
    #expect(calls.conflicts.isEmpty)
  }
}
