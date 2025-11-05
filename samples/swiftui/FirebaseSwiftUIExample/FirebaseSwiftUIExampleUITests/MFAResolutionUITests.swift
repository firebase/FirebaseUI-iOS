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
//  MFAResolutionUITests.swift
//  FirebaseSwiftUIExampleUITests
//
//  UI tests for MFA resolution workflows during sign-in
//

import XCTest

final class MFAResolutionUITests: XCTestCase {
  override func setUpWithError() throws {
    continueAfterFailure = false
  }

  // MARK: - MFA Resolution UI Tests

  // MARK: - Complete MFA Resolution Flow

  @MainActor
  func testCompleteMFAResolutionFlowWithAPIEnrollment() async throws {
    let app = createTestApp(mfaEnabled: true)
    app.launch()

    let email = createEmail()
    let password = "12345678"
    let phoneNumber = "+15551234567"

    // Sign up the user
    try await signUpUser(email: email, password: password)

    // Get ID token and enable MFA via API
    guard let idToken = await getIDTokenFromEmulator(email: email, password: password) else {
      XCTFail("Failed to get ID token from emulator")
      return
    }

    try await verifyEmailInEmulator(email: email, idToken: idToken)

    let mfaEnabled = await enableSMSMFAViaEmulator(
      idToken: idToken,
      phoneNumber: phoneNumber,
      displayName: "Test Phone"
    )

    XCTAssertTrue(mfaEnabled, "MFA should be enabled successfully via API")

    // Wait for sign out to complete
    let emailField = app.textFields["email-field"]
    XCTAssertTrue(emailField.waitForExistence(timeout: 10), "Should return to auth picker")

    try signInUser(app: app, email: email, password: password)

    let mfaResolutionTitle = app.staticTexts["mfa-resolution-title"]
    XCTAssertTrue(
      mfaResolutionTitle.waitForExistence(timeout: 10),
      "MFA resolution view should appear"
    )

    let smsButton = app.buttons["sms-method-button"]
    if smsButton.exists && smsButton.isEnabled {
      smsButton.tap()
    }
    dismissAlert(app: app)

    // Wait for SMS to be sent
    try await Task.sleep(nanoseconds: 2_000_000_000)

    let sendSMSButton = app.buttons["send-sms-button"]

    sendSMSButton.tap()

    try await Task.sleep(nanoseconds: 3_000_000_000)

    guard let verificationCode = await getSMSVerificationCode(
      for: phoneNumber,
      codeType: "verification"
    ) else {
      XCTFail("Failed to retrieve SMS verification code from emulator")
      return
    }

    let codeField = app.textFields["sms-verification-code-field"]
    XCTAssertTrue(codeField.waitForExistence(timeout: 10), "Code field should exist")
    codeField.tap()
    codeField.typeText(verificationCode)

    let completeButton = app.buttons["complete-resolution-button"]
    XCTAssertTrue(completeButton.exists, "Complete button should exist")
    completeButton.tap()

    // Wait for sign-in to complete
    // Resolution always fails due to ERROR_MULTI_FACTOR_INFO_NOT_FOUND exception. See below issue
    // for more information.
    // TODO(russellwheatley): uncomment below when this firebase-ios-sdk issue has been resolved: https://github.com/firebase/firebase-ios-sdk/issues/11079

    //    let signedInText = app.staticTexts["signed-in-text"]
    //    XCTAssertTrue(
    //      signedInText.waitForExistence(timeout: 10),
    //      "User should be signed in after MFA resolution"
    //    )
  }

  // MARK: - Helper Methods

