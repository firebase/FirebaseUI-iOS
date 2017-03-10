//
//  Copyright (c) 2016 Google Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "FUIAuthStrings.h"

#import "FUIAuth.h"
#import "FUIAuthUtils.h"

NS_ASSUME_NONNULL_BEGIN

// AuthUI string keys.
NSString *const kStr_ASCellAddPassword = @"AS_AddPassword";
NSString *const kStr_ASCellChangePassword = @"AS_ChangePassword";
NSString *const kStr_ASCellDeleteAccount = @"AS_DeleteAccount";
NSString *const kStr_ASCellEmail = @"AS_Email";
NSString *const kStr_ASCellName = @"AS_Name";
NSString *const kStr_ASCellSignOut = @"AS_SignOut";
NSString *const kStr_ASSectionTitleLinkedAccounts = @"AS_SectionLinkedAccounts";
NSString *const kStr_ASSectionTitleProfile = @"AS_SectionProfile";
NSString *const kStr_ASSectionTitleSecurity = @"AS_SectionSecurity";
NSString *const kStr_AccountDisabledError = @"AccountDisabledError";
NSString *const kStr_AuthPickerTitle = @"AuthPickerTitle";
NSString *const kStr_Back = @"Back";
NSString *const kStr_Cancel = @"Cancel";
NSString *const kStr_CannotAuthenticateError = @"CannotAuthenticateError";
NSString *const kStr_ChoosePassword = @"ChoosePassword";
NSString *const kStr_Close = @"Close";
NSString *const kStr_Email = @"Email";
NSString *const kStr_EmailAlreadyInUseError = @"EmailAlreadyInUseError";
NSString *const kStr_EnterYourEmail = @"EnterYourEmail";
NSString *const kStr_EnterYourPassword = @"EnterYourPassword";
NSString *const kStr_Error = @"Error";
NSString *const kStr_ExistingAccountTitle = @"ExistingAccountTitle";
NSString *const kStr_FirstAndLastName = @"FirstAndLastName";
NSString *const kStr_ForgotPassword = @"ForgotPassword";
NSString *const kStr_InvalidEmailError = @"InvalidEmailError";
NSString *const kStr_InvalidPasswordError = @"InvalidPasswordError";
NSString *const kStr_Name = @"Name";
NSString *const kStr_Next = @"Next";
NSString *const kStr_OK = @"OK";
NSString *const kStr_Password = @"Password";
NSString *const kStr_PasswordRecoveryEmailSentMessage = @"PasswordRecoveryEmailSentMessage";
NSString *const kStr_PasswordRecoveryEmailSentTitle = @"PasswordRecoveryEmailSentTitle";
NSString *const kStr_PasswordRecoveryMessage = @"PasswordRecoveryMessage";
NSString *const kStr_PasswordRecoveryTitle = @"PasswordRecoveryTitle";
NSString *const kStr_PasswordVerificationMessage = @"PasswordVerificationMessage";
NSString *const kStr_ProviderUsedPreviouslyMessage = @"ProviderUsedPreviouslyMessage";
NSString *const kStr_Save = @"Save";
NSString *const kStr_Send = @"Send";
NSString *const kStr_SignInTitle = @"SignInTitle";
NSString *const kStr_SignInTooManyTimesError = @"SignInTooManyTimesError";
NSString *const kStr_SignInWithEmail = @"SignInWithEmail";
NSString *const kStr_SignUpTitle = @"SignUpTitle";
NSString *const kStr_SignUpTooManyTimesError = @"SignUpTooManyTimesError";
NSString *const kStr_TermsOfService = @"TermsOfService";
NSString *const kStr_TermsOfServiceNotice = @"TermsOfServiceNotice";
NSString *const kStr_UserNotFoundError = @"UserNotFoundError";
NSString *const kStr_WeakPasswordError = @"WeakPasswordError";
NSString *const kStr_WrongPasswordError = @"WrongPasswordError";

/** @var kKeyNotFound
    @brief The value returned if the key is not found in the table.
*/
NSString *const kKeyNotFound = @"KeyNotFound";

/** @var kTableName
    @brief The name of the strings table to search for localized strings.
*/
NSString *const kTableName = @"FirebaseAuthUI";

NSString *FUILocalizedString(NSString *key) {

  NSBundle *customStringsBundle = [FUIAuth defaultAuthUI].customStringsBundle;
  if (customStringsBundle) {
    NSString *localizedString = [customStringsBundle localizedStringForKey:key
                                                                     value:kKeyNotFound
                                                                     table:kTableName];
    if (![kKeyNotFound isEqual:localizedString]) {
      return localizedString;
    }
  }
  NSBundle *frameworkBundle = [FUIAuthUtils frameworkBundle];
  return [frameworkBundle localizedStringForKey:key value:nil table:kTableName];
}

NS_ASSUME_NONNULL_END
