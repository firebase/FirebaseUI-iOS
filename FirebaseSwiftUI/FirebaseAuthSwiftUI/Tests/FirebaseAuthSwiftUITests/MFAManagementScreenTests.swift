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
import Testing

@Suite("MFAManagementScreen Tests")
struct MFAManagementScreenTests {
  @Test("Unenroll runs only for an enrolled factor and when idle")
  func unenrollGuard() {
    let enrolled = ["phone-1", "totp-1"]
    #expect(MFAManagementContentState.canUnenroll(
      "phone-1",
      enrolledFactorUids: enrolled,
      isLoading: false
    ))
    #expect(!MFAManagementContentState.canUnenroll(
      "phone-1",
      enrolledFactorUids: enrolled,
      isLoading: true
    ))
    #expect(!MFAManagementContentState.canUnenroll(
      "gone",
      enrolledFactorUids: enrolled,
      isLoading: false
    ))
  }

  @Test("Cancelling reauthentication is not a failure")
  func cancelledReauthIsNotAFailure() {
    #expect(!MFAManagementContentState.isFailure(
      AuthServiceError.signInCancelled("Reauthentication cancelled")
    ))
  }

  @Test("Other unenroll errors are failures")
  func otherErrorsAreFailures() {
    #expect(MFAManagementContentState.isFailure(AuthServiceError.noCurrentUser))
    #expect(MFAManagementContentState.isFailure(
      AuthServiceError.multiFactorAuth("Factor not found")
    ))
  }

  @Test("MFAManagementContentState builds with no arguments")
  @MainActor
  func stateDefaults() {
    let state = MFAManagementContentState()
    #expect(state.enrolledFactors.isEmpty)
    #expect(!state.isLoading && state.errorMessage == nil)
  }
}