  /// Programmatically enables SMS MFA for a user via the Auth emulator REST API
  /// - Parameters:
  ///   - idToken: The user's Firebase ID token
  ///   - phoneNumber: The phone number to enroll for SMS MFA (e.g., "+15551234567")
  ///   - displayName: Optional display name for the MFA factor
  /// - Returns: True if MFA was successfully enabled, false otherwise
  @MainActor
  private func enableSMSMFAViaEmulator(idToken: String,
                                       phoneNumber: String,
                                       displayName: String = "Test Phone") async -> Bool {
    let emulatorUrl =
      "http://127.0.0.1:9099/identitytoolkit.googleapis.com/v2/accounts/mfaEnrollment:start?key=fake-api-key"

    guard let url = URL(string: emulatorUrl) else {
      XCTFail("Invalid emulator URL")
      return false
    }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    let requestBody: [String: Any] = [
      "idToken": idToken,
      "phoneEnrollmentInfo": [
        "phoneNumber": phoneNumber,
        "recaptchaToken": "fake-recaptcha-token",
      ],
    ]

    guard let httpBody = try? JSONSerialization.data(withJSONObject: requestBody) else {
      XCTFail("Failed to serialize request body")
      return false
    }

    request.httpBody = httpBody

    // Step 1: Start MFA enrollment
    do {
      let (data, _) = try await URLSession.shared.data(for: request)

      // Step 1: Parse JSON
      guard let jsonObject = try? JSONSerialization.jsonObject(with: data) else {
        print("❌ Failed to parse JSON from response data")
        return false
      }

      guard let json = jsonObject as? [String: Any] else {
        print("❌ JSON is not a dictionary. Type: \(type(of: jsonObject))")
        return false
      }

      // Step 2: Extract phoneSessionInfo
      guard let info = json["phoneSessionInfo"] as? [String: Any] else {
        print("❌ Failed to extract 'phoneSessionInfo' from JSON")
        print("Available keys: \(json.keys.joined(separator: ", "))")
        if let phoneSessionInfo = json["phoneSessionInfo"] {
          print("phoneSessionInfo exists but wrong type: \(type(of: phoneSessionInfo))")
        }
        return false
      }

      // Step 3: Extract sessionInfo
      guard let sessionInfo = info["sessionInfo"] as? String else {
        print("❌ Failed to extract 'sessionInfo' from phoneSessionInfo")
        print("Available keys in phoneSessionInfo: \(info.keys.joined(separator: ", "))")
        if let sessionInfoValue = info["sessionInfo"] {
          print("sessionInfo exists but wrong type: \(type(of: sessionInfoValue))")
        }
        return false
      }

      // Step 2: Get verification code from emulator
      try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
      guard let verificationCode = await getSMSVerificationCode(for: phoneNumber) else {
        XCTFail("Failed to retrieve SMS verification code")
        return false
      }

      // Step 3: Finalize MFA enrollment
      let finalizeUrl =
        "http://127.0.0.1:9099/identitytoolkit.googleapis.com/v2/accounts/mfaEnrollment:finalize?key=fake-api-key"
      guard let finalizeURL = URL(string: finalizeUrl) else {
        return false
      }

      var finalizeRequest = URLRequest(url: finalizeURL)
      finalizeRequest.httpMethod = "POST"
      finalizeRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

      let finalizeBody: [String: Any] = [
        "idToken": idToken,
        "phoneVerificationInfo": [
          "sessionInfo": sessionInfo,
          "code": verificationCode,
        ],
        "displayName": displayName,
      ]

      guard let finalizeHttpBody = try? JSONSerialization.data(withJSONObject: finalizeBody) else {
        return false
      }

      finalizeRequest.httpBody = finalizeHttpBody

      let (finalizeData, finalizeResponse) = try await URLSession.shared.data(for: finalizeRequest)

      // Check HTTP status
      if let httpResponse = finalizeResponse as? HTTPURLResponse {
        print("📡 Finalize HTTP Status: \(httpResponse.statusCode)")
      }

      guard let json = try? JSONSerialization.jsonObject(with: finalizeData) as? [String: Any]
      else {
        print("❌ Failed to parse finalize response as JSON")
        return false
      }

      // Check if we have the new idToken and MFA info
      guard let newIdToken = json["idToken"] as? String else {
        print("❌ Missing 'idToken' in finalize response")
        return false
      }

      // Check if refreshToken is present
      if let refreshToken = json["refreshToken"] as? String {
        print("✅ Got refreshToken: \(refreshToken.prefix(20))...")
      }

      // Check for MFA info in response
      if let mfaInfo = json["mfaInfo"] {
        print("✅ MFA info in response: \(mfaInfo)")
      }

      return true

    } catch {
      print("Failed to enable MFA: \(error.localizedDescription)")
      return false
    }
  }

