import SwiftUI

public struct SignedInView {
  @Environment(AuthService.self) private var authService
}

extension SignedInView: View {
  public var body: some View {
    VStack {
      Text("Signed in")
      Text("User: \(authService.currentUser?.email ?? "Unknown")")

      if authService.currentUser?.isEmailVerified == false {
        VerifyEmailView()
      }
    }
    Button("Sign out") {
      Task {
        do {
          try await authService.signOut()
        } catch {}
      }
    }
    Divider()
    Button("Delete account") {
      Task {
        do {
          try await authService.deleteUser()
        } catch {}
      }
    }
    Text(authService.errorMessage).foregroundColor(.red)
  }
}
