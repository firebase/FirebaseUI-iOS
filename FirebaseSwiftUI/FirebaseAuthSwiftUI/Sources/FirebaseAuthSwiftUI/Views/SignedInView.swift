import SwiftUI

public struct SignedInView {
  @Environment(AuthService.self) private var authService
}

extension SignedInView: View {
  public var body: some View {
    VStack {
      Text("Signed in")
      Text("User: \(authService.currentUser?.email ?? "Unknown")")
      Button("Sign out") {
        Task {
          try? await authService.signOut()
        }
      }
      if authService.currentUser?.isEmailVerified == false {
        VerifyEmailView()
      }
    }
  }
}
