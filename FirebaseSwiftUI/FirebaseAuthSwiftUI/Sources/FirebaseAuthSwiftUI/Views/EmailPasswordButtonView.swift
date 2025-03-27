import SwiftUI

public struct EmailPasswordButtonView: View {
  @Environment(AuthEnvironment.self) private var authEnvironment
  public init() {}

  public var body: some View {
    NavigationLink(destination: EmailPasswordView()
      .environment(authEnvironment)) {
        Text(authEnvironment
          .authenticationFlow == .login ? "Login with email" : "Sign up with email")
      }
  }
}
