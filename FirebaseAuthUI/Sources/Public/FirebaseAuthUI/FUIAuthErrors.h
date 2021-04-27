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

NS_ASSUME_NONNULL_BEGIN

/** @var FUIAuthErrorDomain
    @brief The standard Firebase error domain.
 */
extern NSString *const FUIAuthErrorDomain;

/** @var FUIAuthErrorUserInfoProviderIDKey
    @brief The ID of the identity provider.
 */
extern NSString *const FUIAuthErrorUserInfoProviderIDKey;

/** @var FUIAuthCredentialKey
    @brief The key used to obtain the credential stored within the userInfo dictionary of the
        error, if available.
 */
extern NSString *const FUIAuthCredentialKey;

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

  /** @var FUIAuthErrorCodeMergeConflict
      @brief Indicates that a merge conflict occurred while trying to automatically upgrade an
          anonymous user. The non-anonymous credential can be obtained from the userInfo dictionary
          of the corresponding NSError using the @c FUIAuthCredentialKey.
   */
  FUIAuthErrorCodeMergeConflict = 4,
};

NS_ASSUME_NONNULL_END
