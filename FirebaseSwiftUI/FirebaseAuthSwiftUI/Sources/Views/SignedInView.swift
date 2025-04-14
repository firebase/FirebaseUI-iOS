import SwiftUI

public struct SignedInView {
  @Environment(AuthService.self) private var authService
  @State private var errorMessage = ""
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
        } catch {
          errorMessage = error.localizedDescription
        }
      }
    }
    Divider()
    Button("Delete account") {
      Task {
        do {
          try await authService.deleteUser()
        } catch {
          errorMessage = error.localizedDescription
        }
      }
    }
    Text(errorMessage).foregroundColor(.red)
  }
}
