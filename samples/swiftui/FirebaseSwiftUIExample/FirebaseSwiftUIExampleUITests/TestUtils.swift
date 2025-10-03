import Foundation
import XCTest

func createEmail() -> String {
  let before = UUID().uuidString.prefix(8)
  let after = UUID().uuidString.prefix(6)
  return "\(before)@\(after).com"
}

func verifyEmailInEmulator(email: String,
                           idToken: String,
                           projectID: String = "flutterfire-e2e-tests",
                           emulatorHost: String = "localhost:9099") async throws {
  let base = "http://\(emulatorHost)"


  // Step 1: Trigger email verification (creates OOB code in emulator)
  var sendReq = URLRequest(
    url: URL(string: "\(base)/identitytoolkit.googleapis.com/v1/accounts:sendOobCode?key=fake-api-key")!
  )
  sendReq.httpMethod = "POST"
  sendReq.setValue("application/json", forHTTPHeaderField: "Content-Type")
  sendReq.httpBody = try JSONSerialization.data(withJSONObject: [
    "requestType": "VERIFY_EMAIL",
    "idToken": idToken
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
                  userInfo: [NSLocalizedDescriptionKey: "No VERIFY_EMAIL OOB code found for \(email)"])
  }


  // Step 4: Apply the OOB code (simulate clicking verification link)
  let verifyURL = URL(string: "\(base)/emulator/action?mode=verifyEmail&oobCode=\(oobCode)&apiKey=fake-api-key")!
  let (_, verifyResp) = try await URLSession.shared.data(from: verifyURL)
  guard (verifyResp as? HTTPURLResponse)?.statusCode == 200 else {
    throw NSError(domain: "EmulatorError", code: 4,
                  userInfo: [NSLocalizedDescriptionKey: "Failed to apply OOB code"])
  }
}