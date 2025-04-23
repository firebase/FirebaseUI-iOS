import SwiftUI

public struct PasswordRecoveryView {
  @Environment(AuthService.self) private var authService
  @State private var email = ""
  @State private var showModal = false

  public init() {}

  private func sendPasswordRecoveryEmail() async {
    do {
      try await authService.sendPasswordRecoveryEmail(to: email)
      showModal = true
    } catch {}
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
      .disabled(!CommonUtils.isValidEmail(email))
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
    }.onOpenURL { _ in
      // move the user to email/password View
    }
    .navigationBarItems(leading: Button(action: {
      authService.authView = .authPicker
    }) {
      Image(systemName: "chevron.left")
        .foregroundColor(.blue)
      Text("Back")
        .foregroundColor(.blue)
    })
  }
}
