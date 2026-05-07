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

  @MainActor
  func testLegacyRecoveryEmailPasswordOptionPrefillsEmail() throws {
    let app = createTestApp(
      legacyFetchSignInEnabled: true,
      legacyRecoveryPreviewEnabled: true
    )
    app.launch()

    let recoveryView = app.scrollViews["legacy-sign-in-recovery-view"]
    XCTAssertTrue(
      recoveryView.waitForExistence(timeout: 5),
      "Legacy sign-in recovery sheet should be visible"
    )

    let emailButton = app.buttons["legacy-sign-in-with-email-button"]
    XCTAssertTrue(
      emailButton.waitForExistence(timeout: 5),
      "Email/password recovery action should be visible"
    )
    emailButton.tap()

    let emailField = app.textFields["email-field"]
    XCTAssertEqual(
      emailField.value as? String,
      "legacy@example.com",
      "Email/password recovery should prefill the previous email"
    )
  }

  @MainActor
  func testLegacyRecoveryEmailLinkOptionNavigatesWithPrefilledEmail() throws {
    let app = createTestApp(
      legacyFetchSignInEnabled: true,
      legacyRecoveryPreviewEnabled: true
    )
    app.launch()

    let recoveryView = app.scrollViews["legacy-sign-in-recovery-view"]
    XCTAssertTrue(
      recoveryView.waitForExistence(timeout: 5),
      "Legacy sign-in recovery sheet should be visible"
    )

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
      "legacy@example.com",
      "Email link recovery should prefill the previous email"
    )
  }
}
