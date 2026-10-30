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

/// Records which handler `AuthMethodPickerState.route` called.
@MainActor
private final class RouteRecorder {
  var mfa: MFARequired?
  var conflict: AccountConflictContext?
  var error: Error?

  func route(_ result: Result<SignInOutcome?, Error>, handlesConflicts: Bool = true) {
    AuthMethodPickerState.route(
      result,
      mfaHandler: { self.mfa = $0 },
      accountConflictHandler: handlesConflicts ? { self.conflict = $0 } : nil,
      reportError: { self.error = $0 }
    )
  }
}

private struct TestError: Error {}

private func conflictContext() -> AccountConflictContext {
  AccountConflictContext(
    conflictType: .accountExistsWithDifferentCredential,
    credential: EmailAuthProvider.credential(withEmail: "test@example.com", password: "123456"),
    underlyingError: TestError(),
    message: "conflict",
    email: "test@example.com"
  )
}

@Suite("AuthMethodPickerState routing")
@MainActor
struct AuthMethodPickerStateRoutingTests {
  @Test("MFA required goes to the MFA handler")
  func mfaRequired() {
    let recorder = RouteRecorder()
    let mfa = MFARequired(hints: [.totp(displayName: nil, uid: "uid")])
    recorder.route(.success(.mfaRequired(mfa)))
    #expect(recorder.mfa == mfa)
    #expect(recorder.conflict == nil)
    #expect(recorder.error == nil)
  }

  @Test("A completed sign-in calls no handler")
  func signedIn() {
    let recorder = RouteRecorder()
    recorder.route(.success(.signedIn(nil)))
    recorder.route(.success(nil))
    #expect(recorder.mfa == nil)
    #expect(recorder.conflict == nil)
    #expect(recorder.error == nil)
  }

  @Test("An account conflict goes to the conflict handler")
  func accountConflict() {
    let recorder = RouteRecorder()
    let context = conflictContext()
    recorder.route(.failure(AuthServiceError.accountConflict(context)))
    #expect(recorder.conflict == context)
    #expect(recorder.error == nil)
  }

  @Test("An account conflict is reported when there is no conflict handler")
  func accountConflictWithoutHandler() {
    let recorder = RouteRecorder()
    recorder.route(
      .failure(AuthServiceError.accountConflict(conflictContext())),
      handlesConflicts: false
    )
    #expect(recorder.conflict == nil)
    #expect(recorder.error != nil)
  }

  @Test("Other errors are reported")
  func otherError() {
    let recorder = RouteRecorder()
    recorder.route(.failure(TestError()))
    #expect(recorder.error is TestError)
    #expect(recorder.mfa == nil)
    #expect(recorder.conflict == nil)
  }
}
