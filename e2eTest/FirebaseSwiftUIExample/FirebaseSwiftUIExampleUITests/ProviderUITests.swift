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
//  FirebaseSwiftUIExampleUITests.swift
//  FirebaseSwiftUIExampleUITests
//
//  Created by Russell Wheatley on 18/02/2025.
//

import XCTest

final class ProviderUITests: XCTestCase {
  override func setUpWithError() throws {
    continueAfterFailure = false
  }

  override func tearDownWithError() throws {}

  @MainActor
  func testProviderButtons() throws {
    let app = createTestApp()
    app.launch()

    // MARK: - Check existence of provider buttons

    // Check for Twitter/X sign-in button
    let twitterButton = app.buttons["sign-in-with-twitter-button"]
    XCTAssertTrue(
      twitterButton.waitForExistence(timeout: 5),
      "Twitter/X sign-in button should exist"
    )

    // Check for Apple sign-in button
    let appleButton = app.buttons["sign-in-with-apple-button"]
    XCTAssertTrue(
      appleButton.waitForExistence(timeout: 5),
      "Apple sign-in button should exist"
    )

    // Check for Github sign-in button
    let githubButton = app.buttons["sign-in-with-github.com-button"]
    XCTAssertTrue(
      githubButton.waitForExistence(timeout: 5),
      "Github sign-in button should exist"
    )

    // Check for Microsoft sign-in button
    let microsoftButton = app.buttons["sign-in-with-microsoft.com-button"]
    XCTAssertTrue(
      microsoftButton.waitForExistence(timeout: 5),
      "Microsoft sign-in button should exist"
    )

    // Check for Yahoo sign-in button
    let yahooButton = app.buttons["sign-in-with-yahoo.com-button"]
    XCTAssertTrue(
      yahooButton.waitForExistence(timeout: 5),
      "Yahoo sign-in button should exist"
    )

    // Check for Google sign-in button
    let googleButton = app.buttons["sign-in-with-google-button"]
    XCTAssertTrue(
      googleButton.waitForExistence(timeout: 5),
      "Google sign-in button should exist"
    )

    // Check for Facebook sign-in button
    let facebookButton = app.buttons["sign-in-with-facebook-button"]
    XCTAssertTrue(
      facebookButton.waitForExistence(timeout: 5),
      "Facebook sign-in button should exist"
    )

    // Check for Phone sign-in button
    let phoneButton = app.buttons["sign-in-with-phone-button"]
    XCTAssertTrue(
      phoneButton.waitForExistence(timeout: 5),
      "Phone sign-in button should exist"
    )
  }

  @MainActor
  func testErrorModal() throws {
    let app = createTestApp()
    app.launch()
    // Just test email + external provider for error modal on failure to ensure provider button
    // sign-in flow fails along with failures within AuthPickerView
    let emailField = app.textFields["email-field"]
    XCTAssertTrue(emailField.waitForExistence(timeout: 6), "Email field should exist")
    emailField.tap()
    emailField.typeText("fake-email@example.com")

    let passwordField = app.secureTextFields["password-field"]
    XCTAssertTrue(passwordField.exists, "Password field should exist")
    passwordField.tap()
    passwordField.typeText("12345678")

    let signInButton = app.buttons["sign-in-button"]
    XCTAssertTrue(signInButton.exists, "Sign-In button should exist")
    signInButton.tap()

    // Wait for the alert to appear
    let alert1 = app.alerts.firstMatch
    XCTAssertTrue(
      alert1.waitForExistence(timeout: 5),
      "Alert should appear after canceling Facebook sign-in"
    )

    alert1.buttons["OK"].firstMatch.tap()

    let facebookButton = app.buttons["sign-in-with-facebook-button"]
    XCTAssertTrue(
      facebookButton.waitForExistence(timeout: 5),
      "Facebook sign-in button should exist"
    )

    facebookButton.tap()

    // Wait for Facebook modal to appear and tap Cancel
    // The Facebook SDK modal is presented by the system/Safari
    let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")

    // Access the Cancel button from Springboard
    let cancelButton = springboard.buttons["Cancel"]
    XCTAssertTrue(
      cancelButton.waitForExistence(timeout: 10),
      "Cancel button should appear in Springboard authentication modal"
    )
    cancelButton.tap()

    // Wait for the alert to appear
    let alert2 = app.alerts.firstMatch
    XCTAssertTrue(
      alert2.waitForExistence(timeout: 5),
      "Alert should appear after canceling Facebook sign-in"
    )
  }
}
