import FirebaseAuth
import SwiftUI

let kAuthPickerTitle = "AuthPickerTitle"

let kEnterYourEmail = "EnterYourEmail"
let kEnterYourPassword = "EnterYourPassword"

let kSignedInTitle = "SignedIn"

let kKeyNotFound = "Key not found"

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
}
