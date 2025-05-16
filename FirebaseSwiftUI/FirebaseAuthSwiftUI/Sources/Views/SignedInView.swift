import FirebaseCore
import SwiftUI

@MainActor
public struct SignedInView {
  @Environment(AuthService.self) private var authService
}

extension SignedInView: View {
  private var isShowingPasswordPrompt: Binding<Bool> {
    Binding(
      get: { authService.passwordPrompt.isPromptingPassword },
      set: { authService.passwordPrompt.isPromptingPassword = $0 }
    )
  }

  public var body: some View {
    if authService.authView == .updatePassword {
      UpdatePasswordView()
    } else {
      VStack {
        Text(authService.string.signedInTitle)
          .font(.largeTitle)
          .fontWeight(.bold)
          .padding()
          .accessibilityIdentifier("signed-in-text")
        Text(authService.string.accountSettingsEmailLabel)
        Text("\(authService.currentUser?.email ?? "Unknown")")

        if authService.currentUser?.isEmailVerified == false {
          VerifyEmailView()
        }
        Divider()
        Button(authService.string.updatePasswordButtonLabel) {
          authService.authView = .updatePassword
        }
        Divider()
        Button(authService.string.signOutButtonLabel) {
          Task {
            do {
              try await authService.signOut()
            } catch {}
          }
        }
        Divider()
        Button(authService.string.deleteAccountButtonLabel) {
          Task {
            do {
              try await authService.deleteUser()
            } catch {}
          }
        }
        Text(authService.errorMessage).foregroundColor(.red)
      }.sheet(isPresented: isShowingPasswordPrompt) {
        PasswordPromptSheet(coordinator: authService.passwordPrompt)
      }
    }
  }
}

#Preview {
  FirebaseOptions.dummyConfigurationForPreview()
  return SignedInView()
    .environment(AuthService())
}
