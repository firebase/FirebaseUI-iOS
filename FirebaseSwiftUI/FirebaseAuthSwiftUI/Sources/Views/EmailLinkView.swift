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
      Text(authService.string.signInWithEmailLinkViewTitle)
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
          await sendEmailLink()
          authService.emailLink = email
        }
      }) {
        Text(authService.string.sendEmailLinkButtonLabel)
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
        Text(authService.string.signInWithEmailLinkViewMessage)
          .padding()
        Button(authService.string.okButtonLabel) {
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
    }) {
      Image(systemName: "chevron.left")
        .foregroundColor(.blue)
      Text(authService.string.backButtonLabel)
        .foregroundColor(.blue)
    })
  }
}
