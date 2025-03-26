import SwiftUI

public struct EmailPasswordButtonView: View {
  @Environment(AuthEnvironment.self) private var authEnvironment
  private var provider: EmailPasswordAuthProvider
  public init(provider: EmailPasswordAuthProvider) {
    self.provider = provider
  }

  public var body: some View {
    NavigationLink(destination: EmailPasswordView(provider: provider)
      .environment(authEnvironment)) {
        Text(authEnvironment
          .authenticationFlow == .login ? "Login with email" : "Sign up with email")
      }
  }
}
