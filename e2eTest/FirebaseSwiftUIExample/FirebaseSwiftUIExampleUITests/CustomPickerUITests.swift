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

/// A custom first screen (`--custom-picker`) with separate email sign-in and create-account
/// buttons, which push the stock `SignInView` and `SignUpView`.
final class CustomPickerUITests: XCTestCase {
  override func setUpWithError() throws {
    continueAfterFailure = false
  }

  @MainActor
  private func launchCustomPicker() -> XCUIApplication {
    let app = createTestApp(customPicker: true)
    app.launch()
    XCTAssertTrue(
      app.buttons["custom-create-account-button"].waitForExistence(timeout: 10),
      "Custom first screen should show"
    )
    return app
  }

  @MainActor
  func testLoginFromDirectSignUpOpensSignIn() {
    let app = launchCustomPicker()

    app.buttons["custom-create-account-button"].tap()
    XCTAssertTrue(
      app.secureTextFields["confirm-password-field"].waitForExistence(timeout: 5),
      "Create account should open the sign-up screen"
    )

    let switchFlow = app.buttons["switch-auth-flow"]
    XCTAssertTrue(waitForElementToBecomeHittable(switchFlow, timeout: 5))
    switchFlow.tap()

    XCTAssertTrue(
      app.buttons["password-recovery-button"].waitForExistence(timeout: 5),
      "Login should open the sign-in screen, not the first screen"
    )
    XCTAssertFalse(app.secureTextFields["confirm-password-field"].exists)
    XCTAssertFalse(app.buttons["custom-create-account-button"].isHittable)

    app.navigationBars.buttons.element(boundBy: 0).tap()
    XCTAssertTrue(
      waitForElementToBecomeHittable(app.buttons["custom-create-account-button"], timeout: 5),
      "Back from sign-in should return to the custom first screen"
    )
  }

  @MainActor
  func testSignInErrorShowsOneAlert() async throws {
    let email = createEmail()
    try await createTestUser(email: email)
    let app = launchCustomPicker()

    app.buttons["custom-email-sign-in-button"].tap()
    let emailField = app.textFields["email-field"]
    XCTAssertTrue(emailField.waitForExistence(timeout: 5), "Sign-in screen should open")
    try enterText(email, into: emailField, app: app)
    try enterText("wrong-password", into: app.secureTextFields["password-field"], app: app)

    let signInButton = app.buttons["sign-in-button"]
    XCTAssertTrue(waitForElementToBecomeEnabled(signInButton))
    signInButton.tap()

    let alert = app.alerts.firstMatch
    XCTAssertTrue(alert.waitForExistence(timeout: 15), "A failed sign-in should show an alert")
    XCTAssertEqual(app.alerts.count, 1, "The error should show once, not twice")

    alert.buttons.firstMatch.tap()
    XCTAssertTrue(
      waitForElementToBecomeHittable(signInButton, timeout: 5),
      "Closing the alert should return to the sign-in screen"
    )
    XCTAssertEqual(app.alerts.count, 0, "No second alert should follow")
  }
}
