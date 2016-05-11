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

#import "FIRAuthUIBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

/** @class FIRPasswordSignInViewController
    @brief The view controller that asks for user's password.
 */
@interface FIRPasswordSignInViewController : FIRAuthUIBaseViewController

/** @fn initWithNibName:bundle:authUI:
    @brief Please use @c initWithAuthUI:email:.
 */
- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil
                         bundle:(nullable NSBundle *)nibBundleOrNil
                         authUI:(FIRAuthUI *)authUI NS_UNAVAILABLE;

/** @fn initWithAuthUI:
    @brief Please use @c initWithAuthUI:email:.
 */
- (instancetype)initWithAuthUI:(FIRAuthUI *)authUI NS_UNAVAILABLE;

/** @fn initWithAuthUI:email:
    @brief Designated initializer.
    @param authUI The @c FIRAuthUI instance that manages this view controller.
    @param email The email address of the user.
 */
- (instancetype)initWithAuthUI:(FIRAuthUI *)authUI
                         email:(NSString *_Nullable)email NS_DESIGNATED_INITIALIZER;

/** @fn forgotPassword
    @brief IBAction when user forgot password.
 */
- (IBAction)forgotPassword;

@end

NS_ASSUME_NONNULL_END
