import FirebaseCore
import SwiftUI

private struct ResultWrapper: Identifiable {
  let id = UUID()
  let value: Result<Void, Error>
}

public struct PasswordRecoveryView {
  @Environment(AuthService.self) private var authService
  @State private var email = ""
  @State private var resultWrapper: ResultWrapper?

  public init() {}

  private func sendPasswordRecoveryEmail() async {
    let recoveryResult: Result<Void, Error>

    do {
      try await authService.sendPasswordRecoveryEmail(to: email)
      resultWrapper = ResultWrapper(value: .success(()))
    } catch {
      resultWrapper = ResultWrapper(value: .failure(error))
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
      }
      .padding(.vertical, 6)
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
    }
    .sheet(item: $resultWrapper) { wrapper in
      resultSheet(wrapper.value)
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

  @ViewBuilder
  @MainActor
  private func resultSheet(_ result: Result<Void, Error>) -> some View {
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

        Text(String(format: authService.string.passwordRecoveryEmailSentMessage, email))
          .padding()

      case .failure:
        Text(authService.string.alertErrorTitle)
          .font(.title)
          .fontWeight(.semibold)
          .padding()

        Divider()

        Text(authService.errorMessage)
          .padding()
      }

      Divider()

      Button(authService.string.okButtonLabel) {
        self.resultWrapper = nil
      }
      .padding()
    }
    .padding()
  }
}

#Preview {
  FirebaseOptions.dummyConfigurationForPreview()
  return PasswordRecoveryView()
    .environment(AuthService())
}
