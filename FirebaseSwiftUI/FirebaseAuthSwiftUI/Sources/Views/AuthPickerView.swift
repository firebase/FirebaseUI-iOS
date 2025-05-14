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
        Text(authService.authenticationFlow == .login ? authService.string
          .emailLoginFlowLabel : authService.string.emailSignUpFlowLabel)
        VStack { Divider() }

        EmailAuthView()
        VStack {
          authService.renderButtons()
        }.padding(.horizontal)

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
        PrivacyTOCsView(displayMode: .footer)
        Text(authService.errorMessage).foregroundColor(.red)
      }
    }
  }
}