  /// Retrieves SMS verification codes from the Firebase Auth emulator
  /// - Parameters:
  ///   - phoneNumber: The phone number to retrieve the code for
  ///   - codeType: The type of code - "enrollment" for MFA enrollment, "verification" for phone
  /// verification during resolution
  @MainActor
  private func getSMSVerificationCode(for phoneNumber: String,
                                      codeType: String = "enrollment") async -> String? {
    let emulatorUrl =
      "http://127.0.0.1:9099/emulator/v1/projects/flutterfire-e2e-tests/verificationCodes"

    guard let url = URL(string: emulatorUrl) else {
      return nil
    }

    do {
      let (data, _) = try await URLSession.shared.data(from: url)

      guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let codes = json["verificationCodes"] as? [[String: Any]] else {
        print("❌ Failed to parse verification codes")
        return nil
      }

      // Filter codes by phone number and type, then get the most recent one
      let matchingCodes = codes.filter { codeInfo in
        guard let phone = codeInfo["phoneNumber"] as? String else {
          print("❌ Code missing phoneNumber field")
          return false
        }

        // The key difference between enrollment and verification codes:
        // - Enrollment codes have full phone numbers (e.g., "+15551234567")
        // - Verification codes have masked phone numbers (e.g., "+*******4567")
        let isMasked = phone.contains("*")

        // Match phone number
        let phoneMatches: Bool
        if isMasked {
          // Extract last 4 digits from both numbers
          let last4OfResponse = String(phone.suffix(4))
          let last4OfTarget = String(phoneNumber.suffix(4))
          phoneMatches = last4OfResponse == last4OfTarget
        } else {
          // Full phone number match
          phoneMatches = phone == phoneNumber
        }

        guard phoneMatches else {
          return false
        }

        if codeType == "enrollment" {
          // Enrollment codes have unmasked phone numbers
          return !isMasked
        } else { // "verification"
          // Verification codes have masked phone numbers
          return isMasked
        }
      }

      // Get the last matching code (most recent)
      if let lastCode = matchingCodes.last,
         let code = lastCode["code"] as? String {
        return code
      }

      print("❌ No matching code found")
      return nil

    } catch {
      print("Failed to fetch verification codes: \(error.localizedDescription)")
      return nil
    }
  }

  /// Gets an ID token for a user from the Auth emulator by signing in with email/password
  /// This works independently of the app's current auth state
  /// - Parameters:
  ///   - email: The user's email address
  ///   - password: The user's password (defaults to "123456")
  /// - Returns: The user's ID token, or nil if the sign-in failed
  @MainActor
  private func getIDTokenFromEmulator(email: String, password: String = "123456") async -> String? {
    let signInUrl =
      "http://127.0.0.1:9099/identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=fake-api-key"

    guard let url = URL(string: signInUrl) else {
      print("Invalid emulator URL")
      return nil
    }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    let requestBody: [String: Any] = [
      "email": email,
      "password": password,
      "returnSecureToken": true,
    ]

    guard let httpBody = try? JSONSerialization.data(withJSONObject: requestBody) else {
      print("Failed to serialize sign-in request body")
      return nil
    }

    request.httpBody = httpBody

    do {
      let (data, _) = try await URLSession.shared.data(for: request)

      guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let idToken = json["idToken"] as? String else {
        print("Failed to parse sign-in response")
        return nil
      }

      print("Successfully got ID token from emulator: \(idToken.prefix(20))...")
      return idToken

    } catch {
      print("Failed to get ID token from emulator: \(error.localizedDescription)")
      return nil
    }
  }

