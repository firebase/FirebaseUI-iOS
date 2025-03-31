import FirebaseAuth
import SwiftUI

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

class StringUtils {
  static func localizedString(forKey key: String, configuration: AuthConfiguration) -> String {
    if let customStringsBundle = configuration.customStringsBundle {
      let localizedString = customStringsBundle.localizedString(
        forKey: key,
        value: kKeyNotFound,
        table: nil
      )

      if localizedString != key {
        return localizedString
      }
    }

    return Bundle.module.localizedString(forKey: key, value: nil, table: nil)
  }

  static func localizedErrorMessage(for error: Error, configuration: AuthConfiguration) -> String {
    let authError = error as NSError
    let errorCode = AuthErrorCode(rawValue: authError.code)
    switch errorCode {
    case .emailAlreadyInUse:
      return StringUtils.localizedString(
        forKey: kEmailAlreadyInUseError,
        configuration: configuration
      )
    case .invalidEmail:
      return StringUtils.localizedString(forKey: kInvalidEmailError, configuration: configuration)
    case .weakPassword:
      return StringUtils.localizedString(forKey: kWeakPasswordError, configuration: configuration)
    case .tooManyRequests:
      return StringUtils.localizedString(
        forKey: kSignUpTooManyTimesError,
        configuration: configuration
      )
    case .wrongPassword:
      return StringUtils.localizedString(
        forKey: kWrongPasswordError,
        configuration: configuration
      )
    case .userNotFound:
      return StringUtils.localizedString(
        forKey: kUsersNotFoundError,
        configuration: configuration
      )
    case .userDisabled:
      return StringUtils.localizedString(
        forKey: kAccountDisabledError,
        configuration: configuration
      )
    default:
      return StringUtils.localizedString(forKey: kUnknownError, configuration: configuration)
    }
  }
}
