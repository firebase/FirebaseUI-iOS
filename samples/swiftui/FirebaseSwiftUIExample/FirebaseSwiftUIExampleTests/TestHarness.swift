//
//  TestHarness.swift
//  FirebaseSwiftUIExample
//
//  Created by Russell Wheatley on 16/05/2025.
//

import FirebaseAuth
import FirebaseCore

/// Call this at the beginning of any integration test to ensure Firebase is configured and pointed
/// to the Auth Emulator.
@MainActor
func configureFirebaseIfNeeded() {
  if FirebaseApp.app() == nil {
    FirebaseApp.configure()
  }
}

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
