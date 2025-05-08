import SwiftUI

struct PasswordPromptSheet {
  @Environment(AuthService.self) private var authService
  @Bindable var coordinator: PasswordPromptCoordinator
  @State private var password = ""
}

extension PasswordPromptSheet: View {
  var body: some View {
    VStack(spacing: 20) {
      SecureField(authService.string.passwordInputLabel, text: $password)
        .textFieldStyle(.roundedBorder)
        .padding()

      HStack {
        Button(authService.string.cancelButtonLabel) {
          coordinator.cancel()
        }
        Spacer()
        Button(authService.string.okButtonLabel) {
          coordinator.submit(password: password)
        }
        .disabled(password.isEmpty)
      }
      .padding(.horizontal)
    }
    .padding()
  }
}

#Preview {
  PasswordPromptSheet(coordinator: PasswordPromptCoordinator())
}
