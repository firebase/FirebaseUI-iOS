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
import Testing

@MainActor
struct EmailRouteTests {
  private func makeService() -> AuthService {
    configureFirebaseIfNeeded()
    return AuthService()
  }

  private let emailOption = LegacySignInOption(id: EmailAuthProviderID, displayName: "Email")

  @Test
  func removeEmailRoutesKeepsOtherRoutes() {
    let navigator = Navigator()
    navigator.push(.signIn)
    navigator.push(.signUp)
    navigator.push(.passwordRecovery)

    navigator.removeEmailRoutes()

    #expect(navigator.routes == [.passwordRecovery])
  }

  @Test
  func legacyEmailRecoveryReturnsToPushedSignIn() {
    let service = makeService()
    service.navigator.push(.signIn)
    service.navigator.push(.signUp)

    service.startLegacyRecovery(option: emailOption, email: "user@example.com")

    #expect(service.navigator.routes == [.signIn])
    #expect(service.suggestedEmailAddress == "user@example.com")
  }

  @Test
  func legacyEmailRecoveryReturnsToFirstScreenWithoutEmailRoute() {
    let service = makeService()
    service.navigator.push(.enterPhoneNumber)

    service.startLegacyRecovery(option: emailOption, email: "user@example.com")

    #expect(service.navigator.routes.isEmpty)
  }

  @Test
  func signOutClearsNavigation() async throws {
    let service = makeService()
    service.navigator.push(.signIn)
    service.navigator.push(.signUp)

    try await service.signOut()

    #expect(service.navigator.routes.isEmpty)
  }
}
