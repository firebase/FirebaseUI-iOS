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
  func testSignInDisplaysSignedInView() async throws {
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
    XCTAssertTrue(
      signedInText.waitForExistence(timeout: 10),
      "SignedInView should be visible after login"
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
    XCTAssertTrue(
      signedInText.waitForExistence(timeout: 10),
      "SignedInView should be visible after login"
    )
  }
}
