import FirebaseCore
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
    ScrollView {
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
          Divider()
          EmailLinkView()
        } else if authService.authView == .phoneAuth {
          // TODO: - how are we rendering the phone auth View??
        } else {
          Divider()
          if authService.emailSignInEnabled {
            Text(authService.authenticationFlow == .login ? authService.string
              .emailLoginFlowLabel : authService.string.emailSignUpFlowLabel)
            Divider()

            EmailAuthView()
          }
          VStack {
            authService.renderButtons()
          }.padding(.horizontal)

          VStack { Divider() }
          if authService.emailSignInEnabled {
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
          }
          PrivacyTOCsView(displayMode: .footer)
          Text(authService.errorMessage).foregroundColor(.red)
        }
      }
    }
  }
}

#Preview {
  FirebaseOptions.dummyConfigurationForPreview()
  let authService = AuthService()
    .withEmailSignIn()
  return AuthPickerView().environment(authService)
}
