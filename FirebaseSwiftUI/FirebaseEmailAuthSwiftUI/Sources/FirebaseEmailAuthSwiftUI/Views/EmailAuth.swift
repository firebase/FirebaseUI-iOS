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
  EmailButtonStyle: ButtonStyle,
  EmailButtonTextStyleType: EmailButtonTextStyle
>: View {
  private var emailAuthButton: EmailAuthButton<EmailButtonStyle, EmailButtonTextStyleType>?
  public init(emailAuthButton: EmailAuthButton<EmailButtonStyle, EmailButtonTextStyleType>? = nil) {
    self.emailAuthButton = emailAuthButton
  }

  public var body: some View {
    if let emailAuthButton = emailAuthButton {
      emailAuthButton
    } else {
      EmailAuthButton<DefaultEmailAuthButtonStyle, DefaultEmailButtonTextStyle>(
        buttonStyle: DefaultEmailAuthButtonStyle(),
        buttonTextStyle: DefaultEmailButtonTextStyle()
      )
    }
  }
}
