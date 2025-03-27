import SwiftUI

public struct EmailLinkView {
  @Environment(AuthEnvironment.self) private var authEnvironment
  @State private var email = ""
  @State private var errorMessage = ""
  @State private var showModal = false

  private var provider: EmailPasswordAuthProvider

  public init(provider: EmailPasswordAuthProvider) {
    self.provider = provider
  }

  private func sendEmailLink() async {
    do {
//      try await provider.sendEmailSignInLink(to: email)
      showModal = true
    } catch {
      errorMessage = error.localizedDescription
    }
  }
}

extension EmailLinkView: View {
  public var body: some View {
    VStack {
      Text("Sign in with email link")
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
          await sendEmailLink()
        }
      }) {
        Text("Send email sign-in link")
          .padding(.vertical, 8)
          .frame(maxWidth: .infinity)
      }
      .disabled(!EmailUtils.isValidEmail(email))
      .padding([.top, .bottom], 8)
      .frame(maxWidth: .infinity)
      .buttonStyle(.borderedProminent)
      Text(errorMessage).foregroundColor(.red)
    }.sheet(isPresented: $showModal) {
      VStack {
        Text("Instructions")
          .font(.headline)
        Text("Please check your email for email sign-in link.")
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
