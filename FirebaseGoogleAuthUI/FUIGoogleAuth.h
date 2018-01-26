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

#import "FUIAuthProvider.h"

NS_ASSUME_NONNULL_BEGIN

/** @var kGoogleGamesScope
    @brief The OAuth scope string for the "Games" scope.
 */
static NSString *const kGoogleGamesScope = @"https://www.googleapis.com/auth/games";

/** @var kGooglePlusMeScope
    @brief The OAuth scope string for the "plus.me" scope.
 */
static NSString *const kGooglePlusMeScope = @"https://www.googleapis.com/auth/plus.me";

/** @var kGooglePlusMeScope
    @brief The OAuth scope string for the user's email scope.
 */
static NSString *const kGoogleUserInfoEmailScope = @"https://www.googleapis.com/auth/userinfo.email";

/** @var kGooglePlusMeScope
    @brief The OAuth scope string for the basic G+ profile information scope.
 */
static NSString *const kGoogleUserInfoProfileScope = @"https://www.googleapis.com/auth/userinfo.profile";

/** @class FUIGoogleAuth
    @brief AuthUI components for Google Sign In.
 */
@interface FUIGoogleAuth : NSObject <FUIAuthProvider>

/** @property scopes
    @brief The scopes to use with Google Sign In.
    @remarks Defaults to using email and profile scopes. For a list of all scopes
        see https://developers.google.com/identity/protocols/googlescopes
 */
@property(nonatomic, copy, readonly) NSArray<NSString *> *scopes;

/** @fn init
    @brief Convenience initializer. Calls designated init with default
        scopes of "email" and "profile".
 */
- (instancetype)init;

/** @fn initWithScopes:
    @brief Designated initializer.
    @param scopes   The user account scopes required by the app. A list of possible scopes can be
        found at https://developers.google.com/identity/protocols/googlescopes
 */
- (instancetype)initWithScopes:(NSArray <NSString *> *)scopes NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
