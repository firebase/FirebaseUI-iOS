
import FirebaseAuthSwiftUI
import SwiftUI

@MainActor
public struct SignInWithTwitterButton {
  @Environment(AuthService.self) private var authService

  public init() {}

  private func signInWithTwitter() async {
    do {
      try await authService.signInWithTwitter()
    } catch {}
  }
}

extension SignInWithTwitterButton: View {
  public var body: some View {
    Button(action: {
      Task {
        try await signInWithTwitter()
      }
    }) {
      if authService.authenticationState != .authenticating {
        HStack {
          Image("ic_twitter_black", bundle: .module)
            .resizable()
            .scaledToFit()
            .frame(width: 20, height: 20)
            .padding(.leading, 8)

          Text(authService.authenticationFlow == .login
            ? "Login with Twitter"
            : "Sign up with Twitter")
            .foregroundColor(.white)
            .fontWeight(.semibold)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
        }
        .background(Color(red: 29 / 255, green: 161 / 255, blue: 242 / 255))
        .cornerRadius(8)
        .accessibilityLabel("Sign in with Twitter")
      } else {
        ProgressView()
          .progressViewStyle(CircularProgressViewStyle(tint: .white))
          .padding(.vertical, 8)
          .frame(maxWidth: .infinity)
      }
    }
  }
}
