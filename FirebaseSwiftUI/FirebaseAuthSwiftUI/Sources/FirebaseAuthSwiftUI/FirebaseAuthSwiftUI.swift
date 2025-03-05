// The Swift Programming Language
// https://docs.swift.org/swift-book
import SwiftUI
import FirebaseAuth
import FirebaseCore
import Combine

public protocol FUIAuthProvider {
  var providerId: String { get }
}

public class FirebaseAuthSwiftUI {
  private var auth: Auth
  private var authProviders: [FUIAuthProvider] = []

  public init(auth: Auth? = nil) {
      self.auth = auth ?? Auth.auth()
  }

  public func authProviders(providers: [FUIAuthProvider]) {
      self.authProviders = providers
  }
}

// main auth view - can be composed of custom views or fallback to default views. We can also pass state upwards as opposed to having callbacks.
// Negates the need for a delegate used in UIKit
public struct FUIAuthView: View {
  private var FUIAuth: FirebaseAuthSwiftUI
  private var authPickerView: any AuthPickerView
    

  public init(FUIAuth: FirebaseAuthSwiftUI,_authPickerView: some AuthPickerView = FUIAuthPicker()) {
    self.FUIAuth = FUIAuth
    self.authPickerView = _authPickerView

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
    self.emailAuthButton = _emailAuthButton ?? EmailProviderButton() as! any EmailAuthButton
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
              // Add the action you want to perform when the button is tapped
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
