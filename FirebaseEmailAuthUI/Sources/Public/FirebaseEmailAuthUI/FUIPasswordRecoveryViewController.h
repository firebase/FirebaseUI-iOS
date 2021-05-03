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

#import <FirebaseAuthUI/FUIAuthBaseViewController.h>

NS_ASSUME_NONNULL_BEGIN

/** @class FUIPasswordRecoveryViewController
    @brief The view controller that asks for user's password.
 */
@interface FUIPasswordRecoveryViewController : FUIAuthBaseViewController

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

/** @fn didChangeEmail:
    @brief Should be called after any change of email value. Updates UI controls state
    (e g state of send button)
    @param email The email address of the user.
 */
- (void)didChangeEmail:(NSString *)email;

/** @fn recoverEmail:
    @brief Should be called when user want to recover password for specified email.
    Sends email recover request.
    @param email The email address of the user.
 */
- (void)recoverEmail:(NSString *)email;
@end

NS_ASSUME_NONNULL_END
