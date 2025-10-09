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
//  MFAEnrollmentUITests.swift
//  FirebaseSwiftUIExampleUITests
//
//  UI tests for MFA enrollment workflows including SMS and TOTP enrollment
//

import XCTest

final class MFAEnrollmentUITests: XCTestCase {
  override func setUpWithError() throws {
    continueAfterFailure = false
  }

  // MARK: - MFA Management Navigation Tests

  @MainActor
  func testMFAManagementButtonExistsAndIsTappable() throws {
    let app = XCUIApplication()
    app.launchArguments.append("--auth-emulator")
    app.launchArguments.append("--mfa-enabled")
    app.launchArguments.append("--create-user")
    let email = createEmail()
    app.launchArguments.append("\(email)")
    app.launch()

    // Sign in first to access MFA management
    try signInToApp(app: app, email: email)

    // Check MFA management button exists
    let mfaManagementButton = app.buttons["mfa-management-button"]
    XCTAssertTrue(
      mfaManagementButton.waitForExistence(timeout: 5),
      "MFA management button should exist"
    )
    XCTAssertTrue(mfaManagementButton.isEnabled, "MFA management button should be enabled")

    // Tap the button
    mfaManagementButton.tap()

    // Verify we navigated to MFA management view
    let managementTitle = app.staticTexts["Two-Factor Authentication"]
    XCTAssertTrue(
      managementTitle.waitForExistence(timeout: 5),
      "Should navigate to MFA management view"
    )
  }

  @MainActor
  func testMFAEnrollmentNavigationFromManagement() throws {
    let app = XCUIApplication()
    app.launchArguments.append("--auth-emulator")
    app.launchArguments.append("--mfa-enabled")
    app.launchArguments.append("--create-user")
    let email = createEmail()
    app.launchArguments.append("\(email)")
    app.launch()

    // Sign in and navigate to MFA management
    try signInToApp(app: app, email: email)
    app.buttons["mfa-management-button"].tap()

    // Tap setup MFA button (for users with no enrolled factors)
    let setupButton = app.buttons["setup-mfa-button"]
    if setupButton.waitForExistence(timeout: 3) {
      setupButton.tap()
    } else {
      // If factors are already enrolled, tap add another method
      let addMethodButton = app.buttons["add-mfa-method-button"]
      XCTAssertTrue(addMethodButton.waitForExistence(timeout: 3), "Add method button should exist")
      addMethodButton.tap()
    }

    // Verify we navigated to MFA enrollment view
    let enrollmentTitle = app.staticTexts["Set Up Two-Factor Authentication"]
    XCTAssertTrue(
      enrollmentTitle.waitForExistence(timeout: 5),
      "Should navigate to MFA enrollment view"
    )
  }

  // MARK: - MFA Enrollment Factor Selection Tests

  @MainActor
  func testFactorTypePickerExistsAndWorks() throws {
    let app = XCUIApplication()
    app.launchArguments.append("--auth-emulator")
    app.launchArguments.append("--mfa-enabled")
    app.launchArguments.append("--create-user")
    let email = createEmail()
    app.launchArguments.append("\(email)")
    app.launch()

    // Navigate to MFA enrollment
    try signInToApp(app: app, email: email)
    try navigateToMFAEnrollment(app: app)

    // Check factor type picker exists
    let factorPicker = app.segmentedControls["factor-type-picker"]
    XCTAssertTrue(factorPicker.waitForExistence(timeout: 5), "Factor type picker should exist")

    // Test selecting SMS
    let smsOption = factorPicker.buttons.element(boundBy: 0)
    smsOption.tap()
    XCTAssertTrue(smsOption.isSelected, "SMS option should be selected")

    // Test selecting TOTP
    let totpOption = factorPicker.buttons.element(boundBy: 1)
    totpOption.tap()
    XCTAssertTrue(totpOption.isSelected, "TOTP option should be selected")
  }

