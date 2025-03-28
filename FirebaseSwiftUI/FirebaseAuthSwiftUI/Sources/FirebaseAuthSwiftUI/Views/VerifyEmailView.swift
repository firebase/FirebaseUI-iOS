import SwiftUI

public struct VerifyEmailView {
  @Environment(AuthService.self) private var authService
  @State private var errorMessage = ""
  @State private var showModal = false

  private func sendEmailVerification() async {
    do {
      try await authService.sendEmailVerification()
      showModal = true
    } catch {
      errorMessage = error.localizedDescription
    }
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
        Text("Verify email address?")
          .padding(.vertical, 8)
          .frame(maxWidth: .infinity)
      }
      .padding([.top, .bottom], 8)
      .frame(maxWidth: .infinity)
      .buttonStyle(.borderedProminent)
    }.sheet(isPresented: $showModal) {
      VStack {
        Text("Instructions")
          .font(.headline)
        Text("Please check your email for verification link.")
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
