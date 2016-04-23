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

@class FIRAuth;
@class FIRAuthUI;
@protocol FIRAuthProviderUI;

NS_ASSUME_NONNULL_BEGIN

/** @typedef FIRAuthUIAlertActionHandler
    @brief The type of block called when an alert view is dismissed by a user action.
 */
typedef void (^FIRAuthUIAlertActionHandler)(void);

/** @class FIRAuthUIBaseViewController
    @brief The base view controller that provides common methods for all subclasses.
 */
@interface FIRAuthUIBaseViewController : UITableViewController

/** @property auth
    @brief The @c FIRAuth instance of the application.
 */
@property(nonatomic, strong, readonly) FIRAuth *auth;

/** @property authUI
    @brief The @c FIRAuth instance of the application.
 */
@property(nonatomic, strong, readonly) FIRAuthUI *authUI;

/** @fn init
    @brief Please use @c initWithAuthUI:.
 */
- (nullable instancetype)init NS_UNAVAILABLE;

/** @fn initWithStyle:
    @brief Please use @c initWithAuthUI:.
 */
- (instancetype)initWithStyle:(UITableViewStyle)style NS_UNAVAILABLE;

/** @fn initWithNibName:bundle:
    @brief Please use @c initWithAuthUI:.
 */
- (instancetype)initWithNibName:(NSString *_Nullable)nibNameOrNil
                         bundle:(NSBundle *_Nullable)nibBundleOrNil NS_UNAVAILABLE;

/** @fn initWithAuthUI:
    @brief Designated initializer.
    @param authUI The @c FIRAuthUI instance that manages this view controller.
 */
- (instancetype)initWithAuthUI:(FIRAuthUI *)authUI NS_DESIGNATED_INITIALIZER;

/** @fn isValidEmail:
    @brief Statically validates email address.
    @param email The email address to validate.
 */
+ (BOOL)isValidEmail:(NSString *)email;

/** @fn showAlertWithTitle:message:
    @brief Displays an alert view with given title and message on top of the current view
        controller.
    @param title The title of the alert.
    @param message The message of the alert.
 */
- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message;

/** @fn showSignInAlertWithEmail:provider:handler:
    @brief Displays an alert to conform with user whether she wants to proceed with the provider.
    @param email The email address to sign in with.
    @param provider The identity provider to sign in with.
    @param handler Handler for the sign in action of the alert.
 */
- (void)showSignInAlertWithEmail:(NSString *)email
                        provider:(id<FIRAuthProviderUI>)provider
                         handler:(FIRAuthUIAlertActionHandler)handler;

@end

NS_ASSUME_NONNULL_END
