import FirebaseAuthSwiftUI
import SwiftUI

@MainActor
public struct GoogleButtonView {
  @Environment(AuthService.self) private var authService
  @State private var errorMessage = ""

  public init() {}

  private func signInWithGoogle() async {
    do {
      try await authService.signInWithGoogle()
    } catch {
      errorMessage = StringUtils.localizedErrorMessage(
        for: error,
        configuration: authService.configuration
      )
    }
  }
}

extension GoogleButtonView: View {
  public var body: some View {
    Button(action: {
      Task {
        try await signInWithGoogle()
      }
    }) {
      if authService.authenticationState != .authenticating {
        Text(authService.authenticationFlow == .login ? "Login with Google" : "Sign-up with Google")
          .padding(.vertical, 8)
          .frame(maxWidth: .infinity)
      } else {
        ProgressView()
          .progressViewStyle(CircularProgressViewStyle(tint: .white))
          .padding(.vertical, 8)
          .frame(maxWidth: .infinity)
      }
    }
    Text(errorMessage).foregroundColor(.red)
  }
}
