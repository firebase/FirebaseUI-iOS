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

final class FirebaseSwiftUIExampleUITests: XCTestCase {
  override func setUpWithError() throws {
    continueAfterFailure = false
  }

  override func tearDownWithError() throws {}

  @MainActor
  func testNoProvidersInitialized() throws {
    let app = XCUIApplication()
    app.launchArguments.append("--test-view-enabled")
    app.launchArguments.append("--no-providers")
    app.launch()

    // Verify email/password fields are NOT visible when no providers are initialized
    let emailField = app.textFields["email-field"]
    XCTAssertFalse(
      emailField.waitForExistence(timeout: 2),
      "Email field should NOT be visible when no providers are initialized"
    )

    // Verify email link button is NOT visible
    let emailLinkButton = app.buttons["sign-in-with-email-link-button"]
    XCTAssertFalse(
      emailLinkButton.waitForExistence(timeout: 2),
      "Email link button should NOT be visible when no providers are initialized"
    )

    // Verify provider buttons are NOT visible
    let googleButton = app.buttons["sign-in-with-google-button"]
    XCTAssertFalse(
      googleButton.waitForExistence(timeout: 2),
      "Google button should NOT be visible when no providers are initialized"
    )

    let facebookButton = app.buttons["sign-in-with-facebook-button"]
    XCTAssertFalse(
      facebookButton.waitForExistence(timeout: 2),
      "Facebook button should NOT be visible when no providers are initialized"
    )
  }

  @MainActor
  func testAllProvidersInitialized() throws {
    let app = XCUIApplication()
    app.launchArguments.append("--test-view-enabled")
    // No --no-providers flag means all providers are enabled by default
    app.launch()

    // Verify email/password fields are visible when withEmailSignIn() is enabled
    let emailField = app.textFields["email-field"]
    XCTAssertTrue(
      emailField.waitForExistence(timeout: 5),
      "Email field should be visible when withEmailSignIn() is enabled"
    )

    let passwordField = app.secureTextFields["password-field"]
    XCTAssertTrue(
      passwordField.waitForExistence(timeout: 5),
      "Password field should be visible when withEmailSignIn() is enabled"
    )

    let signInButton = app.buttons["sign-in-button"]
    XCTAssertTrue(
      signInButton.waitForExistence(timeout: 5),
      "Sign-in button should be visible when withEmailSignIn() is enabled"
    )

    // Verify email link button is visible when withEmailLinkSignIn() is enabled
    let emailLinkButton = app.buttons["sign-in-with-email-link-button"]
    XCTAssertTrue(
      emailLinkButton.waitForExistence(timeout: 5),
      "Email link button should be visible when withEmailLinkSignIn() is enabled"
    )

    // Tap the email link button and verify it navigates to email link view
    emailLinkButton.tap()
    let emailLinkText = app.staticTexts["Send a sign-in link to your email"].firstMatch
    XCTAssertTrue(
      emailLinkText.waitForExistence(timeout: 5),
      "Email link view should appear after tapping email link button"
    )

    // Go back to verify provider buttons
    let backButton = app.navigationBars.buttons.element(boundBy: 0)
    if backButton.exists {
      backButton.tap()
    }

    // Verify provider buttons are visible
    let googleButton = app.buttons["sign-in-with-google-button"]
    XCTAssertTrue(
      googleButton.waitForExistence(timeout: 5),
      "Google sign-in button should be visible when withGoogleSignIn() is enabled"
    )

    let facebookButton = app.buttons["sign-in-with-facebook-button"]
    XCTAssertTrue(
      facebookButton.waitForExistence(timeout: 5),
      "Facebook sign-in button should be visible when withFacebookSignIn() is enabled"
    )
  }

