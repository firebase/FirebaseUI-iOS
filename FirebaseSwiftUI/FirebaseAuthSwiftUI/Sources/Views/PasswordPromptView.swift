import SwiftUI

struct PasswordPromptSheet {
  @Bindable var coordinator: PasswordPromptCoordinator
  @State private var password = ""
}

extension PasswordPromptSheet: View {
  var body: some View {
    VStack(spacing: 20) {
      SecureField("Enter Password", text: $password)
        .textFieldStyle(.roundedBorder)
        .padding()

      HStack {
        Button("Cancel") {
          coordinator.cancel()
        }
        Spacer()
        Button("Submit") {
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
