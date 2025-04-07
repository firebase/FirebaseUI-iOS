import AppTrackingTransparency
import FacebookCore
import FacebookLogin
import FirebaseAuth
import FirebaseAuthSwiftUI
import SwiftUI

@MainActor
public struct FacebookButtonView {
  @Environment(AuthService.self) private var authService
  @State private var errorMessage = ""
  @State private var limitedLogin: Bool = false
  @State private var rawNonce: String
  @State private var shaNonce: String

  public init() {
    let nonce = FacebookUtils.randomNonce()
    _rawNonce = State(initialValue: nonce)
    _shaNonce = State(initialValue: FacebookUtils.sha256Hash(of: nonce))
  }

  private func classicLogin() async {
    do {
      if let token = AccessToken.current,
         !token.isExpired {
        let credential = FacebookAuthProvider
          .credential(withAccessToken: token.tokenString)
        try await authService.signIn(with: credential)
      } else {
        throw NSError(
          domain: "FacebookSwiftErrorDomain",
          code: 1,
          userInfo: [
            NSLocalizedDescriptionKey: "Access token has expired or not available. Please sign-in with Facebook before attempting to create a Facebook provider credential",
          ]
        )
      }
    } catch {
      errorMessage = authService.string.localizedErrorMessage(
        for: error
      )
    }
  }

  private func limitedLogin() async {
    do {
      if let idToken = AuthenticationToken.current {
        let credential = OAuthProvider.credential(withProviderID: kFacebookProviderId,
                                                  idToken: idToken.tokenString,
                                                  rawNonce: rawNonce)
        try await authService.signIn(with: credential)
      } else {
        throw NSError(
          domain: "FacebookSwiftErrorDomain",
          code: 2,
          userInfo: [
            NSLocalizedDescriptionKey: "Authentication is not available. Please sign-in with Facebook before attempting to create a Facebook provider credential",
          ]
        )
      }
    } catch {
      errorMessage = authService.string.localizedErrorMessage(
        for: error
      )
    }
  }
}

extension FacebookButtonView: View {
  public var body: some View {
    FacebookLoginButtonView(
      isLimitedLogin: $limitedLogin,
      shaNonce: $shaNonce,
      onLoginResult: { error in
        Task {
          if let error = error {
            errorMessage = authService.string.localizedErrorMessage(for: error)
          } else {
            // if not authorized, Facebook will default to limited login and classic login will fail
            let trackingStatus = ATTrackingManager.trackingAuthorizationStatus

            if limitedLogin || trackingStatus != .authorized {
              await limitedLogin()
            } else {
              await classicLogin()
            }
          }
        }
      }
    )
    Text(errorMessage).foregroundColor(.red)
  }
}

struct FacebookLoginButtonView: UIViewRepresentable {
  typealias UIViewType = FBLoginButton

  @Binding var isLimitedLogin: Bool
  @Binding var shaNonce: String
  var onLoginResult: (Error?) -> Void

  class Coordinator: NSObject, @preconcurrency LoginButtonDelegate {
    var parent: FacebookLoginButtonView

    init(_ parent: FacebookLoginButtonView) {
      self.parent = parent
    }

    @MainActor func loginButtonWillLogin(_ loginButton: FBLoginButton) -> Bool {
      loginButton.loginTracking = parent.isLimitedLogin ? .limited : .enabled
      loginButton.permissions = ["public_profile", "email"]

      loginButton.nonce = parent.shaNonce

      return true
    }

    @MainActor func loginButton(_: FBLoginButton,
                                didCompleteWith result: LoginManagerLoginResult?,
                                error: Error?) {
      if let error = error {
        parent.onLoginResult(error)
        return
      }

      guard let result = result, !result.isCancelled else {
        parent.onLoginResult(NSError(
          domain: "FacebookLogin",
          code: 1,
          userInfo: [NSLocalizedDescriptionKey: "Login was cancelled."]
        ))
        return
      }

      parent.onLoginResult(nil)
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
