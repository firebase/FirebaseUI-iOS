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

public class StringUtils {
  let bundle: Bundle
  init(bundle: Bundle) {
    self.bundle = bundle
  }

  public func localizedString(forKey key: String) -> String {
    return bundle.localizedString(forKey: key, value: nil, table: nil)
  }

  public func localizedErrorMessage(for error: Error) -> String {
    let authError = error as NSError
    let errorCode = AuthErrorCode(rawValue: authError.code)
    switch errorCode {
    case .emailAlreadyInUse:
      return localizedString(
        forKey: kEmailAlreadyInUseError
      )
    case .invalidEmail:
      return localizedString(forKey: kInvalidEmailError)
    case .weakPassword:
      return localizedString(forKey: kWeakPasswordError)
    case .tooManyRequests:
      return localizedString(
        forKey: kSignUpTooManyTimesError
      )
    case .wrongPassword:
      return localizedString(
        forKey: kWrongPasswordError
      )
    case .userNotFound:
      return localizedString(
        forKey: kUsersNotFoundError
      )
    case .userDisabled:
      return localizedString(
        forKey: kAccountDisabledError
      )
    default:
      return error.localizedDescription
    }
  }
}