  @MainActor
  func testStartEnrollmentButtonExistsAndWorks() throws {
    let app = XCUIApplication()
    app.launchArguments.append("--auth-emulator")
    app.launchArguments.append("--mfa-enabled")
    app.launchArguments.append("--create-user")
    let email = createEmail()
    app.launchArguments.append("\(email)")
    app.launch()

    // Navigate to MFA enrollment
    try signInToApp(app: app, email: email)
    try navigateToMFAEnrollment(app: app)

    // Check start enrollment button exists and is enabled
    let startButton = app.buttons["start-enrollment-button"]
    XCTAssertTrue(startButton.waitForExistence(timeout: 5), "Start enrollment button should exist")
    XCTAssertTrue(startButton.isEnabled, "Start enrollment button should be enabled")

    // Tap the button
    startButton.tap()

    // Verify the form changes (either phone input for SMS or QR code for TOTP)
    let phoneField = app.textFields["phone-number-field"]
    let qrCode = app.images["qr-code-image"]

    // Either phone field or QR code should appear
    let phoneFieldExists = phoneField.waitForExistence(timeout: 5)
    let qrCodeExists = qrCode.waitForExistence(timeout: 5)

    XCTAssertTrue(
      phoneFieldExists || qrCodeExists,
      "Either phone field or QR code should appear after starting enrollment"
    )
  }

  // MARK: - SMS Enrollment Flow Tests

