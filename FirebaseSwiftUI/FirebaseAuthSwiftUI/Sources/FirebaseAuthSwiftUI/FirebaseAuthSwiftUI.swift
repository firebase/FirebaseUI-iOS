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

// similar to FUIAuth in UIKit implementation
public class FirebaseAuthSwiftUI {
  private var auth: Auth
  private var authProviders: [FUIAuthProvider] = []

  public init(auth: Auth? = nil) {
    self.auth = auth ?? Auth.auth()
  }

  public func authProviders(providers: [FUIAuthProvider]) {
    authProviders = providers
  }

  public func providerWithId(providerId: String) throws -> FUIAuthProvider? {
    if let provider = authProviders.first(where: { $0.providerId == providerId }) {
      return provider
    } else {
      throw FUIError
        .providerNotFound(
          message: "Provider with ID \(providerId) not found. Did you add it to the authProviders array?"
        )
    }
  }
}

// main auth view - can be composed of custom views or fallback to default views. We can also pass
// state upwards as opposed to having callbacks.
// Negates the need for a delegate used in UIKit
public struct FUIAuthView: View {
  private var FUIAuth: FirebaseAuthSwiftUI
  private var authPickerView: AuthPickerView

  public init(FUIAuth: FirebaseAuthSwiftUI,
              _authPickerView: AuthPickerView? = nil) {
    self.FUIAuth = FUIAuth
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

public struct AuthPickerView: AuthPickerViewProtocol {
  private var emailAuthButton: EmailAuthButton

  public init(title: String? = nil, _emailAuthButton: EmailAuthButton? = nil) {
    emailAuthButton = _emailAuthButton ?? EmailAuthButton()
  }

  public var body: some View {
    VStack {
      title
      emailAuthButton
    }.padding(20)
      .background(Color.white)
      .cornerRadius(12)
      .shadow(radius: 10)
      .padding()
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

  public var body: some View {
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

  private func emailSubmit() {
    // TODO-
    // 1. need to be able to call providerWithId() function on FUIAuth. not sure whether to pass it
    // down. I think I kind have to if I want to make it composable.
    // 2. Create another view/alert which renders if email isn't valid
  }
}
