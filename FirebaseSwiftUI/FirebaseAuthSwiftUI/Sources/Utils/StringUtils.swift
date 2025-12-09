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
  let fallbackBundle: Bundle
  let languageCode: String?

  init(bundle: Bundle, languageCode: String? = nil) {
    self.bundle = bundle
    self.fallbackBundle = Bundle.module  // Always fall back to the package's default strings
    self.languageCode = languageCode
  }

  public func localizedString(for key: String) -> String {
    // If a specific language code is set, load strings from that language bundle
    if let languageCode, let path = bundle.path(forResource: languageCode, ofType: "lproj"),
       let localizedBundle = Bundle(path: path) {
      let localizedString = localizedBundle.localizedString(forKey: key, value: nil, table: "Localizable")
      // If string was found in custom bundle, return it
      if localizedString != key {
        return localizedString
      }
      
      // Fall back to fallback bundle with same language
      if let fallbackPath = fallbackBundle.path(forResource: languageCode, ofType: "lproj"),
         let fallbackLocalizedBundle = Bundle(path: fallbackPath) {
        return fallbackLocalizedBundle.localizedString(forKey: key, value: nil, table: "Localizable")
      }
    }

    // Try default localization from custom bundle
    let keyLocale = String.LocalizationValue(key)
    let localizedString = String(localized: keyLocale, bundle: bundle)
    
    // If the string was found in custom bundle (not just the key returned), use it
    if localizedString != key {
      return localizedString
    }
    
    // Fall back to the package's default strings
    return String(localized: keyLocale, bundle: fallbackBundle)
  }

  public func localizedErrorMessage(for error: Error) -> String {
    let authError = error as NSError
    let errorCode = AuthErrorCode(rawValue: authError.code)
    switch errorCode {
    case .emailAlreadyInUse:
      return localizedString(
        for: "The email address is already in use by another account."
      )
    case .invalidEmail:
      return localizedString(for: "That email address isn't correct.")
    case .weakPassword:
      return localizedString(for: "Password must be at least 6 characters long.")
    case .tooManyRequests:
      return localizedString(
        for: "SignUpTooManyTimesError"
      )
    case .wrongPassword:
      return localizedString(
        for: "The email and password you entered don't match."
      )
    case .userNotFound:
      return localizedString(
        for: "That email address doesn't match an existing account."
      )
    case .userDisabled:
      return localizedString(
        for: "That email address is for an account that has been disabled."
      )
    default:
      return error.localizedDescription
    }
  }

  /// Auth Picker title
  /// found in:
  /// - AuthPickerView
  public var authPickerTitle: String {
    return localizedString(for: "Sign in with Firebase")
  }

  /// Email input label
  /// found in:
  /// - EmailAuthView
  /// - PasswordRecoveryView
  /// - EmailLinkView
  public var emailInputLabel: String {
    return localizedString(for: "Enter your email")
  }

  /// Password button action label
  /// found in:
  /// - EmailAuthView
  public var passwordButtonLabel: String {
    return localizedString(for: "Trouble signing in?")
  }

  /// Password input label
  /// found in:
  /// - EmailAuthView
  /// - PasswordPromptView
  /// - UpdatePassword
  public var passwordInputLabel: String {
    return localizedString(for: "Enter your password")
  }

  /// Update password title
  /// found in:
  /// - UpdatePasswordView
  public var updatePasswordTitle: String {
    return localizedString(for: "UpdatePasswordTitle")
  }

  /// Password recovery title
  /// found in:
  /// - PasswordRecoveryView
  public var passwordRecoveryTitle: String {
    return localizedString(for: "Recover password")
  }

  /// Password recovery email sent title
  /// found in:
  /// - PasswordRecoveryView
  public var passwordRecoveryEmailSentTitle: String {
    return localizedString(for: "Check your email")
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
    return localizedString(for: "Send password recovery email")
  }

  /// Signed in title
  /// found in:
  /// - SignedInView
  public var signedInTitle: String {
    return localizedString(for: "Signed in!")
  }

  /// Confirm password
  /// found in:
  /// - EmailAuthView
  /// - UpdatePassword
  public var confirmPasswordInputLabel: String {
    return localizedString(for: "Confirm Password")
  }

  /// Sign in with email button label or can be used as title
  /// found in:
  /// - EmailAuthView
  public var signInWithEmailButtonLabel: String {
    return localizedString(for: "Sign in with email")
  }

  /// Sign up with email button label
  /// found in:
  /// - EmailAuthView
  public var signUpWithEmailButtonLabel: String {
    return localizedString(for: "Create account")
  }

  /// Sign-in with email link button label to push user to email link view
  /// found in:
  /// - EmailAuthView
  public var signUpWithEmailLinkButtonLabel: String {
    return localizedString(for: "Prefer Email link sign-in?")
  }

  /// send email link sign-in button label
  /// found in:
  /// - EmailLinkView
  public var sendEmailLinkButtonLabel: String {
    return localizedString(for: "Send email sign-in link")
  }

  /// Sign in with email link View title
  /// found in:
  /// - EmailLinkView
  public var signInWithEmailLinkViewTitle: String {
    return localizedString(for: "Sign in with email link")
  }

  /// Sign in with email link View message
  /// found in:
  /// - EmailLinkView
  public var signInWithEmailLinkViewMessage: String {
    return localizedString(for: "Sign-in email Sent")
  }

  /// Account settings - Delete button label
  /// found in:
  /// - SignedInView
  public var deleteAccountButtonLabel: String {
    return localizedString(for: "Delete Account")
  }

  /// Account settings - Email label
  /// found in:
  /// SignedInView
  public var accountSettingsEmailLabel: String {
    return localizedString(for: "Email")
  }

  /// Account settings - sign out button label
  /// found in:
  /// - SignedInView
  public var signOutButtonLabel: String {
    return localizedString(for: "Sign Out")
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
  /// SignedInView
  public var sendEmailVerificationButtonLabel: String {
    return localizedString(for: "Verify email address?")
  }

  /// Account settings - verify email sheet message
  /// found in:
  /// SignedInView
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

  /// Google provider
  /// found in:
  /// - SignInWithGoogleButton
  public var googleLoginButtonLabel: String {
    return localizedString(for: "Sign in with Google")
  }

  /// Apple provider
  /// found in:
  /// - SignInWithAppleButton
  public var appleLoginButtonLabel: String {
    return localizedString(for: "Sign in with Apple")
  }

  /// Twitter/X provider
  /// found in:
  /// - SignInWithTwitterButton
  public var twitterLoginButtonLabel: String {
    return localizedString(for: "Sign in with X")
  }

  /// Phone provider
  /// found in:
  /// - PhoneAuthButtonView
  public var phoneLoginButtonLabel: String {
    return localizedString(for: "Sign in with Phone")
  }

  /// Facebook provider
  /// found in:
  /// - SignInWithFacebookButton
  public var facebookLoginButtonLabel: String {
    return localizedString(for: "Sign in with Facebook")
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
  /// - PhoneAuthView
  public var phoneSignInTitle: String {
    return localizedString(for: "Sign in with Phone")
  }

  /// Phone provider
  /// found in:
  /// - PhoneAuthView
  public var enterPhoneNumberPlaceholder: String {
    return localizedString(for: "Enter phone number")
  }

  /// Phone provider
  /// found in:
  /// - PhoneAuthView
  public var sendCodeButtonLabel: String {
    return localizedString(for: "Send Code")
  }

  /// Phone provider
  /// found in:
  /// - PhoneAuthView
  public var processingLabel: String {
    return localizedString(for: "Processing...")
  }

  /// Phone provider
  /// found in:
  /// - PhoneAuthView
  public var enterVerificationCodeTitle: String {
    return localizedString(for: "Enter Verification Code")
  }

  /// Phone provider
  /// found in:
  /// - PhoneAuthView
  public var verificationCodePlaceholder: String {
    return localizedString(for: "Verification Code")
  }

  /// Phone provider
  /// found in:
  /// - PhoneAuthView
  public var verifyAndSignInButtonLabel: String {
    return localizedString(for: "Verify and Sign In")
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
  public var smsCodeSendButtonLabel: String {
    return localizedString(for: "Send SMS code")
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
    return localizedString(for: "Terms of Service")
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
    return localizedString(for: "Privacy Policy")
  }

  /// Alert Error title
  /// found in:
  /// PasswordRecoveryView
  public var alertErrorTitle: String {
    return localizedString(for: "Error")
  }

  /// Authenticating overlay message
  /// found in:
  /// - AuthPickerView
  public var authenticatingMessage: String {
    return localizedString(for: "Authenticating...")
  }

  /// Two-Factor Authentication
  /// found in:
  /// - MFAEnrolmentView
  /// - MFAManagementView
  public var twoFactorAuthenticationLabel: String {
    return localizedString(for: "Two-Factor Authentication")
  }

  /// Set Up Two-Factor Authentication
  /// found in:
  /// - MFAEnrolmentView
  public var setUpTwoFactorAuthenticationLabel: String {
    return localizedString(for: "Set Up Two-Factor Authentication")
  }

  /// Manage Two-Factor Authentication
  /// found in:
  /// - MFAManagementView
  public var manageTwoFactorAuthenticationLabel: String {
    return localizedString(for: "Manage Two-Factor Authentication")
  }

  /// Complete Sign-In
  /// found in:
  /// - MFAResolutionView
  public var completeSignInLabel: String {
    return localizedString(for: "Complete Sign-In")
  }

  /// Complete Setup
  /// found in:
  /// - MFAEnrolmentView
  public var completeSetupLabel: String {
    return localizedString(for: "Complete Setup")
  }

  /// Choose Authentication Method
  /// found in:
  /// - MFAEnrolmentView
  /// - MFAResolutionView
  public var chooseAuthenticationMethodLabel: String {
    return localizedString(for: "Choose Authentication Method")
  }

  /// SMS Authentication
  /// found in:
  /// - MFAEnrolmentView
  /// - MFAResolutionView
  public var smsAuthenticationLabel: String {
    return localizedString(for: "SMS Authentication")
  }

  /// Authenticator App
  /// found in:
  /// - MFAEnrolmentView
  /// - MFAResolutionView
  public var authenticatorAppLabel: String {
    return localizedString(for: "Authenticator App")
  }

  /// Enter Your Phone Number
  /// found in:
  /// - MFAEnrolmentView
  /// - EnterPhoneNumberView
  public var enterYourPhoneNumberLabel: String {
    return localizedString(for: "Enter Your Phone Number")
  }

  /// Phone Number
  /// found in:
  /// - MFAEnrolmentView
  /// - EnterPhoneNumberView
  public var phoneNumberLabel: String {
    return localizedString(for: "Phone Number")
  }

  /// Send Code
  /// found in:
  /// - MFAEnrolmentView
  /// - EnterPhoneNumberView
  public var sendCodeLabel: String {
    return localizedString(for: "Send Code")
  }

  /// Enter Verification Code
  /// found in:
  /// - MFAEnrolmentView
  /// - MFAResolutionView
  /// - EnterVerificationCodeView
  public var enterVerificationCodeLabel: String {
    return localizedString(for: "Enter Verification Code")
  }

  /// Verification Code
  /// found in:
  /// - MFAEnrolmentView
  /// - MFAResolutionView
  /// - EnterVerificationCodeView
  public var verificationCodeLabel: String {
    return localizedString(for: "Verification Code")
  }

  /// Scan QR Code
  /// found in:
  /// - MFAEnrolmentView
  public var scanQRCodeLabel: String {
    return localizedString(for: "Scan QR Code")
  }

  /// Manual Entry Key:
  /// found in:
  /// - MFAEnrolmentView
  public var manualEntryKeyLabel: String {
    return localizedString(for: "Manual Entry Key:")
  }

  /// Enter 6-digit code
  /// found in:
  /// - MFAEnrolmentView
  public var enterSixDigitCodeLabel: String {
    return localizedString(for: "Enter 6-digit code")
  }

  /// Scan with your authenticator app or tap to open directly
  /// found in:
  /// - MFAEnrolmentView
  public var scanWithAuthenticatorAppMessage: String {
    return localizedString(for: "Scan with your authenticator app or tap to open directly")
  }

  /// Tap to open in authenticator app
  /// found in:
  /// - MFAEnrolmentView
  public var tapToOpenInAuthenticatorAppLabel: String {
    return localizedString(for: "Tap to open in authenticator app")
  }

  /// Use an authenticator app like Google Authenticator or Authy to generate verification codes.
  /// found in:
  /// - MFAEnrolmentView
  public var authenticatorAppInstructionsMessage: String {
    return localizedString(
      for: "Use an authenticator app like Google Authenticator or Authy to generate verification codes."
    )
  }

  /// Set up two-factor authentication to add an extra layer of security to your account.
  /// found in:
  /// - MFAEnrolmentView
  public var setUpTwoFactorAuthMessage: String {
    return localizedString(
      for: "Set up two-factor authentication to add an extra layer of security to your account."
    )
  }

  /// We'll send a verification code to this number
  /// found in:
  /// - MFAEnrolmentView
  public var sendVerificationCodeToNumberMessage: String {
    return localizedString(for: "We'll send a verification code to this number")
  }

  /// We'll send a verification code to your phone
  /// found in:
  /// - MFAEnrolmentView
  public var sendVerificationCodeToPhoneMessage: String {
    return localizedString(for: "We'll send a verification code to your phone")
  }

  /// We'll send a verification code to your phone number each time you sign in.
  /// found in:
  /// - MFAEnrolmentView
  public var sendVerificationCodeEachSignInMessage: String {
    return localizedString(
      for: "We'll send a verification code to your phone number each time you sign in."
    )
  }

  /// Unable to generate QR Code
  /// found in:
  /// - MFAEnrolmentView
  public var unableToGenerateQRCodeMessage: String {
    return localizedString(for: "Unable to generate QR Code")
  }

  /// Copied to clipboard!
  /// found in:
  /// - MFAEnrolmentView
  public var copiedToClipboardMessage: String {
    return localizedString(for: "Copied to clipboard!")
  }

  /// Multi-Factor Authentication Disabled
  /// found in:
  /// - MFAEnrolmentView
  /// - MFAResolutionView
  public var mfaDisabledLabel: String {
    return localizedString(for: "Multi-Factor Authentication Disabled")
  }

  /// MFA is not enabled in the current configuration. Please contact your administrator.
  /// found in:
  /// - MFAEnrolmentView
  /// - MFAResolutionView
  public var mfaNotEnabledMessage: String {
    return localizedString(
      for: "MFA is not enabled in the current configuration. Please contact your administrator."
    )
  }

  /// No Authentication Methods Available
  /// found in:
  /// - MFAEnrolmentView
  /// - MFAResolutionView
  public var noAuthenticationMethodsAvailableLabel: String {
    return localizedString(for: "No Authentication Methods Available")
  }

  /// No MFA methods are configured as allowed. Please contact your administrator.
  /// found in:
  /// - MFAEnrolmentView
  /// - MFAResolutionView
  public var noMFAMethodsConfiguredMessage: String {
    return localizedString(
      for: "No MFA methods are configured as allowed. Please contact your administrator."
    )
  }

  /// Complete sign-in with your second factor
  /// found in:
  /// - MFAResolutionView
  public var completeSignInWithSecondFactorMessage: String {
    return localizedString(for: "Complete sign-in with your second factor")
  }

  /// Choose verification method:
  /// found in:
  /// - MFAResolutionView
  public var chooseVerificationMethodLabel: String {
    return localizedString(for: "Choose verification method:")
  }

  /// SMS Verification
  /// found in:
  /// - MFAResolutionView
  public var smsVerificationLabel: String {
    return localizedString(for: "SMS Verification")
  }

  /// We sent a code to %@
  /// found in:
  /// - MFAResolutionView
  public var sentCodeToNumberMessage: String {
    return localizedString(for: "We sent a code to %@")
  }

  /// We'll send a code to ••••••%@
  /// found in:
  /// - MFAResolutionView
  public var sendCodeToMaskedNumberMessage: String {
    return localizedString(for: "We'll send a code to ••••••%@")
  }

  /// Enter the 6-digit code from your authenticator app
  /// found in:
  /// - MFAResolutionView
  public var enterCodeFromAuthenticatorAppMessage: String {
    return localizedString(for: "Enter the 6-digit code from your authenticator app")
  }

  /// Resend Code
  /// found in:
  /// - MFAResolutionView
  /// - EnterVerificationCodeView
  public var resendCodeLabel: String {
    return localizedString(for: "Resend Code")
  }

  /// Change number
  /// found in:
  /// - EnterVerificationCodeView
  public var changeNumberLabel: String {
    return localizedString(for: "Change number")
  }

  /// Manage your authentication methods
  /// found in:
  /// - MFAManagementView
  public var manageAuthenticationMethodsMessage: String {
    return localizedString(for: "Manage your authentication methods")
  }

  /// Enrolled Methods
  /// found in:
  /// - MFAManagementView
  public var enrolledMethodsLabel: String {
    return localizedString(for: "Enrolled Methods")
  }

  /// No Authentication Methods
  /// found in:
  /// - MFAManagementView
  public var noAuthenticationMethodsLabel: String {
    return localizedString(for: "No Authentication Methods")
  }

  /// Add an extra layer of security to your account
  /// found in:
  /// - MFAManagementView
  public var addExtraSecurityLayerMessage: String {
    return localizedString(for: "Add an extra layer of security to your account")
  }

  /// Add Another Method
  /// found in:
  /// - MFAManagementView
  public var addAnotherMethodLabel: String {
    return localizedString(for: "Add Another Method")
  }

  /// Get Started
  /// found in:
  /// - MFAManagementView
  public var getStartedLabel: String {
    return localizedString(for: "Get Started")
  }

  /// Remove
  /// found in:
  /// - MFAManagementView
  public var removeLabel: String {
    return localizedString(for: "Remove")
  }

  /// Authentication Method
  /// found in:
  /// - MFAManagementView
  public var authenticationMethodLabel: String {
    return localizedString(for: "Authentication Method")
  }

  /// Enrolled: %@
  /// found in:
  /// - MFAManagementView
  public var enrolledDateLabel: String {
    return localizedString(for: "Enrolled: %@")
  }

  /// SMS: %@
  /// found in:
  /// - MFAManagementView
  public var smsPhoneLabel: String {
    return localizedString(for: "SMS: %@")
  }

  /// Delete Account
  /// found in:
  /// - SignedInView
  public var deleteAccountLabel: String {
    return localizedString(for: "Delete Account")
  }

  /// Delete Account?
  /// found in:
  /// - SignedInView
  public var deleteAccountConfirmationLabel: String {
    return localizedString(for: "Delete Account?")
  }

  /// This action cannot be undone. All your data will be permanently deleted. You may need to
  /// reauthenticate to complete this action.
  /// found in:
  /// - SignedInView
  public var deleteAccountWarningMessage: String {
    return localizedString(
      for: "This action cannot be undone. All your data will be permanently deleted. You may need to reauthenticate to complete this action."
    )
  }

  /// Invalid OAuth Provider error
  /// found in:
  /// - GenericOAuthButton
  public var invalidOAuthProviderError: String {
    return localizedString(for: "Invalid OAuth Provider")
  }

  // MARK: - Field Labels

  /// Email field label
  /// found in:
  /// - EmailAuthView
  public var emailFieldLabel: String {
    return localizedString(for: "Email")
  }

  /// Password field label
  /// found in:
  /// - EmailAuthView
  public var passwordFieldLabel: String {
    return localizedString(for: "Password")
  }

  /// Confirm Password field label
  /// found in:
  /// - EmailAuthView
  public var confirmPasswordFieldLabel: String {
    return localizedString(for: "Confirm Password")
  }

  /// Phone Number field label
  /// found in:
  /// - MFAEnrolmentView
  public var phoneNumberFieldLabel: String {
    return localizedString(for: "Phone Number")
  }

  /// Display Name field label
  /// found in:
  /// - MFAEnrolmentView
  public var displayNameFieldLabel: String {
    return localizedString(for: "Display Name")
  }

  /// Verification Code field label
  /// found in:
  /// - MFAEnrolmentView
  public var verificationCodeFieldLabel: String {
    return localizedString(for: "Verification Code")
  }

  /// Send a password recovery link to your email field label
  /// found in:
  /// - PasswordRecoveryView
  public var passwordRecoveryEmailFieldLabel: String {
    return localizedString(for: "Send a password recovery link to your email")
  }

  /// Send a sign-in link to your email field label
  /// found in:
  /// - EmailLinkView
  public var signInLinkEmailFieldLabel: String {
    return localizedString(for: "Send a sign-in link to your email")
  }

  /// Enter phone number prompt
  /// found in:
  /// - MFAEnrolmentView
  public var enterPhoneNumberPrompt: String {
    return localizedString(for: "Enter phone number")
  }

  /// Enter display name for this device prompt
  /// found in:
  /// - MFAEnrolmentView
  public var enterDisplayNameForDevicePrompt: String {
    return localizedString(for: "Enter display name for this device")
  }

  /// Enter display name for this authenticator prompt
  /// found in:
  /// - MFAEnrolmentView
  public var enterDisplayNameForAuthenticatorPrompt: String {
    return localizedString(for: "Enter display name for this authenticator")
  }

  /// Enter code from app prompt
  /// found in:
  /// - MFAEnrolmentView
  public var enterCodeFromAppPrompt: String {
    return localizedString(for: "Enter code from app")
  }

  /// Phone field label
  /// found in:
  /// - EnterPhoneNumberView
  public var phoneFieldLabel: String {
    return localizedString(for: "Phone")
  }

  /// We sent a code to number message
  /// found in:
  /// - EnterVerificationCodeView
  public func sentCodeMessage(phoneNumber: String) -> String {
    return String(format: localizedString(for: "We sent a code to %@"), phoneNumber)
  }

  /// Change number label
  /// found in:
  /// - EnterVerificationCodeView
  public var changeNumberButtonLabel: String {
    return localizedString(for: "Change number")
  }

  // MARK: - Reauthentication Strings

  /// Confirm password title
  /// found in:
  /// - EmailReauthView
  public var confirmPasswordTitle: String {
    return localizedString(for: "Confirm Password")
  }

  /// For security prompt message
  /// found in:
  /// - EmailReauthView
  public var forSecurityEnterPasswordMessage: String {
    return localizedString(for: "For security, please enter your password")
  }

  /// Email prefix format
  /// found in:
  /// - EmailReauthView
  public func emailPrefix(email: String) -> String {
    return String(format: localizedString(for: "Email: %@"), email)
  }

  /// Confirm button label
  /// found in:
  /// - EmailReauthView
  public var confirmButtonLabel: String {
    return localizedString(for: "Confirm")
  }

  /// Verify phone number title
  /// found in:
  /// - PhoneReauthView
  public var verifyPhoneNumberTitle: String {
    return localizedString(for: "Verify Phone Number")
  }

  /// For security verify phone message
  /// found in:
  /// - PhoneReauthView
  public var forSecurityVerifyPhoneMessage: String {
    return localizedString(for: "For security, please verify your phone number")
  }

  /// Send verification code to phone prefix
  /// found in:
  /// - PhoneReauthView
  public var sendVerificationCodeToPhonePrefix: String {
    return localizedString(for: "We'll send a verification code to:")
  }

  /// Send verification code button label
  /// found in:
  /// - PhoneReauthView
  public var sendVerificationCodeButtonLabel: String {
    return localizedString(for: "Send Verification Code")
  }

  /// Enter 6-digit code sent to prefix
  /// found in:
  /// - PhoneReauthView
  public var enterSixDigitCodeSentToPrefix: String {
    return localizedString(for: "Enter the 6-digit code sent to:")
  }

  /// Verify button label
  /// found in:
  /// - PhoneReauthView
  public var verifyButtonLabel: String {
    return localizedString(for: "Verify")
  }

  // MARK: - Password Update Strings

  /// Type new password label
  /// found in:
  /// - UpdatePasswordView
  public var typeNewPasswordLabel: String {
    return localizedString(for: "Type new password")
  }

  /// Retype new password label
  /// found in:
  /// - UpdatePasswordView
  public var retypeNewPasswordLabel: String {
    return localizedString(for: "Retype new password")
  }

  /// Password updated title
  /// found in:
  /// - UpdatePasswordView
  public var passwordUpdatedTitle: String {
    return localizedString(for: "Password Updated")
  }

  /// Password updated successfully message
  /// found in:
  /// - UpdatePasswordView
  public var passwordUpdatedSuccessMessage: String {
    return localizedString(for: "Your password has been successfully updated.")
  }

  // MARK: - MFA Management Strings

  /// Unnamed method fallback label
  /// found in:
  /// - MFAManagementView
  public var unnamedMethodLabel: String {
    return localizedString(for: "Unnamed Method")
  }

  /// Account prefix for TOTP display name
  /// found in:
  /// - MFAResolutionView
  public func accountPrefix(displayName: String) -> String {
    return String(format: localizedString(for: "Account: %@"), displayName)
  }

  // MARK: - Email Verification Strings

  /// Email verification tap link message
  /// found in:
  /// - SignedInView
  public var emailVerificationTapLinkMessage: String {
    return localizedString(for: "Please tap on the link in your email to complete verification.")
  }

  // MARK: - Privacy/TOC Format Strings

  /// Footer terms format (simple concatenation for footer mode)
  /// found in:
  /// - PrivacyTOCsView
  public var footerTermsFormat: String {
    return "%@    %@"
  }
}
