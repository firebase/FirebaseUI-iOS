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
        Text("Signed in")
        Text("User: \(authService.currentUser?.email ?? "Unknown")")

        if authService.currentUser?.isEmailVerified == false {
          VerifyEmailView()
        }
        Divider()
        Button("Update password") {
          authService.authView = .updatePassword
        }
        Divider()
        Button("Sign out") {
          Task {
            do {
              try await authService.signOut()
            } catch {}
          }
        }
        Divider()
        Button("Delete account") {
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
