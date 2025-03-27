@preconcurrency import FirebaseAuth
import SwiftUI

@MainActor
public class EmailPasswordAuthProvider {
  public init() {}

  func signIn(auth: Auth, email: String, password: String) async throws {
    let credential = EmailAuthProvider.credential(withEmail: email, password: password)
    try await auth.signIn(with: credential)
  }

  func createUser(auth: Auth, email: String, password: String) async throws {
    try await auth.createUser(withEmail: email, password: password)
  }
}
