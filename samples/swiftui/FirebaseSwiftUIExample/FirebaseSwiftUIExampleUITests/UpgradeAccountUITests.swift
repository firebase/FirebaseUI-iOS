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

//
//  UpgradeAccountUITests.swift
//  UpgradeAccountUITests
//
//  Created by Russell Wheatley on 05/11/2025.
//

import XCTest

final class UpgradeAccountUITests: XCTestCase {
  override func setUpWithError() throws {
    continueAfterFailure = false
  }

  override func tearDownWithError() throws {}

  @MainActor
  func testUpgradeAnonymousAccountWithEmailPassword() async throws {
    // Create a test user first
    let email = createEmail()
    let password = "123456"
    try await createTestUser(email: email, password: password)
    
    // Launch app with anonymous sign-in enabled
    let app = createTestApp()
    app.launchArguments.append("--anonymous-sign-in-enabled")
    app.launch()
    
    // Wait for sign-in screen to appear
    let emailField = app.textFields["email-field"]
    XCTAssertTrue(emailField.waitForExistence(timeout: 6), "Email field should exist")
    emailField.tap()
    emailField.typeText(email)
    
    let passwordField = app.secureTextFields["password-field"]
    XCTAssertTrue(passwordField.exists, "Password field should exist")
    passwordField.tap()
    passwordField.typeText(password)
    
    let signInButton = app.buttons["sign-in-button"]
    XCTAssertTrue(signInButton.exists, "Sign-In button should exist")
    signInButton.tap()
    
    let signedInText = app.staticTexts["signed-in-text"]
    
    // Wait for authentication to complete and signed-in view to appear
    XCTAssertTrue(
      signedInText.waitForExistence(timeout: 30),
      "SignedInView should be visible after signing in with email/password"
    )
  }
}
