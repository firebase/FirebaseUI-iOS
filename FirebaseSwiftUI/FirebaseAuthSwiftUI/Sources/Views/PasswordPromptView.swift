import FirebaseCore
import SwiftUI

struct PasswordPromptSheet {
  @Environment(AuthService.self) private var authService
  @Bindable var coordinator: PasswordPromptCoordinator
  @State private var password = ""
}

extension PasswordPromptSheet: View {
  var body: some View {
    VStack(spacing: 20) {
      Text(authService.string.confirmPasswordInputLabel)
        .font(.largeTitle)
        .fontWeight(.bold)
        .padding()

      Divider()

      LabeledContent {
        TextField(authService.string.passwordInputLabel, text: $password)
          .textInputAutocapitalization(.never)
          .disableAutocorrection(true)
          .submitLabel(.next)
      } label: {
        Image(systemName: "lock")
      }.padding(.vertical, 10)
        .background(Divider(), alignment: .bottom)
        .padding(.bottom, 4)

      Button(action: {
        coordinator.submit(password: password)
      }) {
        Text(authService.string.okButtonLabel)
          .padding(.vertical, 8)
          .frame(maxWidth: .infinity)
      }
      .disabled(password.isEmpty)
      .padding([.top, .bottom, .horizontal], 8)
      .frame(maxWidth: .infinity)
      .buttonStyle(.borderedProminent)

      Button(authService.string.cancelButtonLabel) {
        coordinator.cancel()
      }
    }
    .padding()
  }
}

#Preview {
  FirebaseOptions.dummyConfigurationForPreview()
  return PasswordPromptSheet(coordinator: PasswordPromptCoordinator()).environment(AuthService())
}
