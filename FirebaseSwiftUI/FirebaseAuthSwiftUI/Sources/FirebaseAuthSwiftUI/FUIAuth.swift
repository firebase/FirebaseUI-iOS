import Combine
import FirebaseAuth
import FirebaseCore

// The Swift Programming Language
// https://docs.swift.org/swift-book
import SwiftUI

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
