//
//  TestHarness.swift
//  FirebaseSwiftUIExample
//
//  Created by Russell Wheatley on 16/05/2025.
//

import FirebaseAuth
import FirebaseAuthSwiftUI
import FirebaseCore

@MainActor
func configureFirebaseIfNeeded() {
  if FirebaseApp.app() == nil {
    FirebaseApp.configure()
  }
}

@MainActor
private var hasCheckedEmulatorAvailability = false

@MainActor
func isEmulatorRunning() async throws {
  if hasCheckedEmulatorAvailability { return }
  let healthCheckURL = URL(string: "http://localhost:9099/")!
  var healthRequest = URLRequest(url: healthCheckURL)
  healthRequest.httpMethod = "HEAD"

  let session = URLSession(configuration: .ephemeral)
  let (_, response) = try await session.data(for: healthRequest)

  guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
    throw NSError(
      domain: "FirebaseAuthSwiftUITests",
      code: 1,
      userInfo: [
        NSLocalizedDescriptionKey: """
        🔌 Firebase Auth Emulator is not running on localhost:9099.
        Please run: `firebase emulators:start --only auth`
        """,
      ]
    )
  }
  Auth.auth().useEmulator(withHost: "localhost", port: 9099)
  hasCheckedEmulatorAvailability = true
}

@MainActor
func clearAuthEmulatorState(projectID: String = "flutterfire-e2e-tests") async throws {
  try await isEmulatorRunning()
  let url = URL(string: "http://localhost:9099/emulator/v1/projects/\(projectID)/accounts")!
  var request = URLRequest(url: url)
  request.httpMethod = "DELETE"
  let (_, response) = try await URLSession.shared.data(for: request)

  if let httpResponse = response as? HTTPURLResponse {
    print("🔥 clearAuthEmulatorState: status = \(httpResponse.statusCode)")
  }
}

func createEmail() -> String {
  let before = UUID().uuidString.prefix(8)
  let after = UUID().uuidString.prefix(6)
  return "\(before)@\(after).com"
}

@MainActor
func waitForStateChange(timeout: TimeInterval = 10.0,
                        condition: @escaping () -> Bool) async throws {
  let startTime = Date()

  while !condition() {
    if Date().timeIntervalSince(startTime) > timeout {
      throw TestError.timeout("Timeout waiting for condition to be met")
    }

    try await Task.sleep(nanoseconds: 50_000_000) // 50ms
  }
}

enum TestError: Error {
  case timeout(String)
}

@MainActor
func makeEmailLinkActionCodeSettings() -> ActionCodeSettings {
  let actionCodeSettings = ActionCodeSettings()
  actionCodeSettings.handleCodeInApp = true
  actionCodeSettings.url = URL(string: "https://flutterfire-e2e-tests.firebaseapp.com")
  actionCodeSettings.linkDomain = "flutterfire-e2e-tests.firebaseapp.com"
  actionCodeSettings.setIOSBundleID("io.flutter.plugins.firebase.auth.example")
  return actionCodeSettings
}

@MainActor
func createEmailLinkOnlyUser(email: String) async throws {
  configureFirebaseIfNeeded()
  try await isEmulatorRunning()

  let service = AuthService(
    configuration: AuthConfiguration(
      emailLinkSignInActionCodeSettings: makeEmailLinkActionCodeSettings()
    )
  )
    .withEmailLinkSignIn()

  service.emailLink = email
  try await service.sendEmailSignInLink(email: email)
  let signInLink = try await fetchEmailSignInLinkFromEmulator(email: email)
  try await service.handleSignInLink(url: signInLink)
  try await service.signOut()
}

@MainActor
func fetchEmailSignInLinkFromEmulator(email: String,
                                      projectID: String = "flutterfire-e2e-tests",
                                      emulatorHost: String = "127.0.0.1:9099") async throws -> URL {
  struct OobEnvelope: Decodable { let oobCodes: [OobItem] }
  struct OobItem: Decodable {
    let email: String
    let oobLink: String?
    let requestType: String
    let creationTime: String?
  }

  let oobURL = URL(string: "http://\(emulatorHost)/emulator/v1/projects/\(projectID)/oobCodes")!
  let iso = ISO8601DateFormatter()

  var attempts = 0
  let maxAttempts = 5

  while attempts < maxAttempts {
    let (oobData, oobResponse) = try await URLSession.shared.data(from: oobURL)
    guard (oobResponse as? HTTPURLResponse)?.statusCode == 200 else {
      throw NSError(
        domain: "EmulatorError",
        code: 10,
        userInfo: [NSLocalizedDescriptionKey: "Failed to fetch OOB codes for email sign-in"]
      )
    }

    let envelope = try JSONDecoder().decode(OobEnvelope.self, from: oobData)
    let oobLink = envelope.oobCodes
      .filter {
        $0.email.caseInsensitiveCompare(email) == .orderedSame && $0.requestType == "EMAIL_SIGNIN"
      }
      .sorted {
        let lhs = $0.creationTime.flatMap { iso.date(from: $0) } ?? .distantPast
        let rhs = $1.creationTime.flatMap { iso.date(from: $0) } ?? .distantPast
        return lhs > rhs
      }
      .compactMap(\.oobLink)
      .first

    if let oobLink,
       let encodedLink = oobLink.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
       let wrappedLink = URL(string: "https://example.com/?link=\(encodedLink)") {
      return wrappedLink
    }

    attempts += 1
    try await Task.sleep(nanoseconds: 500_000_000)
  }

  throw NSError(
    domain: "EmulatorError",
    code: 11,
    userInfo: [NSLocalizedDescriptionKey: "No EMAIL_SIGNIN OOB link found for \(email)"]
  )
}
