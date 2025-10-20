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
  
  /// Creates and configures an XCUIApplication with default test launch arguments
  private func createTestApp(mfaEnabled: Bool = false) -> XCUIApplication {
    let app = XCUIApplication()
    app.launchArguments.append("--test-view-enabled")
    if mfaEnabled {
      app.launchArguments.append("--mfa-enabled")
    }
    return app
  }
  
  private func dismissAlert(app: XCUIApplication) {
    if app.scrollViews.otherElements.buttons["Not Now"].waitForExistence(timeout: 2) {
      app.scrollViews.otherElements.buttons["Not Now"].tap()
    }
  }
  
  /// Helper to create a test user in the emulator via REST API (avoids keychain issues)
  private func createTestUser(email: String, password: String) async throws {
    // Use Firebase Auth emulator REST API directly to avoid keychain access issues in UI tests
    let signUpUrl = "http://127.0.0.1:9099/identitytoolkit.googleapis.com/v1/accounts:signUp?key=fake-api-key"
    
    guard let url = URL(string: signUpUrl) else {
      throw NSError(domain: "TestError", code: 1, 
                   userInfo: [NSLocalizedDescriptionKey: "Invalid emulator URL"])
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let body: [String: Any] = [
      "email": email,
      "password": password,
      "returnSecureToken": true
    ]
    
    request.httpBody = try JSONSerialization.data(withJSONObject: body)
    
    let (data, response) = try await URLSession.shared.data(for: request)
    
    guard let httpResponse = response as? HTTPURLResponse,
          httpResponse.statusCode == 200 else {
      let errorBody = String(data: data, encoding: .utf8) ?? "Unknown error"
      throw NSError(domain: "TestError", code: 2,
                   userInfo: [NSLocalizedDescriptionKey: "Failed to create user: \(errorBody)"])
    }
  }

  @MainActor
  func testExample() throws {
    let app = XCUIApplication()
    app.launch()
  }

  @MainActor
  func testLaunchPerformance() throws {
    if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
      measure(metrics: [XCTApplicationLaunchMetric()]) {
        XCUIApplication().launch()
      }
    }
  }

  @MainActor
  func testSignInButtonsExist() throws {
    let app = createTestApp()
    app.launch()
    
    // Check for Twitter/X sign-in button
    let twitterButton = app.buttons["sign-in-with-twitter-button"]
    XCTAssertTrue(
      twitterButton.waitForExistence(timeout: 5),
      "Twitter/X sign-in button should exist"
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
    let passwordRecoveryText = app.staticTexts["password-recovery-text"]
    XCTAssertTrue(
      passwordRecoveryText.waitForExistence(timeout: 10),
      "Password recovery text should exist after routing to PasswordRecoveryView"
    )

    let passwordRecoveryBackButton = app.buttons["password-recovery-back-button"]
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

    let emailLinkText = app.staticTexts["email-link-title-text"]

    XCTAssertTrue(
      emailLinkText.waitForExistence(timeout: 10),
      "Email link text should exist after pressing email link button in AuthPickerView"
    )

    let emailLinkBackButton = app.buttons["email-link-back-button"]
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
    // Workaround for updating SecureFields with ConnectHardwareKeyboard enabled
    UIPasteboard.general.string = email
    emailField.press(forDuration: 1.2)
    app.menuItems["Paste"].tap()

    let passwordField = app.secureTextFields["password-field"]
    XCTAssertTrue(passwordField.exists, "Password field should exist")
    UIPasteboard.general.string = password
    passwordField.press(forDuration: 1.2)
    app.menuItems["Paste"].tap()

    let confirmPasswordField = app.secureTextFields["confirm-password-field"]
    XCTAssertTrue(confirmPasswordField.exists, "Confirm password field should exist")
    UIPasteboard.general.string = password
    confirmPasswordField.press(forDuration: 1.2)
    app.menuItems["Paste"].tap()

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
