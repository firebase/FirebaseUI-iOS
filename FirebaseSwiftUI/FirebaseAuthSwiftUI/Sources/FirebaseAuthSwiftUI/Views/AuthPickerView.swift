import SwiftUI

public struct AuthPickerView<Content: View>: View {
  @Environment(AuthEnvironment.self) private var authEnvironment
  let providerButtons: () -> Content

  public init(@ViewBuilder providerButtons: @escaping () -> Content) {
    self.providerButtons = providerButtons
  }

  private func switchFlow() {
    authEnvironment.authenticationFlow = authEnvironment
      .authenticationFlow == .login ? .signUp : .login
  }

  public var body: some View {
    VStack {
      if authEnvironment.authenticationState == .authenticated {
        SignedInView()
      } else {
        Text(authEnvironment.authenticationFlow == .login ? "Login" : "Sign up")
        providerButtons()
        HStack {
          Text(authEnvironment
            .authenticationFlow == .login ? "Don't have an account yet?" :
            "Already have an account?")
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
}
