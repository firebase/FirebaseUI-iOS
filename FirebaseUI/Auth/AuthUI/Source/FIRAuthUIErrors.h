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

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

/** @var FIRAuthUIErrorDomain
    @brief The standard Firebase error domain.
 */
extern NSString *const FIRAuthUIErrorDomain;

/** @bar FIRAuthUIErrorUserInfoProviderIDKey
    @brief The ID of the identity provider.
 */
extern NSString *const FIRAuthUIErrorUserInfoProviderIDKey;

/** @var FIRAuthUIErrorCode
    @brief Error codes used by FIRAuthUI.
 */
typedef NS_ENUM(NSUInteger, FIRAuthUIErrorCode) {
  /** @var FIRAuthUIErrorCodeUserCancelledSignIn
      @brief Indicates the user cancelled a sign-in flow.
   */
  FIRAuthUIErrorCodeUserCancelledSignIn = 1,
  /** @var FIRAuthUIErrorCodeProviderError
      @brief Indicates there's an error from the identity provider. The
          @c FIRAuthUIErrorUserInfoProviderIDKey field in the @c NError.userInfo dictionary will
          contain the ID of the identity provider.
   */
  FIRAuthUIErrorCodeProviderError = 2,
};

NS_ASSUME_NONNULL_END
