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

import FirebaseAuth
import FirebaseCore
import XCTest

func createEmail() -> String {
  let before = UUID().uuidString.prefix(8)
  let after = UUID().uuidString.prefix(6)
  return "\(before)@\(after).com"
}

func dismissAlert(app: XCUIApplication) {
  if app.scrollViews.otherElements.buttons["Not Now"].waitForExistence(timeout: 2) {
    app.scrollViews.otherElements.buttons["Not Now"].tap()
  }
}

final class FirebaseSwiftUIExampleUITests: XCTestCase {
  override func setUpWithError() throws {
    continueAfterFailure = false
  }

  override func tearDownWithError() throws {}

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
  func testSignInDisplaysSignedInView() throws {
    let app = XCUIApplication()
    let email = createEmail()
    app.launchArguments.append("--auth-emulator")
    app.launchArguments.append("--create-user")
    app.launchArguments.append("\(email)")
    app.launch()

    let emailField = app.textFields["email-field"]
    XCTAssertTrue(emailField.waitForExistence(timeout: 6), "Email field should exist")
    emailField.tap()
    emailField.typeText(email)

    let passwordField = app.secureTextFields["password-field"]
    XCTAssertTrue(passwordField.exists, "Password field should exist")
    passwordField.tap()
    passwordField.typeText("123456")

    let signInButton = app.buttons["sign-in-button"]
    XCTAssertTrue(signInButton.exists, "Sign-In button should exist")
    signInButton.tap()

    let signedInText = app.staticTexts["signed-in-text"]

    let expectation = XCTestExpectation(description: "Wait for SignedInView to appear")

    let checkInterval: TimeInterval = 1
    let maxWaitTime: TimeInterval = 30

    Timer.scheduledTimer(withTimeInterval: checkInterval, repeats: true) { timer in
      DispatchQueue.main.async {
        if signedInText.exists {
          expectation.fulfill()
          timer.invalidate()
        }
      }
    }

    wait(for: [expectation], timeout: maxWaitTime)
    XCTAssertTrue(signedInText.exists, "SignedInView should be visible after login")

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
    let app = XCUIApplication()
    let email = createEmail()
    let password = "qwerty321@"
    app.launchArguments.append("--auth-emulator")
    app.launch()

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

    let signInButton = app.buttons["sign-in-button"]
    XCTAssertTrue(signInButton.exists, "Sign-In button should exist")
    signInButton.tap()

    let signedInText = app.staticTexts["signed-in-text"]

    let expectation = XCTestExpectation(description: "Wait for SignedInView to appear")

    let checkInterval: TimeInterval = 1
    let maxWaitTime: TimeInterval = 30

    Timer.scheduledTimer(withTimeInterval: checkInterval, repeats: true) { timer in
      DispatchQueue.main.async {
        if signedInText.exists {
          expectation.fulfill()
          timer.invalidate()
        }
      }
    }

    wait(for: [expectation], timeout: maxWaitTime)
    XCTAssertTrue(signedInText.exists, "SignedInView should be visible after login")
  }
}
