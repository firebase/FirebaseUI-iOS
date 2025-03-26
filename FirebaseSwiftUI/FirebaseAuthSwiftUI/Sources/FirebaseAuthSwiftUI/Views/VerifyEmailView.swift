import SwiftUI

public struct VerifyEmailView {
  @Environment(AuthEnvironment.self) private var authEnvironment
  @State private var errorMessage = ""
  @State private var showModal = false

  private func sendEmailVerification() async {
    do {
      try await authEnvironment.sendEmailVerification()
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
        if authEnvironment.authenticationState != .authenticating {
          Text("Verify email address?")
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
        } else {
          ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: .white))
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
        }
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
