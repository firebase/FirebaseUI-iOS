import FirebaseAuthSwiftUI
import SwiftUI

class EmailUtils {
  static let emailRegex = ".+@([a-zA-Z0-9\\-]+\\.)+[a-zA-Z0-9]{2,63}"

  static func isValidEmail(_ email: String) -> Bool {
    let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
    return emailPredicate.evaluate(with: email)
  }
}

public struct EmailAuth<
  ButtonModifier: ViewModifier,
  TextModifier: ViewModifier,
  VStackModifier: ViewModifier
>: View {
  private var emailAuthButton: EmailAuthButton<ButtonModifier, TextModifier, VStackModifier>?

  public init(emailAuthButton: EmailAuthButton<ButtonModifier, TextModifier, VStackModifier>? =
    nil) {
    self.emailAuthButton = emailAuthButton
  }

  public var body: some View {
    if emailAuthButton != nil {
      emailAuthButton
    } else {
      EmailAuthButton<EmailAuthButtonModifier, EmailAuthTextModifier, EmailAuthVStackModifier>()
    }
  }
}
