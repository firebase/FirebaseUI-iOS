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

#import "FIRAuthUIStrings.h"

#import "FIRAuthUIUtils.h"

// AuthUI string keys.
static NSString *const kAuthPickerTitle = @"AuthPickerTitle";
static NSString *const kSignInWithEmail = @"SignInWithEmail";
static NSString *const kEnterYourEmail = @"EnterYourEmail";
static NSString *const kInvalidEmailError = @"InvalidEmailError";
static NSString *const kCannotAuthenticateError = @"CannotAuthenticateError";
static NSString *const kWelcomeBack = @"WelcomeBack";
static NSString *const kProviderUsedPreviouslyMessage = @"ProviderUsedPreviouslyMessage";
static NSString *const kSignInTitle = @"SignInTitle";
static NSString *const kEnterYourPassword = @"EnterYourPassword";
static NSString *const kWrongPasswordError = @"WrongPasswordError";
static NSString *const kAccountDoesNotExistError = @"AccountDoesNotExistError";
static NSString *const kAccountDisabledError = @"AccountDisabledError";
static NSString *const kPasswordRecoveryTitle = @"PasswordRecoveryTitle";
static NSString *const kPasswordRecoveryError = @"PasswordRecoveryError";
static NSString *const kPasswordRecoveryEmailSentMessage = @"PasswordRecoveryEmailSentMessage";
static NSString *const kSignUpTitle = @"SignUpTitle";
static NSString *const kEnterYourName = @"EnterYourName";
static NSString *const kNameMissingError = @"NameMissingError";
static NSString *const kEmailAlreadyInUseError = @"EmailAlreadyInUseError";
static NSString *const kWeakPasswordError = @"WeakPasswordError";
static NSString *const kPasswordVerificationMessage = @"PasswordVerificationMessage";
static NSString *const kError = @"Error";
static NSString *const kInfo = @"Info";
static NSString *const kOK = @"OK";
static NSString *const kCancel = @"Cancel";
static NSString *const kNext = @"Next";
static NSString *const kEmail = @"Email";
static NSString *const kPassword = @"Password";
static NSString *const kName = @"Name";

@implementation FIRAuthUIStrings

/** @fn localizedStringForKey:
    @brief Returns the localized text associated with a given string key. Will default to english
        text if the string is not available for the current localization.
    @param key A string key which identifies localized text in the .strings files.
    @return Localized value of the string identified by the key.
 */
+ (NSString *)localizedStringForKey:(NSString *)key {
  NSBundle *frameworkBundle = [FIRAuthUIUtils frameworkBundle];
  return [frameworkBundle localizedStringForKey:key value:nil table:@"FirebaseAuthUI"];
}

+ (NSString *)authPickerTitle {
  return [self localizedStringForKey:kAuthPickerTitle];
}

+ (NSString *)signInWithEmail {
  return [self localizedStringForKey:kSignInWithEmail];
}

+ (NSString *)enterYourEmail {
  return [self localizedStringForKey:kEnterYourEmail];
}

+ (NSString *)invalidEmailError {
  return [self localizedStringForKey:kInvalidEmailError];
}

+ (NSString *)cannotAuthenticateError {
  return [self localizedStringForKey:kCannotAuthenticateError];
}

+ (NSString *)welcomeBack {
  return [self localizedStringForKey:kWelcomeBack];
}

+ (NSString *)providerUsedPreviouslyMessage {
  return [self localizedStringForKey:kProviderUsedPreviouslyMessage];
}

+ (NSString *)signInTitle {
  return [self localizedStringForKey:kSignInTitle];
}

+ (NSString *)enterYourPassword {
  return [self localizedStringForKey:kEnterYourPassword];
}

+ (NSString *)wrongPasswordError {
  return [self localizedStringForKey:kWrongPasswordError];
}

+ (NSString *)accountDoesNotExistError {
  return [self localizedStringForKey:kAccountDoesNotExistError];
}

+ (NSString *)accountDisabledError {
  return [self localizedStringForKey:kAccountDisabledError];
}

+ (NSString *)passwordRecoveryTitle {
  return [self localizedStringForKey:kPasswordRecoveryTitle];
}

+ (NSString *)passwordRecoveryError {
  return [self localizedStringForKey:kPasswordRecoveryError];
}

+ (NSString *)passwordRecoveryEmailSentMessage {
  return [self localizedStringForKey:kPasswordRecoveryEmailSentMessage];
}

+ (NSString *)signUpTitle {
  return [self localizedStringForKey:kSignUpTitle];
}

+ (NSString *)enterYourName {
  return [self localizedStringForKey:kEnterYourName];
}

+ (NSString *)nameMissingError {
  return [self localizedStringForKey:kNameMissingError];
}

+ (NSString *)emailAlreadyInUseError {
  return [self localizedStringForKey:kEmailAlreadyInUseError];
}

+ (NSString *)weakPasswordError {
  return [self localizedStringForKey:kWeakPasswordError];
}

+ (NSString *)passwordVerificationMessage {
  return [self localizedStringForKey:kPasswordVerificationMessage];
}

+ (NSString *)error {
  return [self localizedStringForKey:kError];
}

+ (NSString *)info {
  return [self localizedStringForKey:kInfo];
}

+ (NSString *)OK {
  return [self localizedStringForKey:kOK];
}

+ (NSString *)cancel {
  return [self localizedStringForKey:kCancel];
}

+ (NSString *)next {
  return [self localizedStringForKey:kNext];
}

+ (NSString *)email {
  return [self localizedStringForKey:kEmail];
}

+ (NSString *)password {
  return [self localizedStringForKey:kPassword];
}

+ (NSString *)name {
  return [self localizedStringForKey:kName];
}

@end
