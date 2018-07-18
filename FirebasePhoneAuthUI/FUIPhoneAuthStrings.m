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

#import "FUIPhoneAuthStrings.h"

#import "FUIAuthStrings.h"
#import "FUIPhoneAuth_Internal.h"

NS_ASSUME_NONNULL_BEGIN

NSString *const kPAStr_EnterPhoneTitle = @"EnterPhoneTitle";
NSString *const kPAStr_SignInWithPhone = @"SignInWithPhone";
NSString *const kPAStr_Next = @"Next";
NSString *const kPAStr_Verify = @"Verify";
NSString *const kPAStr_EmptyVerificationCode = @"EmptyVerificationCode";
NSString *const kPAStr_EmptyPhoneNumber = @"EmptyPhoneNumber";
NSString *const kPAStr_PhoneNumber = @"PhoneNumber";
NSString *const kPAStr_EnterYourPhoneNumber = @"EnterYourPhoneNumber";
NSString *const kPAStr_Country = @"Country";
NSString *const kPAStr_EnterCodeDescription = @"EnterCodeDescription";
NSString *const kPAStr_ResendCode = @"ResendCode";
NSString *const kPAStr_ResendCodeTimer = @"ResendCodeTimer";
NSString *const kPAStr_VerifyPhoneTitle = @"VerifyPhoneTitle";
NSString *const kPAStr_ResendCodeResult = @"ResendCodeResult";
NSString *const kPAStr_IncorrectCodeTitle = @"IncorrectCodeTitle";
NSString *const kPAStr_IncorrectCodeMessage = @"IncorrectCodeMessage";
NSString *const kPAStr_Done = @"Done";
NSString *const kPAStr_Back = @"Back";
NSString *const kPAStr_IncorrectPhoneTitle = @"IncorrectPhoneTitle";
NSString *const kPAStr_IncorrectPhoneMessage = @"IncorrectPhoneMessage";
NSString *const kPAStr_InternalErrorMessage = @"InternalErrorMessage";
NSString *const kPAStr_TooManyCodesSent = @"TooManyCodesSent";
NSString *const kPAStr_MessageQuotaExceeded = @"MessageQuotaExceeded";
NSString *const kPAStr_MessageExpired = @"MessageExpired";
NSString *const kPAStr_TermsSMS = @"TermsSMS";

NSString *const FUIPhoneAuthBundleName = @"FirebasePhoneAuthUI";

/** @var kPhoneAuthProviderTableName
    @brief The name of the strings table to search for localized strings.
 */
NSString *const kPhoneAuthProviderTableName = @"FirebasePhoneAuthUI";

NSString *FUIPhoneAuthLocalizedString(NSString *key) {
  return FUILocalizedStringFromTableInBundle(key,
                                             kPhoneAuthProviderTableName,
                                             FUIPhoneAuthBundleName);
}

NS_ASSUME_NONNULL_END
