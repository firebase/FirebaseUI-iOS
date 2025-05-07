import FirebaseAuth
import SwiftUI

public struct EmailLinkView {
  @Environment(AuthService.self) private var authService
  @State private var email = ""
  @State private var showModal = false

  public init() {}

  private func sendEmailLink() async {
    do {
      try await authService.sendEmailSignInLink(to: email)
      showModal = true
    } catch {}
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
          authService.emailLink = email
        }
      }) {
        Text("Send email sign-in link")
          .padding(.vertical, 8)
          .frame(maxWidth: .infinity)
      }
      .disabled(!CommonUtils.isValidEmail(email))
      .padding([.top, .bottom], 8)
      .frame(maxWidth: .infinity)
      .buttonStyle(.borderedProminent)
      Text(authService.errorMessage).foregroundColor(.red)
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
    }.onOpenURL { url in
      Task {
        do {
          try await authService.handleSignInLink(url: url)
        } catch {}
      }
    }
    .navigationBarItems(leading: Button(action: {
      authService.authView = .authPicker
    }, label: {
      Image(systemName: "chevron.left")
        .foregroundColor(.blue)
      Text("Back")
        .foregroundColor(.blue)
    }))
  }
}

#Preview {
  CommonUtils.dummyConfigurationForPreview()
  return EmailLinkView()
    .environment(AuthService())
}
