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

@import FirebaseCore;

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
NSString *const kStr_PrivacyPolicy = @"PrivacyPolicy";
NSString *const kStr_TermsOfServiceMessage = @"TermsOfServiceMessage";
NSString *const kStr_UserNotFoundError = @"UserNotFoundError";
NSString *const kStr_WeakPasswordError = @"WeakPasswordError";
NSString *const kStr_WrongPasswordError = @"WrongPasswordError";
NSString *const kStr_CantFindProvider = @"CantFindProvider";
NSString *const kStr_EmailsDontMatch = @"EmailsDontMatch";
NSString *const kStr_VerifyItsYou = @"VerifyItsYou";
NSString *const kStr_DeleteAccountConfirmationTitle = @"DeleteAccountConfirmationTitle";
NSString *const kStr_DeleteAccountBody = @"DeleteAccountBody";
NSString *const kStr_DeleteAccountConfirmationMessage = @"DeleteAccountConfirmationMessage";
NSString *const kStr_Delete = @"Delete";
NSString *const kStr_DeleteAccountControllerTitle = @"DeleteAccountControllerTitle";
NSString *const kStr_ActionCantBeUndone = @"ActionCantBeUndone";
NSString *const kStr_UnlinkTitle = @"UnlinkTitle";
NSString *const kStr_UnlinkAction = @"UnlinkAction";
NSString *const kStr_UnlinkConfirmationTitle = @"UnlinkConfirmationTitle";
NSString *const kStr_UnlinkConfirmationMessage = @"UnlinkConfirmationMessage";
NSString *const kStr_UnlinkConfirmationActionTitle = @"UnlinkConfirmationActionTitle";
NSString *const kStr_UpdateEmailAlertMessage = @"UpdateEmailAlertMessage";
NSString *const kStr_UpdateEmailVerificationAlertMessage = @"UpdateEmailVerificationAlertMessage";
NSString *const kStr_EditEmailTitle = @"EditEmailTitle";
NSString *const kStr_EditNameTitle = @"EditNameTitle";
NSString *const kStr_AddPasswordAlertMessage = @"AddPasswordAlertMessage";
NSString *const kStr_EditPasswordAlertMessage = @"EditPasswordAlertMessage";
NSString *const kStr_ReauthenticateEditPasswordAlertMessage = @"ReauthenticateEditPasswordAlertMessage";
NSString *const kStr_AddPasswordTitle = @"AddPasswordTitle";
NSString *const kStr_EditPasswordTitle = @"EditPasswordTitle";
NSString *const kStr_ProviderTitlePassword = @"ProviderTitlePassword";
NSString *const kStr_ProviderTitleGoogle = @"ProviderTitleGoogle";
NSString *const kStr_ProviderTitleFacebook = @"ProviderTitleFacebook";
NSString *const kStr_ProviderTitleTwitter = @"ProviderTitleTwitter";
NSString *const kStr_SignInWithProvider = @"SignInWithProvider";
NSString *const kStr_PlaceholderEnterName = @"PlaceholderEnterName";
NSString *const kStr_PlaceholderEnterEmail = @"PlaceholderEnterEmail";
NSString *const kStr_PlaceholderEnterPassword = @"PlaceholderEnterPassword";
NSString *const kStr_PlaceholderChosePassword = @"PlaceholderChosePassword";
NSString *const kStr_PlaceholderNewPassword = @"PlaceholderNewPassword";
NSString *const kStr_ForgotPasswordTitle = @"ForgotPasswordTitle";

/** @var kKeyNotFound
    @brief The value returned if the key is not found in the table.
 */
NSString *const kKeyNotFound = @"KeyNotFound";

/** @var kTableName
    @brief The name of the strings table to search for localized strings.
 */
NSString *const kTableName = @"FirebaseAuthUI";

NSString *FUILocalizedString(NSString *key) {
  return FUILocalizedStringFromTable(key, kTableName);
}

NSString *FUILocalizedStringFromTable(NSString *key, NSString *table) {
  return FUILocalizedStringFromTableInBundle(key, table, kTableName);
}

NSString *FUILocalizedStringFromTableInBundle(NSString *key,
                                              NSString *table,
                                              NSString *_Nullable bundleName) {
  // Don't load defaultAuthUI if the default app isn't configured. We don't recommend
  // people do this in our docs, but if for whatever reason they want to use a custom
  // app, this code shouldn't crash.
  if ([FIRApp defaultApp] != nil) {
    NSBundle *customStringsBundle = [FUIAuth defaultAuthUI].customStringsBundle;
    if (customStringsBundle) {
      NSString *localizedString = [customStringsBundle localizedStringForKey:key
                                                                       value:kKeyNotFound
                                                                       table:table];
      if (![kKeyNotFound isEqual:localizedString]) {
        return localizedString;
      }
    }
  }
  NSBundle *frameworkBundle = [FUIAuthUtils bundleNamed:bundleName];
  if (frameworkBundle == nil) {
    frameworkBundle = [NSBundle mainBundle];
  }
  return [frameworkBundle localizedStringForKey:key value:nil table:table];
}

NS_ASSUME_NONNULL_END