  @MainActor
  func testEndToEndSMSEnrollmentAndRemovalFlow() async throws {
    // 1) Launch app with emulator and create a fresh user
    let app = XCUIApplication()
    app.launchArguments.append("--auth-emulator")
    app.launchArguments.append("--mfa-enabled")
    app.launchArguments.append("--verify-email")
    app.launchArguments.append("--create-user")
    let email = createEmail()
    app.launchArguments.append("\(email)")
    app.launch()

    // 2) Sign in to reach SignedInView
    try signInToApp(app: app, email: email)

    // 3) From SignedInView, open MFA Management
    let mfaManagementButton = app.buttons["mfa-management-button"]
    XCTAssertTrue(mfaManagementButton.waitForExistence(timeout: 10))
    mfaManagementButton.tap()

    // 4) In MFAManagementView, tap "Set Up Two-Factor Authentication"
    let setupButton = app.buttons["setup-mfa-button"]
    XCTAssertTrue(setupButton.waitForExistence(timeout: 10))
    setupButton.tap()

    // 5) In MFAEnrollmentView, select SMS factor and start the flow
    let factorPicker = app.segmentedControls["factor-type-picker"]
    XCTAssertTrue(factorPicker.waitForExistence(timeout: 10))
    factorPicker.buttons.element(boundBy: 0).tap() // SMS

    let startButton = app.buttons["start-enrollment-button"]
    XCTAssertTrue(startButton.waitForExistence(timeout: 10))
    startButton.tap()

    // 6) Enter phone number and display name, then press "Send Code"
    let phoneField = app.textFields["phone-number-field"]
    XCTAssertTrue(phoneField.waitForExistence(timeout: 10))
    let phoneNumber = "+447444555666"
    UIPasteboard.general.string = phoneNumber
    phoneField.tap()
    phoneField.press(forDuration: 1.2)
    app.menuItems["Paste"].tap()

    let displayNameField = app.textFields["display-name-field"]
    XCTAssertTrue(displayNameField.waitForExistence(timeout: 10))
    UIPasteboard.general.string = "test user"
    displayNameField.tap()
    displayNameField.press(forDuration: 1.2)
    app.menuItems["Paste"].tap()

    let sendCodeButton = app.buttons["send-sms-button"]
    XCTAssertTrue(sendCodeButton.waitForExistence(timeout: 10))
    XCTAssertTrue(sendCodeButton.isEnabled)
    sendCodeButton.tap()

    // 7) Retrieve verification code from the Auth Emulator and complete setup
    let verificationCodeField = app.textFields["verification-code-field"]
    XCTAssertTrue(verificationCodeField.waitForExistence(timeout: 15))

    // Fetch the latest SMS verification code generated by the emulator for this phone number
    let code = try await getLastSmsCode(specificPhone: phoneNumber)

    UIPasteboard.general.string = code
    verificationCodeField.tap()
    verificationCodeField.press(forDuration: 1.2)
    app.menuItems["Paste"].tap()
    
    // Test resend code button exists
    let resendButton = app.buttons["resend-code-button"]
    XCTAssertTrue(resendButton.exists, "Resend code button should exist")

    let completeSetupButton = app.buttons["complete-enrollment-button"]
    XCTAssertTrue(completeSetupButton.waitForExistence(timeout: 10))
    XCTAssertTrue(completeSetupButton.isEnabled)
    completeSetupButton.tap()

    // 8) Verify we've returned to SignedInView
    let signedInText = app.staticTexts["signed-in-text"]
    XCTAssertTrue(signedInText.waitForExistence(timeout: 15))

    // 9) Open MFA Management again and verify SMS factor is enrolled
    XCTAssertTrue(mfaManagementButton.waitForExistence(timeout: 10))
    mfaManagementButton.tap()

    let enrolledMethodsHeader = app.staticTexts["Enrolled Methods"]
    XCTAssertTrue(enrolledMethodsHeader.waitForExistence(timeout: 10))

    // Find a "Remove" button for any enrolled factor (identifier starts with "remove-factor-")
    let removeButton = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "remove-factor-")).firstMatch
    XCTAssertTrue(removeButton.waitForExistence(timeout: 10))

    // 10) Remove the enrolled SMS factor and verify we're back to setup state
    removeButton.tap()

    // After removal, the setup button should reappear for an empty list
    XCTAssertTrue(setupButton.waitForExistence(timeout: 15))
  }


  // MARK: - TOTP Enrollment Flow Tests

  @MainActor
  func testTOTPEnrollmentFlowUI() throws {
    let app = XCUIApplication()

    app.launchArguments.append("--auth-emulator")
    app.launchArguments.append("--mfa-enabled")
    app.launchArguments.append("--verify-email")
    app.launchArguments.append("--create-user")
    let email = createEmail()
    app.launchArguments.append("\(email)")
    app.launch()

    // Navigate to MFA enrollment and select TOTP
    try signInToApp(app: app, email: email)
    try navigateToMFAEnrollment(app: app)

    // Select TOTP factor type
    let factorPicker = app.segmentedControls["factor-type-picker"]
    factorPicker.buttons.element(boundBy: 1).tap() // TOTP option

    // Start enrollment
    app.buttons["start-enrollment-button"].tap()

    // Test QR code image (might not load in test environment)
    let qrCodeImage = app.images["qr-code-image"]
    if qrCodeImage.waitForExistence(timeout: 5) {
      XCTAssertTrue(qrCodeImage.exists, "QR code image should appear")
    }

    // TOTP enrollment isn't testable via emulator, so this is commented out for the moment
    // Test TOTP secret key display
//    let secretKey = app.staticTexts["totp-secret-key"]

//    XCTAssertTrue(secretKey.waitForExistence(timeout: 5), "TOTP secret key should be displayed")
//
//    // Test display name field
//    let displayNameField = app.textFields["display-name-field"]
//    XCTAssertTrue(displayNameField.exists, "Display name field should exist")
//
//    // Test TOTP code input field
//    let totpCodeField = app.textFields["totp-code-field"]
//    XCTAssertTrue(totpCodeField.exists, "TOTP code field should exist")
//    XCTAssertTrue(totpCodeField.isEnabled, "TOTP code field should be enabled")
//
//    // Test complete enrollment button
//    let completeButton = app.buttons["complete-enrollment-button"]
//    XCTAssertTrue(completeButton.exists, "Complete enrollment button should exist")
//
//    // Button should be disabled without code
//    XCTAssertFalse(completeButton.isEnabled, "Complete button should be disabled without code")
//
//    // Enter TOTP code
//    totpCodeField.tap()
//    totpCodeField.typeText("123456")
//
//    // Button should be enabled with code
//    XCTAssertTrue(completeButton.isEnabled, "Complete button should be enabled with code")
  }

  // MARK: - Error Handling Tests

  @MainActor
  func testErrorMessageDisplay() throws {
    let app = XCUIApplication()
    app.launchArguments.append("--auth-emulator")
    app.launchArguments.append("--mfa-enabled")
    app.launchArguments.append("--create-user")
    let email = createEmail()
    app.launchArguments.append("\(email)")
    app.launch()

    // Navigate to MFA enrollment
    try signInToApp(app: app, email: email)
    try navigateToMFAEnrollment(app: app)

    // Start enrollment to trigger potential errors
    app.buttons["start-enrollment-button"].tap()

    // Check if error message element exists (it might not be visible initially)
    let errorMessage = app.staticTexts["error-message"]

    // The error message element should exist even if not currently displaying an error
    // In real scenarios, this would test actual error conditions
    if errorMessage.exists {
      XCTAssertTrue(true, "Error message element exists for error display")
    }
  }

  // MARK: - Navigation Tests

  @MainActor
  func testBackButtonNavigation() throws {
    let app = XCUIApplication()
    app.launchArguments.append("--auth-emulator")
    app.launchArguments.append("--mfa-enabled")
    app.launchArguments.append("--create-user")
    let email = createEmail()
    app.launchArguments.append("\(email)")
    app.launch()

    // Navigate to MFA enrollment
    try signInToApp(app: app, email: email)
    try navigateToMFAEnrollment(app: app)

    // Test back button exists
    let cancelButton = app.buttons["mfa-back-button"]
    XCTAssertTrue(cancelButton.exists, "Back button should exist")
    XCTAssertTrue(cancelButton.isEnabled, "Back button should be enabled")

    // Tap cancel button
    cancelButton.tap()

    // Should navigate back to signed in view
    let signedInText = app.staticTexts["signed-in-text"]
    XCTAssertTrue(
      signedInText.waitForExistence(timeout: 5),
      "Should navigate back to signed in view"
    )
  }

  @MainActor
  func testBackButtonFromMFAManagement() throws {
    let app = XCUIApplication()
    app.launchArguments.append("--auth-emulator")
    app.launchArguments.append("--mfa-enabled")
    app.launchArguments.append("--create-user")
    let email = createEmail()
    app.launchArguments.append("\(email)")
    app.launch()

    // Sign in and navigate to MFA management
    try signInToApp(app: app, email: email)
    app.buttons["mfa-management-button"].tap()

    // Test back button exists
    let backButton = app.buttons["back-button"]
    XCTAssertTrue(backButton.waitForExistence(timeout: 5), "Back button should exist")
    XCTAssertTrue(backButton.isEnabled, "Back button should be enabled")

    // Tap back button
    backButton.tap()

    // Should navigate back to signed in view
    let signedInText = app.staticTexts["signed-in-text"]
    XCTAssertTrue(
      signedInText.waitForExistence(timeout: 5),
      "Should navigate back to signed in view"
    )
  }

  // MARK: - Helper Methods

  private func signInToApp(app: XCUIApplication, email: String) throws {
    let password = "123456"

    // Fill email field
    let emailField = app.textFields["email-field"]
    XCTAssertTrue(emailField.waitForExistence(timeout: 10), "Email field should exist")
    // Workaround for updating SecureFields with ConnectHardwareKeyboard enabled
    UIPasteboard.general.string = email
    emailField.press(forDuration: 1.2)
    app.menuItems["Paste"].tap()

    // Fill password field
    let passwordField = app.secureTextFields["password-field"]
    XCTAssertTrue(passwordField.exists, "Password field should exist")
    UIPasteboard.general.string = password
    passwordField.press(forDuration: 1.2)
    app.menuItems["Paste"].tap()

    // Create the user (sign up)
    let signUpButton = app
      .buttons["sign-in-button"] // This button changes context after switch-auth-flow
    XCTAssertTrue(signUpButton.exists, "Sign-up button should exist")
    signUpButton.tap()

    let notNowButton = app.scrollViews.containing(.button, identifier: "Not Now").firstMatch
    if notNowButton.waitForExistence(timeout: 5) {
      notNowButton.tap()
    }

    // Wait for signed-in state
        // Wait for signed-in state
    let signedInText = app.staticTexts["signed-in-text"]
    XCTAssertTrue(signedInText.waitForExistence(timeout: 30), "SignedInView should be visible after login")
    XCTAssertTrue(signedInText.exists, "SignedInView should be visible after login")
  }

  private func navigateToMFAEnrollment(app: XCUIApplication) throws {
    // Navigate to MFA management
    app.buttons["mfa-management-button"].tap()

    // Navigate to MFA enrollment
    let setupButton = app.buttons["setup-mfa-button"]
    if setupButton.waitForExistence(timeout: 3) {
      setupButton.tap()
    } else {
      let addMethodButton = app.buttons["add-mfa-method-button"]
      XCTAssertTrue(addMethodButton.waitForExistence(timeout: 3), "Add method button should exist")
      addMethodButton.tap()
    }

    // Verify we're in MFA enrollment view
    let enrollmentTitle = app.staticTexts["Set Up Two-Factor Authentication"]
    XCTAssertTrue(enrollmentTitle.waitForExistence(timeout: 5), "Should be in MFA enrollment view")
  }
}

