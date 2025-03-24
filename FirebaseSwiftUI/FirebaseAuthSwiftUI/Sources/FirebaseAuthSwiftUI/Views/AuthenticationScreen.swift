import FirebaseAuth
import SwiftUI

@MainActor
public struct AuthenticationScreen {
  @Environment(AuthEnvironment.self) private var authEnvironment
  @State private var errorMessage = ""

  public init() {}

  private func switchFlow() {
    authEnvironment.authenticationFlow = authEnvironment
      .authenticationFlow == .login ? .signUp : .login
    errorMessage = ""
  }
}

extension AuthenticationScreen: View {
  public var body: some View {
    VStack {
      Text(authEnvironment.authenticationFlow == .login ? "Login" : "Sign up")
      EmailPasswordView(provider: EmailAuthProvider(authEnvironment: authEnvironment))
      HStack {
        Text(authEnvironment
          .authenticationFlow == .login ? "Don't have an account yet?" : "Already have an account?")
        Button(action: {
          withAnimation {
            switchFlow()
          }
        }) {
          Text(authEnvironment.authenticationFlow == .signUp ? "Log in" : "Sign up")
            .fontWeight(.semibold)
            .foregroundColor(.blue)
        }
      }
    }
  }
}