  @MainActor
  private func signUpUser(email: String, password: String = "12345678") async throws {
    // Create user via Auth Emulator REST API
    let url =
      URL(
        string: "http://127.0.0.1:9099/identitytoolkit.googleapis.com/v1/accounts:signUp?key=fake-api-key"
      )!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    let body: [String: Any] = [
      "email": email,
      "password": password,
      "returnSecureToken": true,
    ]
    request.httpBody = try JSONSerialization.data(withJSONObject: body)

    let (data, response) = try await URLSession.shared.data(for: request)

    guard let httpResponse = response as? HTTPURLResponse else {
      XCTFail("Invalid response")
      return
    }

    guard (200 ... 299).contains(httpResponse.statusCode) else {
      let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
      XCTFail("Failed to create user. Status: \(httpResponse.statusCode), Error: \(errorMessage)")
      return
    }
  }

  @MainActor private func signInUser(app: XCUIApplication, email: String,
                                     password: String = "123456") throws {
    // Ensure we're in sign in flow
    let switchFlowButton = app.buttons["switch-auth-flow"]
    if switchFlowButton.exists && switchFlowButton.label.contains("Sign In") {
      switchFlowButton.tap()
    }

    // Fill email field
    let emailField = app.textFields["email-field"]
    XCTAssertTrue(emailField.waitForExistence(timeout: 6))
    emailField.tap()
    emailField.clearAndEnterText(email)

    // Fill password field
    let passwordField = app.secureTextFields["password-field"]
    passwordField.tap()
    passwordField.clearAndEnterText(password)

    // Tap sign in button
    let signInButton = app.buttons["sign-in-button"]
    signInButton.tap()
  }

  @MainActor private func enrollSMSMFA(app: XCUIApplication) throws {
    // Navigate to MFA management
    let mfaManagementButton = app.buttons["mfa-management-button"]
    XCTAssertTrue(mfaManagementButton.waitForExistence(timeout: 5))
    mfaManagementButton.tap()

    // Tap add factor button
    let addFactorButton = app.buttons["add-factor-button"]
    XCTAssertTrue(addFactorButton.waitForExistence(timeout: 5))
    addFactorButton.tap()

    // Select SMS factor
    let factorPicker = app.segmentedControls["factor-type-picker"]
    XCTAssertTrue(factorPicker.waitForExistence(timeout: 5))
    factorPicker.buttons["SMS"].tap()

    // Start enrollment
    let startButton = app.buttons["start-enrollment-button"]
    startButton.tap()

    // Enter phone number
    let phoneField = app.textFields["phone-number-field"]
    XCTAssertTrue(phoneField.waitForExistence(timeout: 5))
    phoneField.tap()
    phoneField.typeText("+15551234567")

    // Send SMS
    let sendSMSButton = app.buttons["send-sms-button"]
    sendSMSButton.tap()

    // Enter verification code
    let codeField = app.textFields["sms-verification-code-field"]
    XCTAssertTrue(codeField.waitForExistence(timeout: 10))
    codeField.tap()
    codeField.typeText("123456") // This will work in emulator

    // Complete enrollment
    let completeButton = app.buttons["complete-enrollment-button"]
    completeButton.tap()

    // Wait for completion
    let successMessage = app.staticTexts
      .containing(NSPredicate(format: "label CONTAINS[cd] 'successfully enrolled'"))
    XCTAssertTrue(successMessage.firstMatch.waitForExistence(timeout: 10))

    // Go back to signed in view
    let backButton = app.buttons["back-button"]
    if backButton.exists {
      backButton.tap()
    }
  }
}

// MARK: - XCUIElement Extensions

extension XCUIElement {
  func clearAndEnterText(_ text: String) {
    guard let stringValue = value as? String else {
      XCTFail("Tried to clear and enter text into a non-string value")
      return
    }

    tap()

    let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)
    typeText(deleteString)
    typeText(text)
  }
}
