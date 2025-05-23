import FirebaseCore
import SwiftUI

enum PasswordRecoveryResult: Identifiable {
  case success
  case failure

  var id: String {
    switch self {
    case .success: return "success"
    case .failure: return "failure"
    }
  }
}

public struct PasswordRecoveryView {
  @Environment(AuthService.self) private var authService
  @State private var email = ""
  @State private var result: PasswordRecoveryResult?

  public init() {}

  private func sendPasswordRecoveryEmail() async {
    do {
      try await authService.sendPasswordRecoveryEmail(to: email)
      result = .success
    } catch {
      result = .failure
    }
  }
}

extension PasswordRecoveryView: View {
  public var body: some View {
    VStack {
      Text(authService.string.passwordRecoveryTitle)
        .font(.largeTitle)
        .fontWeight(.bold)
        .padding()

      Divider()

      LabeledContent {
        TextField(authService.string.emailInputLabel, text: $email)
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
        Text(authService.string.forgotPasswordInputLabel)
          .padding(.vertical, 8)
          .frame(maxWidth: .infinity)
      }
      .disabled(!CommonUtils.isValidEmail(email))
      .padding([.top, .bottom, .horizontal], 8)
      .frame(maxWidth: .infinity)
      .buttonStyle(.borderedProminent)
    }.sheet(item: $result) { result in
      VStack {
        switch result {
        case .success:
          Text(authService.string.passwordRecoveryEmailSentTitle)
            .font(.largeTitle)
            .fontWeight(.bold)
            .padding()
          Text(authService.string.passwordRecoveryHelperMessage)
            .padding()

          Divider()

          Text(authService.string.passwordRecoveryEmailSentMessage)
            .padding()
          Button(authService.string.okButtonLabel) {
            self.result = nil
          }
          .padding()
        case .failure:
          Text(authService.string.alertErrorTitle)
            .font(.title)
            .fontWeight(.semibold)
            .padding()

          Divider()

          Text(authService.errorMessage)
            .padding()

          Divider()

          Button(authService.string.okButtonLabel) {
            self.result = nil
          }
          .padding()
        }
      }
      .padding()
    }
    .navigationBarItems(leading: Button(action: {
      authService.authView = .authPicker
    }) {
      Image(systemName: "chevron.left")
        .foregroundColor(.blue)
      Text(authService.string.backButtonLabel)
        .foregroundColor(.blue)
    })
  }
}

#Preview {
  FirebaseOptions.dummyConfigurationForPreview()
  return PasswordRecoveryView()
    .environment(AuthService())
}
