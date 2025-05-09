import SwiftUI

@MainActor
public struct AuthPickerView {
  @Environment(AuthService.self) private var authService

  public init() {}

  private func switchFlow() {
    authService.authenticationFlow = authService
      .authenticationFlow == .login ? .signUp : .login
  }
}

extension AuthPickerView: View {
  public var body: some View {
    VStack {
      Text(authService.string.authPickerTitle)
        .font(.largeTitle)
        .fontWeight(.bold)
        .padding()
      if authService.authenticationState == .authenticated {
        SignedInView()
      } else if authService.authView == .passwordRecovery {
        PasswordRecoveryView()
      } else if authService.authView == .emailLink {
        EmailLinkView()
      } else {
        if authService.emailSignInEnabled {
          Text(authService.authenticationFlow == .login ? authService.string
            .emailLoginFlowLabel : authService.string.emailSignUpFlowLabel)
          VStack { Divider() }
          EmailAuthView()
        }
        authService.renderButtons()
        if authService.emailSignInEnabled {
          VStack { Divider() }
          HStack {
            Text(authService
              .authenticationFlow == .login ? authService.string.dontHaveAnAccountYetLabel :
              authService.string.alreadyHaveAnAccountLabel)
            Button(action: {
              withAnimation {
                switchFlow()
              }
            }) {
              Text(authService.authenticationFlow == .signUp ? authService.string
                .emailLoginFlowLabel : authService.string.emailSignUpFlowLabel)
                .fontWeight(.semibold)
                .foregroundColor(.blue)
            }
          }
          Text(authService.errorMessage).foregroundColor(.red)
        }
      }
    }
  }
}
