import FirebaseAuthSwiftUI
import SwiftUI

class EmailUtils {
  static let emailRegex = ".+@([a-zA-Z0-9\\-]+\\.)+[a-zA-Z0-9]{2,63}"

  static func isValidEmail(_ email: String) -> Bool {
    let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
    return emailPredicate.evaluate(with: email)
  }
}

public struct EmailAuth: View {
  public init() {}
  public var body: some View {
    EmailAuthButton()
  }
}
