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

@testable import FirebaseAuthSwiftUI
import SwiftUI
import Testing

/// `SignedInContentState`'s public initializer must be callable with no arguments, so adding a
/// field with a default later never breaks a consumer's preview. This fails to compile if a
/// parameter loses its default.
@Suite("SignedInContentState defaults")
@MainActor
struct SignedInContentStateTests {
  @Test("SignedInContentState builds with no arguments")
  func noArguments() {
    let state = SignedInContentState()
    #expect(state.user == nil)
    #expect(state.isEmailVerified && state.isMFAEnabled)
    #expect(!state.isLoading && state.errorMessage == nil)
  }

  @Test("A preview passes only the fields it needs")
  func partialArguments() {
    let state = SignedInContentState(isEmailVerified: false, isLoading: true)
    #expect(!state.isEmailVerified)
    #expect(state.isLoading)
  }
}

@Suite("Signed-in email verification rule")
struct SignedInEmailVerificationTests {
  @Test("Users without an email are treated as verified")
  func noEmail() {
    #expect(SignedInScreen<EmptyView>.isEmailVerified(email: nil, verified: nil))
    #expect(SignedInScreen<EmptyView>.isEmailVerified(email: nil, verified: false))
  }

  @Test("Users with an email follow Firebase's verified flag")
  func withEmail() {
    #expect(SignedInScreen<EmptyView>.isEmailVerified(email: "a@b.com", verified: true))
    #expect(!SignedInScreen<EmptyView>.isEmailVerified(email: "a@b.com", verified: false))
    #expect(!SignedInScreen<EmptyView>.isEmailVerified(email: "a@b.com", verified: nil))
  }
}
