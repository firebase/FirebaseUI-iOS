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

#import <FirebaseUI/FirebaseAuthUI.h>

@class FBSDKLoginManager;
NS_ASSUME_NONNULL_BEGIN

/** @class FUIFacebookAuth
    @brief AuthUI components for Facebook Login.
 */
@interface FUIFacebookAuth : NSObject <FUIAuthProvider>
{
  @protected
  /** @var _loginManager
   @brief The Facebook login manager.
   */
  FBSDKLoginManager *_loginManager;

}

/** @property scopes
    @brief The scopes to use with Facebook Login.
    @remarks Defaults to using "email" scopes.
 */
@property(nonatomic, readonly, copy) NSArray<NSString *> *scopes;

/** @fn init
    @brief Conevenience initializer. Uses a default permission of `@[ "email" ]`.
 */
- (instancetype)init;

/** @fn initWithPermissions:
    @brief Designated initializer.
    @param permissions The permissions of the app. This array must be an array of specific string values
      as defined in https://developers.facebook.com/docs/facebook-login/permissions/
 */
- (instancetype)initWithPermissions:(NSArray *)permissions NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
