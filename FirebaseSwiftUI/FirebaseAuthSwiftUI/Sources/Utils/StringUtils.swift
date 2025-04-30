import FirebaseAuth
import SwiftUI

// Auth Picker (not signed-in)
let kAuthPickerTitle = "AuthPickerTitle"

// Used across multiple Views
let kEnterYourEmail = "EnterYourEmail"
let kEnterYourPassword = "EnterYourPassword"
let kOK = "OK"
let kBack = "Back"

// Signed-in
let kSignedInTitle = "SignedIn"

let kForgotPasswordButtonLabel = "ForgotPasswordTitle"
let kForgotPasswordInputLabel = "ForgotPassword"

// Password recovery
let kPasswordRecoveryTitle = "PasswordRecoveryTitle"
let kPasswordRecoveryEmailSentTitle = "PasswordRecoveryEmailSentTitle"
let kPasswordRecoveryMessage = "PasswordRecoveryMessage"
let kPasswordRecoveryEmailSentMessage = "PasswordRecoveryEmailSentMessage"

let kKeyNotFound = "Key not found"

// Errors
let kUsersNotFoundError = "UserNotFoundError"
let kEmailAlreadyInUseError = "EmailAlreadyInUseError"
let kInvalidEmailError = "InvalidEmailError"
let kWeakPasswordError = "WeakPasswordError"
let kSignUpTooManyTimesError = "SignUpTooManyTimesError"
let kWrongPasswordError = "WrongPasswordError"
let kAccountDisabledError = "AccountDisabledError"
let kEmailsDoNotMatchError = "EmailsDoNotMatchError"
let kUnknownError = "UnknownError"

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
        for: kEmailAlreadyInUseError
      )
    case .invalidEmail:
      return localizedString(for: kInvalidEmailError)
    case .weakPassword:
      return localizedString(for: kWeakPasswordError)
    case .tooManyRequests:
      return localizedString(
        for: kSignUpTooManyTimesError
      )
    case .wrongPassword:
      return localizedString(
        for: kWrongPasswordError
      )
    case .userNotFound:
      return localizedString(
        for: kUsersNotFoundError
      )
    case .userDisabled:
      return localizedString(
        for: kAccountDisabledError
      )
    default:
      return error.localizedDescription
    }
  }

  /// Auth Picker title
  /// found in:
  /// - AuthPickerView
  public var authPickerTitle: String {
    return localizedString(for: kAuthPickerTitle)
  }

  /// Email input label
  /// found in:
  /// - EmailAuthView
  /// - PasswordRecoveryView
  public var emailInputLabel: String {
    return localizedString(for: kEnterYourEmail)
  }

  /// Password button action label
  /// found in:
  /// - EmailAuthView
  public var passwordButtonLabel: String {
    return localizedString(for: kForgotPasswordButtonLabel)
  }

  /// Password input label
  /// found in:
  /// - EmailAuthView
  public var passwordInputLabel: String {
    return localizedString(for: kEnterYourPassword)
  }

  /// Password recovery title
  /// found in:
  /// - PasswordRecoveryView
  public var passwordRecoveryTitle: String {
    return localizedString(for: kPasswordRecoveryTitle)
  }

  /// Password recovery email sent title
  /// found in:
  /// - PasswordRecoveryView
  public var passwordRecoveryEmailSentTitle: String {
    return localizedString(for: kPasswordRecoveryEmailSentTitle)
  }

  /// Password recovery helper message
  /// found in:
  /// - PasswordRecoveryView
  public var passwordRecoveryHelperMessage: String {
    return localizedString(for: kPasswordRecoveryMessage)
  }

  /// Password recovery email sent message
  /// found in:
  /// - PasswordRecoveryView
  public var passwordRecoveryEmailSentMessage: String {
    return localizedString(for: kPasswordRecoveryEmailSentMessage)
  }

  /// Forgot password input label
  /// found in:
  /// - PasswordRecoveryView
  public var forgotPasswordInputLabel: String {
    return localizedString(for: kForgotPasswordInputLabel)
  }

  /// Signed in title
  /// found in:
  /// - SignedInView
  public var signedInTitle: String {
    return localizedString(for: kSignedInTitle)
  }

  /// General string - Back button label
  /// found in:
  /// - PasswordRecoveryView
  public var backButtonLabel: String {
    return localizedString(for: kBack)
  }

  /// General string - OK button label
  /// found in:
  /// - PasswordRecoveryView
  public var okButtonLabel: String {
    return localizedString(for: kOK)
  }
}
