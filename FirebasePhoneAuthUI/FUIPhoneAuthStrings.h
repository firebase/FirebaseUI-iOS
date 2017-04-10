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
extern NSString *const kPAStr_SignInWithTwitter;
extern NSString *const kPAStr_Next;
extern NSString *const kPAStr_EmptyVerificationCode;
extern NSString *const kPAStr_EmptyPhoneNumber;
extern NSString *const kPAStr_PhoneNumber;
extern NSString *const kPAStr_EnterYourPhoneNumber;
extern NSString *const kPAStr_Country;

#ifdef __cplusplus
extern "C" {
#endif

/** @fn FUIPhoneAuthLocalizedString
    @brief Gets a localized string from a name.
    @param name The key value of the string.
    @return The string by the key localized in the current locale.
 */
NSString *FUIPhoneAuthLocalizedString(NSString *key);

#ifdef __cplusplus
}
#endif

NS_ASSUME_NONNULL_END
