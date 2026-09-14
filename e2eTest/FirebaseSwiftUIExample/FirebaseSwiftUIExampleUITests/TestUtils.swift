import Foundation
import XCTest

// MARK: - Email Generation

func createEmail() -> String {
  let before = UUID().uuidString.prefix(8)
  let after = UUID().uuidString.prefix(6)
  return "\(before)@\(after).com"
}

// MARK: - App Configuration

/// Creates and configures an XCUIApplication with default test launch arguments
@MainActor func createTestApp(mfaEnabled: Bool = false,
                              legacyFetchSignInEnabled: Bool = false) -> XCUIApplication {
  let app = XCUIApplication()
  app.launchArguments.append("--test-view-enabled")
  if mfaEnabled {
    app.launchArguments.append("--mfa-enabled")
  }
  if legacyFetchSignInEnabled {
    app.launchArguments.append("--legacy-fetch-sign-in-enabled")
  }
  return app
}

// MARK: - Alert Handling

@MainActor func dismissAlert(app: XCUIApplication) {
  let notNowButton = app.buttons["Not Now"].firstMatch
  if notNowButton.waitForExistence(timeout: 5) {
    notNowButton.tap()
  }
}

// MARK: - Text Input Helpers

@MainActor private func waitForFieldValue(_ field: XCUIElement,
                                          expectedText: String,
                                          timeout: TimeInterval = 2) -> Bool {
  let deadline = Date().addingTimeInterval(timeout)

  while Date() < deadline {
    if (field.value as? String) == expectedText {
      return true
    }
    RunLoop.current.run(until: Date().addingTimeInterval(0.1))
  }

  return (field.value as? String) == expectedText
}

@MainActor private func showPasteMenu(for field: XCUIElement,
                                      text: String,
                                      app: XCUIApplication) throws -> XCUIElement {
  field.tap()

  // Give field time to become first responder.
  usleep(200_000) // 0.2 seconds

  // Press and hold to bring up paste menu.
  field.press(forDuration: 1.5)

  let pasteMenuItem = app.menuItems["Paste"]

  // Fallback to double-tap if the context menu did not appear.
  if !pasteMenuItem.waitForExistence(timeout: 3) {
    field.doubleTap()
    usleep(300_000) // 0.3 seconds

    if !pasteMenuItem.waitForExistence(timeout: 2) {
      throw NSError(
        domain: "TestError",
        code: 1,
        userInfo: [
          NSLocalizedDescriptionKey: "Failed to show paste menu for field. Text was: \(text)",
        ]
      )
    }
  }

  return pasteMenuItem
}

@MainActor private func typeIntoField(_ field: XCUIElement,
                                      text: String,
                                      app: XCUIApplication) throws {
  UIPasteboard.general.string = text
  let pasteMenuItem = try showPasteMenu(for: field, text: text, app: app)
  pasteMenuItem.tap()

  let success = waitForFieldValue(field, expectedText: text, timeout: 3)
  UIPasteboard.general.string = nil

  guard success else {
    throw NSError(
      domain: "TestError",
      code: 2,
      userInfo: [
        NSLocalizedDescriptionKey: "Failed to type expected text into field. Text was: \(text)",
      ]
    )
  }
}

@MainActor private func pasteIntoSecureField(_ field: XCUIElement,
                                             text: String,
                                             app: XCUIApplication) throws {
  let originalValue = field.value as? String
  UIPasteboard.general.string = text
  let pasteMenuItem = try showPasteMenu(for: field, text: text, app: app)
  pasteMenuItem.tap()

  // Poll until the value changes rather than relying on a fixed sleep.
  // Secure fields show bullet characters so we can only detect a change, not the exact value.
  let deadline = Date().addingTimeInterval(3.0)
  var pasted = false
  while Date() < deadline {
    if (field.value as? String) != originalValue {
      pasted = true
      break
    }
    RunLoop.current.run(until: Date().addingTimeInterval(0.1))
  }

  UIPasteboard.general.string = nil

  guard pasted else {
    throw NSError(
      domain: "TestError",
      code: 3,
      userInfo: [
        NSLocalizedDescriptionKey: "Failed to paste expected text into secure field. Text was: \(text)",
      ]
    )
  }
}

/// Enters text into a UI test field.
/// - Parameters:
///   - field: The XCUIElement representing the text field
///   - text: The text to enter
///   - app: The XCUIApplication instance
@MainActor func enterText(_ text: String, into field: XCUIElement, app: XCUIApplication) throws {
  switch field.elementType {
  case .secureTextField:
    try pasteIntoSecureField(field, text: text, app: app)
  default:
    try typeIntoField(field, text: text, app: app)
  }
}

@MainActor func waitForElementToBecomeEnabled(_ element: XCUIElement,
                                              timeout: TimeInterval = 5) -> Bool {
  let deadline = Date().addingTimeInterval(timeout)

  while Date() < deadline {
    if element.isEnabled {
      return true
    }
    RunLoop.current.run(until: Date().addingTimeInterval(0.1))
  }

  return element.isEnabled
}

// MARK: - User Creation

