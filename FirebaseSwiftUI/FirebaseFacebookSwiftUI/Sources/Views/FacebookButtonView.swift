import FacebookCore
import FacebookLogin
import FirebaseAuthSwiftUI
import SwiftUI

@MainActor
public struct FacebookButtonView {
  @Environment(AuthService.self) private var authService
  @State private var errorMessage = ""
  @State private var limitedLogin: Bool = true
  @State private var nonce: String? = FacebookUtils.randomNonce()

  public init() {}

  private func signInWithFacebook() async {}
}

extension FacebookButtonView: View {
  public var body: some View {
    Button(action: {
      Task {
        try await signInWithFacebook()
      }
    }) {
      FacebookLoginButtonView(
        isLimitedLogin: $limitedLogin,
        nonce: $nonce
      )
    }
    Text(errorMessage).foregroundColor(.red)
  }
}

struct FacebookLoginButtonView: UIViewRepresentable {
  typealias UIViewType = FBLoginButton

  @Binding var isLimitedLogin: Bool
  @Binding var nonce: String?

  class Coordinator: NSObject, @preconcurrency LoginButtonDelegate {
    var parent: FacebookLoginButtonView

    init(_ parent: FacebookLoginButtonView) {
      self.parent = parent
    }

    @MainActor func loginButtonWillLogin(_ loginButton: FBLoginButton) -> Bool {
      loginButton.loginTracking = parent.isLimitedLogin ? .limited : .enabled

      if let nonce = parent.nonce, !nonce.isEmpty {
        loginButton.nonce = nonce
      }

      return true
    }

    func loginButton(_: FBLoginButton,
                     didCompleteWith result: LoginManagerLoginResult?,
                     error: Error?) {
      if let error = error {
        print("Login Error: \(error.localizedDescription)")
        return
      }

      guard let result = result else {
        print("Invalid Login Result")
        return
      }

      if result.isCancelled {
        print("Login Cancelled")
        return
      }

      print("Login Successful")
    }

    func loginButtonDidLogOut(_: FBLoginButton) {
      print("User Logged Out")
    }
  }

  func makeCoordinator() -> Coordinator {
    return Coordinator(self)
  }

  func makeUIView(context: Context) -> FBLoginButton {
    let button = FBLoginButton()
    button.delegate = context.coordinator
    button.loginTracking = isLimitedLogin ? .limited : .enabled
    return button
  }

  func updateUIView(_ uiView: FBLoginButton, context _: Context) {
    uiView.loginTracking = isLimitedLogin ? .limited : .enabled
  }
}
