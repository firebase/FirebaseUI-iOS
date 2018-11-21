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

#import "FUIAuthUtils.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString *const kPAStr_EnterPhoneTitle;
extern NSString *const kPAStr_SignInWithPhone;
extern NSString *const kPAStr_Next;
extern NSString *const kPAStr_Verify;
extern NSString *const kPAStr_EmptyVerificationCode;
extern NSString *const kPAStr_EmptyPhoneNumber;
extern NSString *const kPAStr_PhoneNumber;
extern NSString *const kPAStr_EnterYourPhoneNumber;
extern NSString *const kPAStr_Country;
extern NSString *const kPAStr_EnterCodeDescription;
extern NSString *const kPAStr_ResendCode;
extern NSString *const kPAStr_ResendCodeTimer;
extern NSString *const kPAStr_VerifyPhoneTitle;
extern NSString *const kPAStr_ResendCodeResult;
extern NSString *const kPAStr_IncorrectCodeTitle;
extern NSString *const kPAStr_IncorrectCodeMessage;
extern NSString *const kPAStr_Done;
extern NSString *const kPAStr_Back;
extern NSString *const kPAStr_IncorrectPhoneTitle;
extern NSString *const kPAStr_IncorrectPhoneMessage;
extern NSString *const kPAStr_InternalErrorMessage;
extern NSString *const kPAStr_TooManyCodesSent;
extern NSString *const kPAStr_MessageQuotaExceeded;
extern NSString *const kPAStr_MessageExpired;
extern NSString *const kPAStr_TermsSMS;

/* Name of the FirebasePhoneAuthUI resource bundle. */
extern NSString *const FUIPhoneAuthBundleName;

#ifdef __cplusplus
extern "C" {
#endif

/** @fn FUIPhoneAuthLocalizedString
    @brief Gets a localized string from a name.
    @param key The key value of the string.
    @return The string by the key localized in the current locale.
 */
NSString *FUIPhoneAuthLocalizedString(NSString *key);

#ifdef __cplusplus
}
#endif

NS_ASSUME_NONNULL_END