/// Helper to create a test user in the emulator via REST API (avoids keychain issues)
@MainActor func createTestUser(email: String, password: String = "123456",
                               verifyEmail: Bool = false) async throws {
  // Use Firebase Auth emulator REST API directly to avoid keychain access issues in UI tests
  let signUpUrl =
    "http://127.0.0.1:9099/identitytoolkit.googleapis.com/v1/accounts:signUp?key=fake-api-key"

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
    "returnSecureToken": true,
  ]

  request.httpBody = try JSONSerialization.data(withJSONObject: body)

  let (data, response) = try await URLSession.shared.data(for: request)

  guard let httpResponse = response as? HTTPURLResponse,
        httpResponse.statusCode == 200 else {
    let errorBody = String(data: data, encoding: .utf8) ?? "Unknown error"
    throw NSError(domain: "TestError", code: 2,
                  userInfo: [NSLocalizedDescriptionKey: "Failed to create user: \(errorBody)"])
  }

  // If email verification is requested, verify the email
  if verifyEmail {
    // Parse the response to get the idToken
    if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
       let idToken = json["idToken"] as? String {
      try await verifyEmailInEmulator(email: email, idToken: idToken)
    }
  }
}

// MARK: - Email Verification

private let authEmulatorProjectIDs = [
  "flutterfire-e2e-tests",
]

private func projectIDFromIDToken(_ idToken: String) -> String? {
  let segments = idToken.split(separator: ".")
  guard segments.count >= 2 else { return nil }

  var payload = String(segments[1])
    .replacingOccurrences(of: "-", with: "+")
    .replacingOccurrences(of: "_", with: "/")

  let paddingLength = (4 - payload.count % 4) % 4
  payload += String(repeating: "=", count: paddingLength)

  guard let payloadData = Data(base64Encoded: payload),
        let json = try? JSONSerialization.jsonObject(with: payloadData) as? [String: Any]
  else {
    return nil
  }

  return json["aud"] as? String
}

func authEmulatorCandidateProjectIDs(preferredProjectID: String? = nil,
                                     idToken: String? = nil) -> [String] {
  var projectIDs: [String] = []

  if let preferredProjectID, !preferredProjectID.isEmpty {
    projectIDs.append(preferredProjectID)
  }

  if let idToken, let tokenProjectID = projectIDFromIDToken(idToken) {
    projectIDs.append(tokenProjectID)
  }

  projectIDs.append(contentsOf: authEmulatorProjectIDs)

  var seen = Set<String>()
  return projectIDs.filter { seen.insert($0).inserted }
}

private struct OobEnvelope: Decodable { let oobCodes: [OobItem] }

private struct OobItem: Decodable {
  let oobCode: String
  let email: String
  let requestType: String
  let creationTime: String?
}

/// Fetches the most recent OOB code the emulator recorded for `email` and `requestType`.
/// Retries because the emulator registers the code asynchronously.
func fetchOobCode(email: String,
                  requestType: String,
                  projectID: String = "flutterfire-e2e-tests",
                  idToken: String? = nil,
                  emulatorHost: String = "127.0.0.1:9099",
                  maxAttempts: Int = 5) async throws -> String {
  let candidateProjectIDs = authEmulatorCandidateProjectIDs(
    preferredProjectID: projectID,
    idToken: idToken
  )
  let iso = ISO8601DateFormatter()
  var availableCodesByProject = ""

  for attempt in 1 ... maxAttempts {
    var availableCodes: [String] = []

    for candidateProjectID in candidateProjectIDs {
      guard let oobURL = URL(
        string: "http://\(emulatorHost)/emulator/v1/projects/\(candidateProjectID)/oobCodes"
      ),
      let (oobData, oobResp) = try? await URLSession.shared.data(from: oobURL),
            (oobResp as? HTTPURLResponse)?.statusCode == 200,
            let envelope = try? JSONDecoder().decode(OobEnvelope.self, from: oobData) else {
        continue
      }

      let match = envelope.oobCodes
        .filter {
          $0.email.caseInsensitiveCompare(email) == .orderedSame && $0.requestType == requestType
        }
        .sorted {
          let d0 = $0.creationTime.flatMap { iso.date(from: $0) } ?? .distantPast
          let d1 = $1.creationTime.flatMap { iso.date(from: $0) } ?? .distantPast
          return d0 > d1
        }
        .first

      if let match {
        return match.oobCode
      }

      availableCodes.append(contentsOf: envelope.oobCodes.map {
        "[\(candidateProjectID)] Email: \($0.email), Type: \($0.requestType)"
      })
    }

    availableCodesByProject = availableCodes.joined(separator: "; ")

    if attempt < maxAttempts {
      // Wait before retrying
      try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
    }
  }

  throw NSError(domain: "EmulatorError", code: 3,
                userInfo: [
                  NSLocalizedDescriptionKey: "No \(requestType) OOB code found for \(email) after \(maxAttempts) attempts. Available codes: \(availableCodesByProject)",
                ])
}