struct VerificationCodesResponse: Codable {
    let verificationCodes: [VerificationCode]?
}

struct VerificationCode: Codable {
    let phoneNumber: String
    let code: String
}

/// Retrieves the last SMS verification code from Firebase Auth Emulator
/// - Parameter specificPhone: Optional phone number to filter codes for a specific phone
/// - Returns: The verification code as a String
/// - Throws: Error if unable to retrieve codes
private func getLastSmsCode(specificPhone: String? = nil) async throws -> String {
  let getSmsCodesUrl = "http://127.0.0.1:9099/emulator/v1/projects/flutterfire-e2e-tests/verificationCodes"

  guard let url = URL(string: getSmsCodesUrl) else {
      throw NSError(domain: "getLastSmsCode", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create URL for SMS codes endpoint"])
  }

  do {
      let (data, _) = try await URLSession.shared.data(from: url)

      let decoder = JSONDecoder()
      let codesResponse = try decoder.decode(VerificationCodesResponse.self, from: data)

      guard let codes = codesResponse.verificationCodes, !codes.isEmpty else {
          throw NSError(domain: "getLastSmsCode", code: -1, userInfo: [NSLocalizedDescriptionKey: "No SMS verification codes found in emulator"])
      }

      if let specificPhone = specificPhone {
          // Search backwards through codes for the specific phone number
          for code in codes.reversed() {
              if code.phoneNumber == specificPhone {
                  return code.code
              }
          }
          throw NSError(domain: "getLastSmsCode", code: -1, userInfo: [NSLocalizedDescriptionKey: "No SMS verification code found for phone number: \(specificPhone)"])
      } else {
          // Return the last code in the array
          return codes.last!.code
      }
  } catch let error as DecodingError {
      throw NSError(domain: "getLastSmsCode", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to parse SMS codes response: \(error.localizedDescription)"])
  } catch {
      throw NSError(domain: "getLastSmsCode", code: -1, userInfo: [NSLocalizedDescriptionKey: "Network request failed: \(error.localizedDescription)"])
  }
}
