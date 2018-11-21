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

#import <UIKit/UIKit.h>

#import "FUIAuthBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

/** @class FUIPasswordSignInViewController
    @brief The view controller that asks for user's password.
 */
@interface FUIPasswordSignInViewController : FUIAuthBaseViewController

/** @fn initWithNibName:bundle:authUI:
    @brief Please use @c initWithNibName:bundle:authUI:email:.
 */
- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil
                         bundle:(nullable NSBundle *)nibBundleOrNil
                         authUI:(FUIAuth *)authUI NS_UNAVAILABLE;

/** @fn initWithAuthUI:
    @brief Please use @c initWithNibName:bundle:authUI:email:.
 */
- (instancetype)initWithAuthUI:(FUIAuth *)authUI NS_UNAVAILABLE;

/** @fn initWithNibName:bundle:authUI:email:
    @brief Designated initializer.
    @param nibNameOrNil The name of the nib file to associate with the view controller.
    @param nibBundleOrNil The bundle in which to search for the nib file.
    @param authUI The @c FUIAuth instance that manages this view controller.
    @param email The email address of the user.
 */
- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil
                         bundle:(nullable NSBundle *)nibBundleOrNil
                         authUI:(FUIAuth *)authUI
                         email:(NSString *_Nullable)email NS_DESIGNATED_INITIALIZER;

/** @fn initWithAuthUI:email:
    @brief Convenience initializer.
    @param authUI The @c FUIAuth instance that manages this view controller.
    @param email The email address of the user.
 */
- (instancetype)initWithAuthUI:(FUIAuth *)authUI
                          email:(NSString *_Nullable)email;

/** @fn forgotPasswordForEmail:
    @brief Method is called when user forgot password.
    @param email The email address of the user.
 */
- (void)forgotPasswordForEmail:(NSString *)email;

/** @fn didChangeEmail:andPassword:
    @brief Should be called after any change of email/password value. Updates UI controls state
    (e g state of next button)
    @param email The email address of the user.
    @param password The password which user uses.
 */
- (void)didChangeEmail:(NSString *)email andPassword:(NSString *)password;

/** @fn signInWithDefaultValue:andPassword:
    @brief Should be called when user entered credentials. Sends authorization request
    @param email The email address of the user.
    @param password The password which user uses.
 */
- (void)signInWithDefaultValue:(NSString *)email andPassword:(NSString *)password;

@end

NS_ASSUME_NONNULL_END