  @MainActor
  func testSignInDisplaysSignedInView() async throws {
    let email = createEmail()
    let password = "123456"

    // Create user in test runner BEFORE launching app
    // User will exist in emulator, but app starts unauthenticated
    try await createTestUser(email: email, password: password)

    // Now launch the app - it connects to emulator but isn't signed in
    let app = createTestApp()
    app.launch()

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

    // Wait for authentication to complete and signed-in view to appear
    let signedInText = app.staticTexts["signed-in-text"]
    XCTAssertTrue(
      signedInText.waitForExistence(timeout: 30),
      "SignedInView should be visible after login"
    )

    dismissAlert(app: app)
    // Check the Views are updated
    let signOutButton = app.buttons["sign-out-button"]
    XCTAssertTrue(
      signOutButton.waitForExistence(timeout: 10),
      "Sign-Out button should exist and be visible"
    )

    signOutButton.tap()
    XCTAssertTrue(
      signInButton.waitForExistence(timeout: 20),
      "Sign-In button should exist after logout"
    )

    let passwordRecoveryButton = app.buttons["password-recovery-button"]
    XCTAssertTrue(passwordRecoveryButton.exists, "Password recovery button should exist")
    passwordRecoveryButton.tap()
    let passwordRecoveryText = app.staticTexts["Send a password recovery link to your email"]
      .firstMatch
    XCTAssertTrue(
      passwordRecoveryText.waitForExistence(timeout: 10),
      "Password recovery text should exist after routing to PasswordRecoveryView"
    )

    let passwordRecoveryBackButton = app.navigationBars.buttons.element(boundBy: 0)
    XCTAssertTrue(passwordRecoveryBackButton.exists, "Password back button should exist")
    passwordRecoveryBackButton.tap()

    let signInButton2 = app.buttons["sign-in-button"]
    XCTAssertTrue(
      signInButton2.waitForExistence(timeout: 10),
      "Sign-In button should exist after pressing password recovery back button"
    )

    let emailLinkSignInButton = app.buttons["sign-in-with-email-link-button"]
    XCTAssertTrue(emailLinkSignInButton.exists, "Email link sign-in button should exist")
    emailLinkSignInButton.tap()

    let emailLinkText = app.staticTexts["Send a sign-in link to your email"].firstMatch

    XCTAssertTrue(
      emailLinkText.waitForExistence(timeout: 10),
      "Email link text should exist after pressing email link button in AuthPickerView"
    )

    let emailLinkBackButton = app.navigationBars.buttons.element(boundBy: 0)
    XCTAssertTrue(emailLinkBackButton.exists, "Email link back button should exist")
    emailLinkBackButton.tap()

    let signInButton3 = app.buttons["sign-in-button"]
    XCTAssertTrue(
      signInButton3.waitForExistence(timeout: 10),
      "Sign-In button should exist after pressing password recovery back button"
    )
  }

  @MainActor
  func testCreateUserDisplaysSignedInView() throws {
    let email = createEmail()
    let password = "qwerty321@"
    let app = createTestApp()
    app.launch()

    // Check the Views are updated
    let signOutButton = app.buttons["sign-out-button"]
    if signOutButton.exists {
      signOutButton.tap()
    }

    let switchFlowButton = app.buttons["switch-auth-flow"]
    switchFlowButton.tap()

    let emailField = app.textFields["email-field"]

    XCTAssertTrue(emailField.waitForExistence(timeout: 2), "Email field should exist")
    try pasteIntoField(emailField, text: email, app: app)

    let passwordField = app.secureTextFields["password-field"]
    XCTAssertTrue(passwordField.exists, "Password field should exist")
    try pasteIntoField(passwordField, text: password, app: app)

    let confirmPasswordField = app.secureTextFields["confirm-password-field"]
    XCTAssertTrue(confirmPasswordField.exists, "Confirm password field should exist")
    try pasteIntoField(confirmPasswordField, text: password, app: app)

    // Create the user (sign up)
    let signUpButton = app
      .buttons["sign-in-button"] // This button changes context after switch-auth-flow
    XCTAssertTrue(signUpButton.exists, "Sign-Up button should exist")
    signUpButton.tap()

    // Wait for user creation and signed-in view to appear
    let signedInText = app.staticTexts["signed-in-text"]
    XCTAssertTrue(
      signedInText.waitForExistence(timeout: 30),
      "SignedInView should be visible after user creation"
    )
  }
}
