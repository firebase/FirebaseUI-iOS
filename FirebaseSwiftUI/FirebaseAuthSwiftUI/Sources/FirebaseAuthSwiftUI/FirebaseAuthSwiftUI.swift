import Combine
import FirebaseAuth
import FirebaseCore

// The Swift Programming Language
// https://docs.swift.org/swift-book
import SwiftUI

public protocol FUIAuthProvider {
  var providerId: String { get }
  var shortName: String { get }
  var signInLabel: String { get }
  var icon: UIImage { get }
  var buttonBackgroundColor: UIColor { get }
  var buttonTextColor: UIColor { get }
  var buttonAlignment: Alignment { get set }
  var accessToken: String? { get }
  var idToken: String? { get }

  // State properties passed upwards
  var credential: AuthCredential? { get set }
  var error: Error? { get set }
  var userInfo: [String: Any]? { get set }
  var isAuthenticated: Bool { get set }

  func signOut()

  func email() -> String

  // Removed handleOpenURL method as SwiftUI uses onOpenURL which is a view modifier
}

public class FirebaseAuthSwiftUI {
  private var auth: Auth
  private var authProviders: [FUIAuthProvider] = []

  public init(auth: Auth? = nil) {
    self.auth = auth ?? Auth.auth()
  }

  public func authProviders(providers: [FUIAuthProvider]) {
    authProviders = providers
  }
}

// main auth view - can be composed of custom views or fallback to default views. We can also pass
// state upwards as opposed to having callbacks.
// Negates the need for a delegate used in UIKit
public struct FUIAuthView: View {
  private var FUIAuth: FirebaseAuthSwiftUI
  private var authPickerView: any AuthPickerView

  public init(FUIAuth: FirebaseAuthSwiftUI,
              _authPickerView: some AuthPickerView = FUIAuthPicker()) {
    self.FUIAuth = FUIAuth
    authPickerView = _authPickerView
  }

  public var body: some View {
    VStack {
      AnyView(authPickerView)
    }
  }
}

public protocol AuthPickerView: View {
  var title: String { get }
}

public struct FUIAuthPicker: AuthPickerView {
  public var title: String
  private var emailAuthButton: any EmailAuthButton

  public init(title: String? = nil, _emailAuthButton: (any EmailAuthButton)? = nil) {
    self.title = title ?? "Auth Picker View"
    emailAuthButton = _emailAuthButton ?? EmailProviderButton() as! any EmailAuthButton
  }

  public var body: some View {
    VStack {
      Text(title)
        .font(.largeTitle)
        .padding()
      AnyView(emailAuthButton)
    }.padding(20)
      .background(Color.white)
      .cornerRadius(12)
      .shadow(radius: 10)
      .padding()
  }
}

public protocol EmailAuthButton: View {
  var text: String { get }
}

public struct EmailProviderButton: EmailAuthButton {
  public var text: String = "Sign in with email"
  public var body: some View {
    VStack {
      Button(action: {
        print("Email sign-in button tapped")
      }) {
        Text(text)
          .padding()
          .background(Color.red)
          .foregroundColor(.white)
          .cornerRadius(8)
      }
    }
  }
}