/// Verifies an email address in the emulator using the OOB code mechanism
@MainActor func verifyEmailInEmulator(email: String,
                                      idToken: String,
                                      projectID: String = "flutterfire-e2e-tests",
                                      emulatorHost: String = "127.0.0.1:9099") async throws {
  let base = "http://\(emulatorHost)"

  // Step 1: Trigger email verification (creates OOB code in emulator)
  var sendReq = URLRequest(
    url: URL(
      string: "\(base)/identitytoolkit.googleapis.com/v1/accounts:sendOobCode?key=fake-api-key"
    )!
  )
  sendReq.httpMethod = "POST"
  sendReq.setValue("application/json", forHTTPHeaderField: "Content-Type")
  sendReq.httpBody = try JSONSerialization.data(withJSONObject: [
    "requestType": "VERIFY_EMAIL",
    "idToken": idToken,
  ])

  let (sendData, sendResp) = try await URLSession.shared.data(for: sendReq)
  guard let http = sendResp as? HTTPURLResponse, http.statusCode == 200 else {
    let errorBody = String(data: sendData, encoding: .utf8) ?? "Unknown error"
    throw NSError(domain: "EmulatorError", code: 1,
                  userInfo: [
                    NSLocalizedDescriptionKey: "Failed to send verification email: \(errorBody)",
                  ])
  }

  // Add a small delay to ensure the OOB code is registered in the emulator
  try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds

  // Step 2: Fetch the OOB code the emulator recorded for this request.
  let oobCode = try await fetchOobCode(
    email: email,
    requestType: "VERIFY_EMAIL",
    projectID: projectID,
    idToken: idToken,
    emulatorHost: emulatorHost
  )

  // Step 4: Apply the OOB code (simulate clicking verification link)
  let verifyURL =
    URL(string: "\(base)/emulator/action?mode=verifyEmail&oobCode=\(oobCode)&apiKey=fake-api-key")!
  let (_, verifyResp) = try await URLSession.shared.data(from: verifyURL)
  guard (verifyResp as? HTTPURLResponse)?.statusCode == 200 else {
    throw NSError(domain: "EmulatorError", code: 4,
                  userInfo: [NSLocalizedDescriptionKey: "Failed to apply OOB code"])
  }
}


// MARK: - Legacy Sign-In Recovery

/// Creates a user that has BOTH `password` and `emailLink` sign-in methods.
///
/// `buildLegacySignInRecovery` returns nil when the only available sign-in method is the one that
/// was just attempted, so the recovery sheet is only ever presented for an account carrying a
/// second method. Completing an email-link sign-in is what attaches `emailLink` to the account.
@MainActor func createLegacyRecoveryUser(email: String,
                                         password: String = "123456",
                                         emulatorHost: String = "127.0.0.1:9099") async throws {
  try await createTestUser(email: email, password: password)

  let base = "http://\(emulatorHost)/identitytoolkit.googleapis.com/v1"

  guard let sendURL = URL(string: "\(base)/accounts:sendOobCode?key=fake-api-key") else {
    throw NSError(domain: "EmulatorError", code: 1,
                  userInfo: [NSLocalizedDescriptionKey: "Invalid sendOobCode URL"])
  }

  var sendReq = URLRequest(url: sendURL)
  sendReq.httpMethod = "POST"
  sendReq.setValue("application/json", forHTTPHeaderField: "Content-Type")
  sendReq.httpBody = try JSONSerialization.data(withJSONObject: [
    "requestType": "EMAIL_SIGNIN",
    "email": email,
    "continueUrl": "http://localhost",
  ])

  let (sendData, sendResp) = try await URLSession.shared.data(for: sendReq)
  guard (sendResp as? HTTPURLResponse)?.statusCode == 200 else {
    let errorBody = String(data: sendData, encoding: .utf8) ?? "Unknown error"
    throw NSError(domain: "EmulatorError", code: 1,
                  userInfo: [
                    NSLocalizedDescriptionKey: "Failed to send email-link sign-in code: \(errorBody)",
                  ])
  }

  let oobCode = try await fetchOobCode(
    email: email,
    requestType: "EMAIL_SIGNIN",
    emulatorHost: emulatorHost
  )

  guard let signInURL = URL(string: "\(base)/accounts:signInWithEmailLink?key=fake-api-key") else {
    throw NSError(domain: "EmulatorError", code: 2,
                  userInfo: [NSLocalizedDescriptionKey: "Invalid signInWithEmailLink URL"])
  }

  var signInReq = URLRequest(url: signInURL)
  signInReq.httpMethod = "POST"
  signInReq.setValue("application/json", forHTTPHeaderField: "Content-Type")
  signInReq.httpBody = try JSONSerialization.data(withJSONObject: [
    "email": email,
    "oobCode": oobCode,
  ])

  let (signInData, signInResp) = try await URLSession.shared.data(for: signInReq)
  guard (signInResp as? HTTPURLResponse)?.statusCode == 200 else {
    let errorBody = String(data: signInData, encoding: .utf8) ?? "Unknown error"
    throw NSError(domain: "EmulatorError", code: 2,
                  userInfo: [
                    NSLocalizedDescriptionKey: "Failed to complete email-link sign-in: \(errorBody)",
                  ])
  }
}
