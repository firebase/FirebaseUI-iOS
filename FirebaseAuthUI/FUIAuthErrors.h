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

/** @var FUIAuthErrorDomain
    @brief The standard Firebase error domain.
 */
extern NSString *const FUIAuthErrorDomain;

/** @bar FUIAuthErrorUserInfoProviderIDKey
    @brief The ID of the identity provider.
 */
extern NSString *const FUIAuthErrorUserInfoProviderIDKey;

/** @var FUIAuthErrorCode
    @brief Error codes used by FUIAuth.
 */
typedef NS_ENUM(NSUInteger, FUIAuthErrorCode) {

  /** @var FUIAuthErrorCodeUserCancelledSignIn
      @brief Indicates the user cancelled a sign-in flow.
   */
  FUIAuthErrorCodeUserCancelledSignIn = 1,

  /** @var FUIAuthErrorCodeProviderError
      @brief Indicates there's an error from the identity provider. The
          @c FUIAuthErrorUserInfoProviderIDKey field in the @c NError.userInfo dictionary will
          contain the ID of the identity provider.
   */
  FUIAuthErrorCodeProviderError = 2,

  /** @var FUIAuthErrorCodeCantFindProvider
      @brief Indicates that @FUIAuth.providers doen't contain current provider (see NSError.userInfo
          key @c FUIAuthErrorUserInfoProviderIDKey).
   */
  FUIAuthErrorCodeCantFindProvider = 3,
};

NS_ASSUME_NONNULL_END
