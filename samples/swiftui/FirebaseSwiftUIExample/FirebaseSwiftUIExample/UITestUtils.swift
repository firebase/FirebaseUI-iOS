//
//  UITestUtils.swift
//  FirebaseSwiftUIExample
//
//  Created by Russell Wheatley on 16/05/2025.
//
import FirebaseAuth
import SwiftUI

// UI Test Runner keys
public let testRunner = CommandLine.arguments.contains("--auth-emulator")
let verifyEmail = CommandLine.arguments.contains("--verify-email")

public var testEmail: String? {
  guard let emailIndex = CommandLine.arguments.firstIndex(of: "--create-user"),
        CommandLine.arguments.indices.contains(emailIndex + 1)
  else { return nil }
  return CommandLine.arguments[emailIndex + 1]
}

func testCreateUser() async throws {
  if let email = testEmail {
    let password = "123456"
    let auth = Auth.auth()
    let result = try await auth.createUser(withEmail: email, password: password)
    if verifyEmail {
      try await setEmailVerifiedInEmulator(for: result.user)
    }
    try auth.signOut()
  }
}

/// Marks the given Firebase `user` as email-verified **in the Auth emulator**.
/// Works in CI even if the email address doesn't exist.
/// - Parameters:
///   - user: The signed-in Firebase user you want to verify.
///   - projectID: Your emulator project ID (e.g. "demo-project" or whatever you're using locally).
///   - emulatorHost: Host:port for the Auth emulator. Defaults to localhost:9099.
func setEmailVerifiedInEmulator(for user: User,
                                projectID: String = "flutterfire-e2e-tests",
                                emulatorHost: String = "localhost:9099") async throws {

  guard let email = user.email else {
    throw NSError(domain: "EmulatorError", code: 1,
                  userInfo: [
                    NSLocalizedDescriptionKey: "User has no email; cannot look up OOB code in emulator",
                  ])
  }

  // 1) Trigger a verification email -> creates an OOB code in the emulator.
  try await sendVerificationEmail(user)

  // 2) Read OOB codes from the emulator and find the VERIFY_EMAIL code for this user.
  let base = "http://\(emulatorHost)"
  let oobURL = URL(string: "\(base)/emulator/v1/projects/\(projectID)/oobCodes")!

  let (oobData, oobResp) = try await URLSession.shared.data(from: oobURL)
  guard (oobResp as? HTTPURLResponse)?.statusCode == 200 else {
    let body = String(data: oobData, encoding: .utf8) ?? ""
    throw NSError(domain: "EmulatorError", code: 2,
                  userInfo: [
                    NSLocalizedDescriptionKey: "Failed to fetch oobCodes. Response: \(body)",
                  ])
  }

  struct OobEnvelope: Decodable { let oobCodes: [OobItem] }
  struct OobItem: Decodable {
    let oobCode: String
    let email: String
    let requestType: String
    let creationTime: String? // RFC3339/ISO8601; optional for safety
  }

  let envelope = try JSONDecoder().decode(OobEnvelope.self, from: oobData)

  // Pick the most recent VERIFY_EMAIL code for this email (in case there are multiple).
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
                    NSLocalizedDescriptionKey: "No VERIFY_EMAIL oobCode found for \(email) in emulator",
                  ])
  }

  // 3) Apply the OOB code via the emulator's identitytoolkit endpoint.
  // Note: API key value does not matter when talking to the emulator.
  var applyReq = URLRequest(
    url: URL(string: "\(base)/identitytoolkit.googleapis.com/v1/accounts:update?key=anything")!
  )
  applyReq.httpMethod = "POST"
  applyReq.setValue("application/json", forHTTPHeaderField: "Content-Type")
  applyReq.httpBody = try JSONSerialization.data(withJSONObject: ["oobCode": oobCode], options: [])

  let (applyData, applyResp) = try await URLSession.shared.data(for: applyReq)
  guard let http = applyResp as? HTTPURLResponse, http.statusCode == 200 else {
    let body = String(data: applyData, encoding: .utf8) ?? ""
    throw NSError(domain: "EmulatorError", code: 4,
                  userInfo: [
                    NSLocalizedDescriptionKey: "Applying oobCode failed. Status \((applyResp as? HTTPURLResponse)?.statusCode ?? -1). Body: \(body)",
                  ])
  }

  log("Applied oobCode successfully; reloading user...")

  // 4) Reload the user to reflect the new verification state.
  try await user.reload()
  log("User reloaded. emailVerified after reload: \(user.isEmailVerified)")
}

/// Small async helper to call FirebaseAuth's callback-based `sendEmailVerification` on iOS.
private func sendVerificationEmail(_ user: User) async throws {
  try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
    user.sendEmailVerification { error in
      if let error = error {
        cont.resume(throwing: error)
      } else {
        cont.resume()
      }
    }
  }
}
