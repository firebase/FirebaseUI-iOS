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

#import <Foundation/Foundation.h>

/** @class FIRAuthUIStrings
    @brief A util class to provide localized strings.
 */
@interface FIRAuthUIStrings : NSObject

/** @fn authPickerTitle
    @brief Title for auth picker screen.
    @return Localized string.
 */
+ (NSString *)authPickerTitle;

/** @fn signInWithEmail
    @brief Sign in with email button label.
    @return Localized string.
 */
+ (NSString *)signInWithEmail;

/** @fn enterYourEmail
    @brief Title for email entry screen, email text field placeholder.
    @return Localized string.
 */
+ (NSString *)enterYourEmail;

/** @fn invalidEmailError
    @brief Error message displayed when user enters an invalid email address.
    @return Localized string.
 */
+ (NSString *)invalidEmailError;

/** @fn cannotAuthenticateError
    @brief Error message displayed when the app cannot authenticate user's account.
    @return Localized string.
 */
+ (NSString *)cannotAuthenticateError;

/** @fn welcomeBack
    @brief Title of an alert shown to an existing user coming back to the app.
    @return Localized string.
 */
+ (NSString *)welcomeBack;

/** @fn providerUsedPreviouslyMessage
    @brief Alert message to let user know what identity provider was used previously for the email
        address;
    @return Localized string.
 */
+ (NSString *)providerUsedPreviouslyMessage;

/** @fn signInTitle
    @brief Title for sign in screen.
    @return Localized string.
 */
+ (NSString *)signInTitle;

/** @fn enterYourPassword
    @brief Password text field placeholder.
    @return Localized string.
 */
+ (NSString *)enterYourPassword;

/** @fn wrongPasswordError
    @brief Error message displayed when the email and password don't match.
    @return Localized string.
 */
+ (NSString *)wrongPasswordError;

/** @fn accountDoesNotExistError
    @brief Error message displayed when the account does not exist.
    @return Localized string.
 */
+ (NSString *)accountDoesNotExistError;

/** @fn accountDisabledError
    @brief The user account has been disabled by an administrator.
    @return Localized string.
 */
+ (NSString *)accountDisabledError;

/** @fn passwordRecoveryTitle
    @brief Title for password recovery screen.
    @return Localized string.
 */
+ (NSString *)passwordRecoveryTitle;

/** @fn passwordRecoveryError
    @brief Error message displayed when failed to recover password for an account.
    @return Localized string.
 */
+ (NSString *)passwordRecoveryError;

/** @fn passwordRecoveryEmailSentMessage
    @brief Message displayed when the email for password recovery has been sent.
    @return Localized string.
 */
+ (NSString *)passwordRecoveryEmailSentMessage;

/** @fn signUpTitle
    @brief Title for sign up screen.
    @return Localized string.
 */
+ (NSString *)signUpTitle;

/** @fn enterYourName
    @brief Name text field placeholder.
    @return Localized string.
 */
+ (NSString *)enterYourName;

/** @fn nameMissingError
    @brief Error message displayed when the name of the user is not entered.
    @return Localized string.
 */
+ (NSString *)nameMissingError;

/** @fn emailAlreadyInUseError
    @brief Error message displayed when the email address is already in use.
    @return Localized string.
 */
+ (NSString *)emailAlreadyInUseError;

/** @fn weakPasswordError
    @brief Error message displayed when the password is too weak.
    @return Localized string.
 */
+ (NSString *)weakPasswordError;

/** @fn passwordVerificationMessage
    @brief Message to explain to the user why password is needed for an account with this email
        address.
    @return Localized string.
 */
+ (NSString *)passwordVerificationMessage;

/** @fn error
    @brief Error alert title.
    @return Localized string.
 */
+ (NSString *)error;

/** @fn info
    @brief Informational alert title.
    @return Localized string.
 */
+ (NSString *)info;

/** @fn OK
    @brief OK button title.
    @return Localized string.
 */
+ (NSString *)OK;

/** @fn cancel
    @brief Cancel button title.
    @return Localized string.
 */
+ (NSString *)cancel;

/** @fn next
    @brief Next button title.
    @return Localized string.
 */
+ (NSString *)next;

/** @fn email
    @brief Label next to a email text field.
    @return Localized string.
 */
+ (NSString *)email;

/** @fn password
    @brief Label next to a password text field.
    @return Localized string.
 */
+ (NSString *)password;

/** @fn name
    @brief Label next to a name text field.
    @return Localized string.
 */
+ (NSString *)name;

@end
