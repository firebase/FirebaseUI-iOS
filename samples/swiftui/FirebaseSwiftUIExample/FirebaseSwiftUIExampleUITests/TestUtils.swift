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
@MainActor func createTestApp(mfaEnabled: Bool = false) -> XCUIApplication {
  let app = XCUIApplication()
  app.launchArguments.append("--test-view-enabled")
  if mfaEnabled {
    app.launchArguments.append("--mfa-enabled")
  }
  return app
}

// MARK: - Alert Handling

@MainActor func dismissAlert(app: XCUIApplication) {
  if app.scrollViews.otherElements.buttons["Not Now"].waitForExistence(timeout: 2) {
    app.scrollViews.otherElements.buttons["Not Now"].tap()
  }
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

  let (_, sendResp) = try await URLSession.shared.data(for: sendReq)
  guard let http = sendResp as? HTTPURLResponse, http.statusCode == 200 else {
    throw NSError(domain: "EmulatorError", code: 1,
                  userInfo: [NSLocalizedDescriptionKey: "Failed to send verification email"])
  }

  // Step 2: Fetch OOB codes from emulator
  let oobURL = URL(string: "\(base)/emulator/v1/projects/\(projectID)/oobCodes")!
  let (oobData, oobResp) = try await URLSession.shared.data(from: oobURL)
  guard (oobResp as? HTTPURLResponse)?.statusCode == 200 else {
    throw NSError(domain: "EmulatorError", code: 2,
                  userInfo: [NSLocalizedDescriptionKey: "Failed to fetch OOB codes"])
  }

  struct OobEnvelope: Decodable { let oobCodes: [OobItem] }
  struct OobItem: Decodable {
    let oobCode: String
    let email: String
    let requestType: String
    let creationTime: String?
  }

  let envelope = try JSONDecoder().decode(OobEnvelope.self, from: oobData)

  // Step 3: Find most recent VERIFY_EMAIL code for this email
  let iso = ISO8601DateFormatter()
  let codeItem = envelope.oobCodes
    .filter {
      $0.email.caseInsensitiveCompare(email) == .orderedSame && $0.requestType == "VERIFY_EMAIL"
    }
    .sorted {
      let d0 = $0.creationTime.flatMap { iso.date(from: $0) } ?? .distantPast
      let d1 = $1.creationTime.flatMap { iso.date(from: $0) } ?? .distantPast
      return d0 > d1
    }
    .first

  guard let oobCode = codeItem?.oobCode else {
    throw NSError(domain: "EmulatorError", code: 3,
                  userInfo: [
                    NSLocalizedDescriptionKey: "No VERIFY_EMAIL OOB code found for \(email)",
                  ])
  }

  // Step 4: Apply the OOB code (simulate clicking verification link)
  let verifyURL =
    URL(string: "\(base)/emulator/action?mode=verifyEmail&oobCode=\(oobCode)&apiKey=fake-api-key")!
  let (_, verifyResp) = try await URLSession.shared.data(from: verifyURL)
  guard (verifyResp as? HTTPURLResponse)?.statusCode == 200 else {
    throw NSError(domain: "EmulatorError", code: 4,
                  userInfo: [NSLocalizedDescriptionKey: "Failed to apply OOB code"])
  }
}
