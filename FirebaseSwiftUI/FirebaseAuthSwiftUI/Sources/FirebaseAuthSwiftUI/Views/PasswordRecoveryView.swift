import SwiftUI

public struct PasswordRecoveryView {
  @Environment(AuthEnvironment.self) private var authEnvironment
  @State private var email = ""
  @State private var errorMessage = ""
  @State private var showModal = false

  private var provider: EmailPasswordAuthProvider

  public init(provider: EmailPasswordAuthProvider) {
    self.provider = provider
  }

  private func sendPasswordRecoveryEmail() async {
    do {
      try await provider.sendPasswordRecoveryEmail(to: email)
      showModal = true
    } catch {
      errorMessage = error.localizedDescription
    }
  }
}

extension PasswordRecoveryView: View {
  public var body: some View {
    VStack {
      Text("Password Recovery")
      LabeledContent {
        TextField("Email", text: $email)
          .textInputAutocapitalization(.never)
          .disableAutocorrection(true)
          .submitLabel(.next)
      } label: {
        Image(systemName: "at")
      }.padding(.vertical, 6)
        .background(Divider(), alignment: .bottom)
        .padding(.bottom, 4)
      Button(action: {
        Task {
          await sendPasswordRecoveryEmail()
        }
      }) {
        Text("Password Recovery")
          .padding(.vertical, 8)
          .frame(maxWidth: .infinity)
      }
      .disabled(!EmailUtils.isValidEmail(email))
      .padding([.top, .bottom], 8)
      .frame(maxWidth: .infinity)
      .buttonStyle(.borderedProminent)
    }.sheet(isPresented: $showModal) {
      VStack {
        Text("Instructions")
          .font(.headline)
        Text("Please check your email for password recovery instructions.")
          .padding()
        Button("Dismiss") {
          showModal = false
        }
        .padding()
      }
      .padding()
    }
  }
}
