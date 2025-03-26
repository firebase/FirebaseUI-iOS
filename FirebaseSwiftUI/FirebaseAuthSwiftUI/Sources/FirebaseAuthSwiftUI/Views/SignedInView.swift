import SwiftUI


public struct SignedInView {
  @Environment(AuthEnvironment.self) private var authEnvironment
}

extension SignedInView: View {
  public var body: some View {
    VStack {
      Text("Signed in")
      Text("User: \(authEnvironment.currentUser?.email ?? "Unknown")")
      Button("Sign out") {
        Task {
          try? await authEnvironment.signOut()
        }
      }
    }
  }
}
