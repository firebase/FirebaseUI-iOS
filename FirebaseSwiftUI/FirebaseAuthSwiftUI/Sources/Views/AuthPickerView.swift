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

  @ViewBuilder
  private var authPickerTitleView: some View {
    if authService.authView == .authPicker {
      Text(authService.string.authPickerTitle)
        .font(.largeTitle)
        .fontWeight(.bold)
        .padding()
    }
  }
}

extension AuthPickerView: View {
  public var body: some View {
    ScrollView {
      VStack {
        authPickerTitleView
        if authService.authenticationState == .authenticated {
          SignedInView()
        } else {
          switch authService.authView {
          case .passwordRecovery:
            PasswordRecoveryView()
          case .emailLink:
            EmailLinkView()
          case .authPicker:
            if authService.emailSignInEnabled {
              Text(authService.authenticationFlow == .login ? authService.string
                .emailLoginFlowLabel : authService.string.emailSignUpFlowLabel)
              Divider()
              EmailAuthView()
            }
            VStack {
              authService.renderButtons()
            }.padding(.horizontal)
            if authService.emailSignInEnabled {
              Divider()
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
          default:
            // TODO: - possibly refactor this, see: https://github.com/firebase/FirebaseUI-iOS/pull/1259#discussion_r2105473437
            EmptyView()
          }
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
