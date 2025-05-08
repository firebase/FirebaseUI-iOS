import SwiftUI

@MainActor
public struct AuthPickerView<Content: View> {
  @Environment(AuthService.self) private var authService
  let providerButtons: () -> Content

  public init(@ViewBuilder providerButtons: @escaping () -> Content) {
    self.providerButtons = providerButtons
  }

  private func switchFlow() {
    authService.authenticationFlow = authService
      .authenticationFlow == .login ? .signUp : .login
  }
}

extension AuthPickerView: View {
  public var body: some View {
    VStack {
      if authService.authenticationState == .authenticated {
        SignedInView()
      } else if authService.authView == .passwordRecovery {
        PasswordRecoveryView()
      } else if authService.authView == .emailLink {
        EmailLinkView()
      } else {
        Text(authService.authenticationFlow == .login ? "Login" : "Sign up")
        VStack { Divider() }
        EmailAuthView()
        // Xcode compiler exception: Type 'any ExternalAuthProvider' cannot conform to 'ExternalAuthProvider'
        RenderButtonsView(providers: authService.availableProviders)
        VStack { Divider() }
        HStack {
          Text(authService
            .authenticationFlow == .login ? "Don't have an account yet?" :
            "Already have an account?")
          Button(action: {
            withAnimation {
              switchFlow()
            }
          }) {
            Text(authService.authenticationFlow == .signUp ? "Log in" : "Sign up")
              .fontWeight(.semibold)
              .foregroundColor(.blue)
          }
        }
        Text(authService.errorMessage).foregroundColor(.red)
      }
    }
  }
}
