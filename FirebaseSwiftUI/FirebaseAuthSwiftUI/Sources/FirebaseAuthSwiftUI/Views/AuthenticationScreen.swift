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
      EmailPasswordView(provider: EmailAuthProvider()).environment(authEnvironment)
    }
  }
}
