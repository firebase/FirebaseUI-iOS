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
      Text(authService.string.localizedString(for: kPasswordRecoveryTitle))
        .font(.largeTitle)
        .fontWeight(.bold)
        .padding()

      Divider()

      LabeledContent {
        TextField(authService.string.localizedString(for: kEnterYourEmail), text: $email)
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
        Text(authService.string.localizedString(for: kForgotPasswordInputLabel))
          .padding(.vertical, 8)
          .frame(maxWidth: .infinity)
      }
      .disabled(!CommonUtils.isValidEmail(email))
      .padding([.top, .bottom], 8)
      .frame(maxWidth: .infinity)
      .buttonStyle(.borderedProminent)
    }.sheet(isPresented: $showModal) {
      VStack {
        Text(authService.string.localizedString(for: kPasswordRecoveryEmailSentTitle))
          .font(.largeTitle)
          .fontWeight(.bold)
          .padding()
        Text(authService.string.localizedString(for: kPasswordRecoveryMessage))
          .padding()

        Divider()

        Text(authService.string.localizedString(for: kPasswordRecoveryEmailSentMessage))
          .padding()
        Button(authService.string.localizedString(for: kOK)) {
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
      Text(authService.string.localizedString(for: kBack))
        .foregroundColor(.blue)
    })
  }
}
