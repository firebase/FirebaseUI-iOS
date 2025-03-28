import SwiftUI

public struct EmailPasswordButtonView: View {
  @Environment(AuthService.self) private var authService
  private var provider: EmailPasswordAuthProvider
  public init(provider: EmailPasswordAuthProvider) {
    self.provider = provider
  }

  public var body: some View {
    NavigationLink(destination: EmailPasswordView(provider: provider)
      .environment(authService)) {
        Text(authService
          .authenticationFlow == .login ? "Login with email" : "Sign up with email")
      }
  }
}
