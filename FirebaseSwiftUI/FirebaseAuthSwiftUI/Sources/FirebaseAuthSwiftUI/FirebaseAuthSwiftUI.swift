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
      // Use the provided Auth instance or default
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
  public init(title: String? = nil) {
    self.title = title ?? "Auth Picker View"
  }
    public var title: String = "Main View"
    public var body: some View {
        VStack {
            Text(title)
                .font(.largeTitle)
                .padding()
        }
    }
}
