// Copyright 2025 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

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
  /// - UpdatePassword
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
  /// - UpdatePassword
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
  /// - SignedInView
  /// - UpdatePassword
  public var updatePasswordButtonLabel: String {
    return localizedString(for: "Update password")
  }

  /// Account settings - send email verification label
  /// found in:
  /// VerifyEmailView
  public var sendEmailVerificationButtonLabel: String {
    return localizedString(for: "Verify email address?")
  }

  /// Account settings - verify email sheet message
  /// found in:
  /// VerifyEmailView
  public var verifyEmailSheetMessage: String {
    return localizedString(for: "Verification email sent")
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

  /// Email provider
  /// found in:
  /// - AuthPickerView
  public var emailLoginFlowLabel: String {
    return localizedString(for: "Login")
  }

  /// Email provider
  /// found in:
  /// - AuthPickerView
  public var emailSignUpFlowLabel: String {
    return localizedString(for: "Sign up")
  }

  /// Email provider
  /// found in:
  /// - AuthPickerView
  public var dontHaveAnAccountYetLabel: String {
    return localizedString(for: "Don't have an account yet?")
  }

  /// Email provider
  /// found in:
  /// - AuthPickerView
  public var alreadyHaveAnAccountLabel: String {
    return localizedString(for: "Already have an account?")
  }

  /// Facebook provider
  /// found in:
  /// - SignInWithFacebookButton
  public var facebookLoginButtonLabel: String {
    return localizedString(for: "Continue with Facebook")
  }

  /// Facebook provider
  /// found in:
  /// - SignInWithFacebookButton
  public var facebookLoginCancelledLabel: String {
    return localizedString(for: "Facebook login cancelled")
  }

  /// Facebook provider
  /// found in:
  /// - SignInWithFacebookButton
  public var authorizeUserTrackingLabel: String {
    return localizedString(for: "Authorize User Tracking")
  }

  /// Facebook provider
  /// found in:
  /// - SignInWithFacebookButton
  public var facebookLimitedLoginLabel: String {
    return localizedString(for: "Limited Login")
  }

  /// Facebook provider
  /// found in:
  /// - SignInWithFacebookButton
  public var facebookAuthorizeUserTrackingMessage: String {
    return localizedString(for: "For classic Facebook login, please authorize user tracking.")
  }

  /// Phone provider
  /// found in:
  /// - PhoneAuthButtonView
  public var enterPhoneNumberLabel: String {
    return localizedString(for: "Enter phone number")
  }

  /// Phone provider
  /// found in:
  /// - PhoneAuthButtonView
  public var phoneNumberVerificationCodeLabel: String {
    return localizedString(for: "Enter verification code")
  }

  /// Phone provider
  /// found in:
  /// - PhoneAuthButtonView
  public var smsCodeSentLabel: String {
    return localizedString(for: "SMS code sent")
  }

  /// Phone provider
  /// found in:
  /// - PhoneAuthButtonView
  public var verifyPhoneNumberAndSignInLabel: String {
    return localizedString(for: "Verify phone number and sign-in")
  }

  /// Terms of Service label
  /// found in:
  /// - PrivacyTOCsView
  public var termsOfServiceLabel: String {
    return localizedString(for: "TermsOfService")
  }

  /// Terms of Service message
  /// found in:
  /// - PrivacyTOCsView
  public var termsOfServiceMessage: String {
    return localizedString(for: "TermsOfServiceMessage")
  }

  /// Privacy Policy
  /// found in:
  /// - PrivacyTOCsView
  public var privacyPolicyLabel: String {
    return localizedString(for: "PrivacyPolicy")
  }
}
