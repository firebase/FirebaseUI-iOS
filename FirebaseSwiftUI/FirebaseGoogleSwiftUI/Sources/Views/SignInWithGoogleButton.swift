import FirebaseAuthSwiftUI
import SwiftUI

@MainActor
public struct SignInWithGoogleButton {
  @Environment(AuthService.self) private var authService
  @State private var errorMessage = ""

  public init() {}

  private func signInWithGoogle() async {
    do {
      try await authService.signInWithGoogle()
    } catch {
      errorMessage = authService.string.localizedErrorMessage(
        for: error
      )
    }
  }
}

extension SignInWithGoogleButton: View {
  public var body: some View {
    Button(action: {
      Task {
        try await signInWithGoogle()
      }
    }) {
      if authService.authenticationState != .authenticating {
        HStack {
          Image(systemName: "globe") // Placeholder for Google logo
            .resizable()
            .frame(width: 20, height: 20)
            .padding(.leading, 8)

          Text(authService
            .authenticationFlow == .login ? "Login with Google" : "Sign-up with Google")
            .foregroundColor(.black)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
        }
        .background(Color.white)
        .cornerRadius(8)
        .overlay(
          RoundedRectangle(cornerRadius: 8)
            .stroke(Color.gray, lineWidth: 1)
        )
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
