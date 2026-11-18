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

struct NavigatorTests {
  @Test("Signing in removes every signed-out screen, including the email link screen")
  func removesSignedOutRoutes() {
    let navigator = Navigator()
    navigator.routes = [
      .signIn,
      .signUp,
      .emailLink,
      .passwordRecovery,
      .enterPhoneNumber,
      .enterVerificationCode(verificationID: "id", fullPhoneNumber: "+15551234567"),
      .mfaResolution(MFARequired(hints: [.totp(displayName: nil, uid: "uid")])),
    ]

    navigator.removeSignedOutRoutes()

    #expect(navigator.routes.isEmpty)
  }

  @Test("Signing in keeps screens for a signed-in user, in order")
  func keepsSignedInRoutes() {
    let navigator = Navigator()
    navigator.routes = [.mfaManagement, .emailLink, .mfaEnrollment, .updatePassword]

    navigator.removeSignedOutRoutes()

    #expect(navigator.routes == [.mfaManagement, .mfaEnrollment, .updatePassword])
  }
}
