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

import XCTest

final class LegacySignInRecoveryUITests: XCTestCase {
  override func setUpWithError() throws {
    continueAfterFailure = false
  }

  /// Drives the real recovery flow: a failed password sign-in against an account that also has an
  /// email-link method is what makes `AuthService` build a recovery context and present the sheet.
  @MainActor
  private func presentRecoverySheet(for email: String) throws -> XCUIApplication {
    let app = createTestApp(legacyFetchSignInEnabled: true)
    app.launch()

    let emailField = app.textFields["email-field"]
    XCTAssertTrue(emailField.waitForExistence(timeout: 10), "Email field should exist")
    try enterText(email, into: emailField, app: app)

    let passwordField = app.secureTextFields["password-field"]
    XCTAssertTrue(passwordField.exists, "Password field should exist")
    try enterText("wrong-password", into: passwordField, app: app)

    let signInButton = app.buttons["sign-in-button"]
    XCTAssertTrue(
      waitForElementToBecomeEnabled(signInButton),
      "Sign-In button should become enabled once both fields are filled"
    )
    signInButton.tap()

    let recoveryView = app.scrollViews["legacy-sign-in-recovery-view"]
    XCTAssertTrue(
      recoveryView.waitForExistence(timeout: 15),
      "Legacy sign-in recovery sheet should be visible"
    )

    return app
  }

  @MainActor
  func testLegacyRecoveryEmailPasswordOptionPrefillsEmail() async throws {
    let email = createEmail()
    try await createLegacyRecoveryUser(email: email)

    let app = try presentRecoverySheet(for: email)

    let emailButton = app.buttons["legacy-sign-in-with-email-button"]
    XCTAssertTrue(
      emailButton.waitForExistence(timeout: 5),
      "Email/password recovery action should be visible"
    )
    emailButton.tap()

    let emailField = app.textFields["email-field"]
    XCTAssertTrue(
      emailField.waitForExistence(timeout: 5),
      "Sign-in form should be visible after choosing email/password recovery"
    )
    XCTAssertEqual(
      emailField.value as? String,
      email,
      "Email/password recovery should prefill the previous email"
    )
  }

  @MainActor
  func testLegacyRecoveryEmailLinkOptionNavigatesWithPrefilledEmail() async throws {
    let email = createEmail()
    try await createLegacyRecoveryUser(email: email)

    let app = try presentRecoverySheet(for: email)

    let emailLinkButton = app.buttons["legacy-sign-in-with-email-link-button"]
    XCTAssertTrue(
      emailLinkButton.waitForExistence(timeout: 5),
      "Email link recovery action should be visible"
    )
    emailLinkButton.tap()

    let emailLinkField = app.textFields["email-link-email-field"]
    XCTAssertTrue(
      emailLinkField.waitForExistence(timeout: 5),
      "Email link view should be visible after choosing email link recovery"
    )
    XCTAssertEqual(
      emailLinkField.value as? String,
      email,
      "Email link recovery should prefill the previous email"
    )
  }
}
