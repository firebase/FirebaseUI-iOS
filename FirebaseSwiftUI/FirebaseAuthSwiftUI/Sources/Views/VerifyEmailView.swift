import FirebaseCore
import SwiftUI

public struct VerifyEmailView {
  @Environment(AuthService.self) private var authService
  @State private var showModal = false

  private func sendEmailVerification() async {
    do {
      try await authService.sendEmailVerification()
      showModal = true
    } catch {}
  }
}

extension VerifyEmailView: View {
  public var body: some View {
    VStack {
      Button(action: {
        Task {
          await sendEmailVerification()
        }
      }) {
        Text(authService.string.sendEmailVerificationButtonLabel)
          .padding(.vertical, 8)
          .frame(maxWidth: .infinity)
      }
      .padding([.top, .bottom, .horizontal], 8)
      .frame(maxWidth: .infinity)
      .buttonStyle(.borderedProminent)
    }.sheet(isPresented: $showModal) {
      VStack {
        Text(authService.string.verifyEmailSheetMessage)
          .font(.headline)
        Button(authService.string.okButtonLabel) {
          showModal = false
        }
        .padding()
      }
      .padding()
    }
  }
}

#Preview {
  FirebaseOptions.dummyConfigurationForPreview()
  return VerifyEmailView()
    .environment(AuthService())
}
