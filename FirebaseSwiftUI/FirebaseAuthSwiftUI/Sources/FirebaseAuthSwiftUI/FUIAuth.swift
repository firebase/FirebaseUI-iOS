import Combine
import FirebaseAuth
import FirebaseCore

// The Swift Programming Language
// https://docs.swift.org/swift-book
import SwiftUI

enum FUIError: Error {
  case providerNotFound(message: String)
}

public protocol FUIAuthProvider {
  var providerId: String { get }
  var shortName: String { get }
  // TODO: - put customisable UI on the appropriate View
//  var signInLabel: String { get }
//  var icon: UIImage { get }
//  var buttonBackgroundColor: UIColor { get }
//  var buttonTextColor: UIColor { get }
//  var buttonAlignment: Alignment { get set }
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

class AuthUtils {
  static let emailRegex = ".+@([a-zA-Z0-9\\-]+\\.)+[a-zA-Z0-9]{2,63}"

  static func isValidEmail(_ email: String) -> Bool {
    let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
    return emailPredicate.evaluate(with: email)
  }
}

// similar to FUIAuth in UIKit implementation
public class FUIAuth: ObservableObject {
  private var auth: Auth
  private var authProviders: [FUIAuthProvider] = []

  public init(auth: Auth? = nil) {
    self.auth = auth ?? Auth.auth()
  }

  public func authProviders(providers: [FUIAuthProvider]) {
    authProviders = providers
  }

  public func getEmailProvider() -> EmailAuthProvider? {
    return try! providerWithId(providerId: "password") as! EmailAuthProvider
  }

  public func providerWithId(providerId: String) -> FUIAuthProvider? {
    if let provider = authProviders.first(where: { $0.providerId == providerId }) {
      return provider
    } else {
      assertionFailure(
        "Provider with ID \(providerId) not found. Did you add it to the authProviders array?"
      )
      return nil
    }
  }
}

// main auth view - can be composed of custom views or fallback to default views. We can also pass
// state upwards as opposed to having callbacks.
// Negates the need for a delegate used in UIKit
public struct FUIAuthView<Modifier: ViewModifier>: View {
  private var authFUI: FUIAuth
  private var authPickerView: AuthPickerView<Modifier>

  public init(FUIAuth: FUIAuth,
              _authPickerView: AuthPickerView<Modifier>? = nil) {
    authFUI = FUIAuth
    authPickerView = _authPickerView ?? AuthPickerView()
  }

  public var body: some View {
    VStack {
      AnyView(authPickerView)
    }
  }
}

public protocol AuthPickerViewProtocol: View {
  var title: AnyView { get }
}

public struct AuthPickerModifier: ViewModifier {
  public func body(content: Content) -> some View {
    content
      .padding(20)
      .background(Color.white)
      .cornerRadius(12)
      .shadow(radius: 10)
      .padding()
  }
}

public struct AuthPickerView<Modifier: ViewModifier>: AuthPickerViewProtocol {
  private var emailAuthButton: EmailAuthButton
  private var vStackModifier: Modifier

  public init(title _: String? = nil, _emailAuthButton: EmailAuthButton? = nil,
              _modifier: Modifier? = nil) {
    emailAuthButton = _emailAuthButton ?? EmailAuthButton()
    vStackModifier = _modifier ?? AuthPickerModifier() as! Modifier
  }

  public var body: some View {
    VStack {
      title
      emailAuthButton
    }.modifier(vStackModifier)
  }

  // Default implementation that can be overridden
  public var title: AnyView {
    AnyView(
      Text("Auth Picker view")
        .font(.largeTitle)
        .padding()
    )
  }
}

public protocol FUIButtonProtocol: View {
  var buttonContent: AnyView { get }
}

public struct EmailAuthButton: FUIButtonProtocol {
  @State private var emailAuthView = false
  public var body: some View {
    VStack {
      // TODO: - update FUIButtonProtocol with ways to align the button/have defaults
      Button(action: {
        emailAuthView = true
      }) {
        buttonContent
      }
      NavigationLink(destination: EmailEntryView(), isActive: $emailAuthView) {
        EmptyView()
      }
    }
  }

  // Default implementation that can be overridden
  public var buttonContent: AnyView {
    AnyView(
      Text("Sign in with email")
        .padding()
        .background(Color.red)
        .foregroundColor(.white)
        .cornerRadius(8)
    )
  }
}

public struct EmailEntryView: View {
  @State private var email: String = ""
  @State private var invalidEmailWarning: Bool = false
  @EnvironmentObject var authFUI: FUIAuth

  public var body: some View {
    if invalidEmailWarning {
      WarningView(invalidEmailWarning: $invalidEmailWarning, message: "Incorrect email address")
    } else {
      VStack {
        Text("Email")
          .font(.largeTitle)
          .padding()
        TextField("Email", text: $email, onCommit: emailSubmit)
          .textFieldStyle(RoundedBorderTextFieldStyle())
          .padding()
      }
      .padding(20)
      .background(Color.white)
      .cornerRadius(12)
      .shadow(radius: 10)
      .padding()
      // TODO: - figure out why this is causing exception: Ambiguous use of 'toolbar(content:)'
      //    .toolbar {
      //      ToolbarItemGroup(placement: .navigationBarTrailing) {
      //        Button("Next") {
      //          handleNext()
      //        }
      //      }
      //    }
    }
  }

  private func emailSubmit() {
//    var emailAuthProvider = authFUI.getEmailProvider()
    if !AuthUtils.isValidEmail(email) {
      invalidEmailWarning = true
    }

    // TODO-
    // 2. Create another view/alert which renders if email isn't valid
  }
}

public struct WarningView: View {
  @Binding var invalidEmailWarning: Bool
  var message: String

  public var body: some View {
    VStack {
      Text(message)
        .font(.headline)
        .padding()
      Button(action: {
        invalidEmailWarning = false
      }) {
        Text("OK")
          .font(.body)
          .padding()
          .background(Color.blue)
          .foregroundColor(.white)
          .cornerRadius(8)
      }
    }
    .frame(width: 300, height: 150)
    .background(Color.white)
    .cornerRadius(12)
    .shadow(radius: 10)
    .overlay(
      RoundedRectangle(cornerRadius: 12)
        .stroke(Color.gray, lineWidth: 1)
    )
    .padding()
  }
}

public struct FUIEmailProvider: FUIAuthProvider {
  public var providerId: String {
    return "email"
  }

  public var shortName: String {
    return "Email"
  }

  public var accessToken: String? {
    // Email Auth token is matched by FirebaseUI User Access Token
    return nil
  }

  public var idToken: String? {
    // Email Auth Token Secret is matched by FirebaseUI User Id Token
    return nil
  }

  public var credential: AuthCredential? = nil

  public var error: Error? = nil

  public var userInfo: [String: Any]? = nil

  public var isAuthenticated: Bool = false

  public init() {}

  public func signOut() {}

  public func email() -> String {
    // Return the email associated with the provider, if available
    return userInfo?["email"] as? String ?? ""
  }
}
