import SwiftUI

public struct EmailPasswordButtonView: View {
  @Environment(AuthService.self) private var authService
  public init() {}

  public var body: some View {
    NavigationLink(destination: EmailPasswordView()
      .environment(authService)) {
        Text(authService
          .authenticationFlow == .login ? "Login with email" : "Sign up with email")
      }
  }
}
