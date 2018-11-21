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

@class FIRAuthCredential;

NS_ASSUME_NONNULL_BEGIN

/** @class FUIPasswordVerificationViewController
    @brief The view controller that verifies user's password.
 */
@interface FUIPasswordVerificationViewController : FUIAuthBaseViewController

/** @fn initWithNibName:bundle:authUI:
    @brief Please use @c initWithAuthUI:email:.
 */
- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil
                         bundle:(nullable NSBundle *)nibBundleOrNil
                         authUI:(FUIAuth *)authUI NS_UNAVAILABLE;

/** @fn initWithAuthUI:
    @brief Please use @c initWithAuthUI:email:.
 */
- (instancetype)initWithAuthUI:(FUIAuth *)authUI NS_UNAVAILABLE;

/** @fn initWithNibName:bundle:authUI:email:newCredential:
    @brief Designated initializer.
    @param nibNameOrNil The name of the nib file to associate with the view controller.
    @param nibBundleOrNil The bundle in which to search for the nib file.
    @param authUI The @c FUIAuth instance that manages this view controller.
    @param email The email address of the user.
    @param newCredential The new @c FIRAuthCredential that the user had never used before.
 */
- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil
                         bundle:(nullable NSBundle *)nibBundleOrNil
                         authUI:(FUIAuth *)authUI
                          email:(NSString *_Nullable)email
                  newCredential:(FIRAuthCredential *)newCredential NS_DESIGNATED_INITIALIZER;

/** @fn initWithAuthUI:email:newCredential:
    @brief Convenience initializer.
    @param authUI The @c FUIAuth instance that manages this view controller.
    @param email The email address of the user.
    @param newCredential The new @c FIRAuthCredential that the user had never used before.
 */
- (instancetype)initWithAuthUI:(FUIAuth *)authUI
                          email:(NSString *_Nullable)email
                  newCredential:(FIRAuthCredential *)newCredential;

/** @fn forgotPassword
    @brief Method is called when user forgot password.
 */
- (void)forgotPassword;

/** @fn didChangePassword:
    @brief Should be called after any change of password value. Updates UI controls state
    (e g state of next button)
    @param password The password which user uses.
 */
- (void)didChangePassword:(NSString *)password;

/** @fn verifyPassword:
    @brief Should be called when user entered password. Sends authorization request
    @param password The password which user uses.
 */
- (void)verifyPassword:(NSString *)password;

@end

NS_ASSUME_NONNULL_END
