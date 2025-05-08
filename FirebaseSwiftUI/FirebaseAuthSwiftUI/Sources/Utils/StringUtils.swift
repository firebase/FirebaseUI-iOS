import FirebaseAuth
import SwiftUI

let kKeyNotFound = "Key not found"


public class StringUtils {
  let bundle: Bundle
  init(bundle: Bundle) {
    self.bundle = bundle
  }

  public func localizedString(for key: String) -> String {
    let keyLocale = String.LocalizationValue(key)
    let value = String(localized: keyLocale, bundle: bundle)
    return value
  }

  public func localizedErrorMessage(for error: Error) -> String {
      let authError = error as NSError
      let errorCode = AuthErrorCode(rawValue: authError.code)
      switch errorCode {
      case .emailAlreadyInUse:
        return localizedString(
          for: "EmailAlreadyInUseError"
        )
      case .invalidEmail:
        return localizedString(for: "InvalidEmailError")
      case .weakPassword:
        return localizedString(for: "WeakPasswordError")
      case .tooManyRequests:
        return localizedString(
          for: "SignUpTooManyTimesError"
        )
      case .wrongPassword:
        return localizedString(
          for: "WrongPasswordError"
        )
      case .userNotFound:
        return localizedString(
          for: "UserNotFoundError"
        )
      case .userDisabled:
        return localizedString(
          for: "AccountDisabledError"
        )
      default:
        return error.localizedDescription
      }
    }

  /// Auth Picker title
  /// found in:
  /// - AuthPickerView
  public var authPickerTitle: String {
    return localizedString(for: "AuthPickerTitle")
  }

  /// Email input label
  /// found in:
  /// - EmailAuthView
  /// - PasswordRecoveryView
  /// - EmailLinkView
  public var emailInputLabel: String {
    return localizedString(for: "EnterYourEmail")
  }

  /// Password button action label
  /// found in:
  /// - EmailAuthView
  public var passwordButtonLabel: String {
    return localizedString(for: "ForgotPasswordTitle")
  }

  /// Password input label
  /// found in:
  /// - EmailAuthView
  /// - PasswordPromptView
  public var passwordInputLabel: String {
    return localizedString(for: "EnterYourPassword")
  }

  /// Password recovery title
  /// found in:
  /// - PasswordRecoveryView
  public var passwordRecoveryTitle: String {
    return localizedString(for: "PasswordRecoveryTitle")
  }

  /// Password recovery email sent title
  /// found in:
  /// - PasswordRecoveryView
  public var passwordRecoveryEmailSentTitle: String {
    return localizedString(for: "PasswordRecoveryEmailSentTitle")
  }

  /// Password recovery helper message
  /// found in:
  /// - PasswordRecoveryView
  public var passwordRecoveryHelperMessage: String {
    return localizedString(for: "PasswordRecoveryMessage")
  }

  /// Password recovery email sent message
  /// found in:
  /// - PasswordRecoveryView
  public var passwordRecoveryEmailSentMessage: String {
    return localizedString(for: "PasswordRecoveryEmailSentMessage")
  }

  /// Forgot password input label
  /// found in:
  /// - PasswordRecoveryView
  public var forgotPasswordInputLabel: String {
    return localizedString(for: "ForgotPassword")
  }

  /// Signed in title
  /// found in:
  /// - SignedInView
  public var signedInTitle: String {
    return localizedString(for: "SignedIn")
  }

  /// Confirm password
  /// found in:
  /// - EmailAuthView
  public var confirmPasswordInputLabel: String {
    return localizedString(for: "ConfirmPasswordInputLabel")
  }

  /// Sign in with email button label or can be used as title
  /// found in:
  /// - EmailAuthView
  public var signInWithEmailButtonLabel: String {
    return localizedString(for: "SignInWithEmail")
  }

  /// Sign up with email button label
  /// found in:
  /// - EmailAuthView
  public var signUpWithEmailButtonLabel: String {
    return localizedString(for: "SignUpTitle")
  }

  /// Sign-in with email link button label to push user to email link view
  /// found in:
  /// - EmailAuthView
  public var signUpWithEmailLinkButtonLabel: String {
    return localizedString(for: "EmailLinkSignInLabel")
  }

  /// send email link sign-in button label
  /// found in:
  /// - EmailLinkView
  public var sendEmailLinkButtonLabel: String {
    return localizedString(for: "SendEmailSignInLinkButtonLabel")
  }

  /// Sign in with email link View title
  /// found in:
  /// - EmailLinkView
  public var signInWithEmailLinkViewTitle: String {
    return localizedString(for: "EmailLinkSignInTitle")
  }

  /// Sign in with email link View message
  /// found in:
  /// - EmailLinkView
  public var signInWithEmailLinkViewMessage: String {
    return localizedString(for: "SignInEmailSent")
  }

  /// Account settings - Delete button label
  /// found in:
  /// - SignedInView
  public var deleteAccountButtonLabel: String {
    return localizedString(for: "AS_DeleteAccount")
  }

  /// Account settings - Email label
  /// found in:
  /// SignedInView
  public var accountSettingsEmailLabel: String {
    return localizedString(for: "AS_Email")
  }

  /// Account settings - sign out button label
  /// found in:
  /// - SignedInView
  public var signOutButtonLabel: String {
    return localizedString(for: "AS_SignOut")
  }
  
  /// Account settings - update password button label
  /// found in:
  /// SignedInView
  public var updatePasswordButtonLabel: String {
    return localizedString(for: "Update password")
  }
  

  /// General string - Back button label
  /// found in:
  /// - PasswordRecoveryView
  /// - EmailLinkView
  public var backButtonLabel: String {
    return localizedString(for: "Back")
  }

  /// General string - OK button label
  /// found in:
  /// - PasswordRecoveryView
  /// - EmailLinkView
  /// - PasswordPromptView
  public var okButtonLabel: String {
    return localizedString(for: "OK")
  }

  /// General string - Cancel button label
  /// found in:
  /// - PasswordPromptView
  public var cancelButtonLabel: String {
    return localizedString(for: "Cancel")
  }
}
