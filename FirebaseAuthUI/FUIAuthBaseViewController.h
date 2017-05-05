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
@class FUIAuth;
@protocol FUIAuthProvider;

NS_ASSUME_NONNULL_BEGIN

/** @typedef FUIAuthAlertActionHandler
    @brief The type of block called when an alert view is dismissed by a user action.
 */
typedef void (^FUIAuthAlertActionHandler)(void);

/** @class FUIAuthBaseViewController
    @brief The base view controller that provides common methods for all subclasses.
 */
@interface FUIAuthBaseViewController : UIViewController

/** @property auth
    @brief The @c FIRAuth instance of the application.
 */
@property(nonatomic, strong, readonly) FIRAuth *auth;

/** @property authUI
    @brief The @c FUIAuth instance of the application.
 */
@property(nonatomic, strong, readonly) FUIAuth *authUI;

/** @fn init
    @brief Please use @c initWithNibName:bundle:authUI:.
 */
- (instancetype)init NS_UNAVAILABLE;

/** @fn initWithStyle:
    @brief Please use @c initWithNibName:bundle:authUI:.
 */
- (instancetype)initWithStyle:(UITableViewStyle)style NS_UNAVAILABLE;

/** @fn initWithNibName:bundle:
    @brief Please use @c initWithNibName:bundle:authUI:.
 */
- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil
                         bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;

/** @fn initWithNibName:bundle:authUI:
    @brief Designated initializer.
    @param nibNameOrNil The name of the nib file to associate with the view controller.
    @param nibBundleOrNil The bundle in which to search for the nib file.
    @param authUI The @c FUIAuth instance that manages this view controller.
 */
- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil
                         bundle:(nullable NSBundle *)nibBundleOrNil
                         authUI:(FUIAuth *)authUI NS_DESIGNATED_INITIALIZER;

/** @fn initWithAuthUI:
    @brief Convenience initializer.
    @param authUI The @c FUIAuth instance that manages this view controller.
 */
- (instancetype)initWithAuthUI:(FUIAuth *)authUI;

/** @fn isValidEmail:
    @brief Statically validates email address.
    @param email The email address to validate.
 */
+ (BOOL)isValidEmail:(NSString *)email;

/** @fn showAlertWithMessage:
    @brief Displays an alert view with given title and message on top of the current view
        controller.
    @param message The message of the alert.
 */
- (void)showAlertWithMessage:(NSString *)message;

/** @fn showAlertWithMessage:presentingViewController:
    @brief Displays an alert view with given title and message on top of the 
        specified view controller.
    @param message The message of the alert.
    @param presentingViewController The controller which shows alert.
 */
+ (void)showAlertWithMessage:(NSString *)message
    presentingViewController:(UIViewController *)presentingViewController;


/** @fn showAlertWithTitle:message:actionTitle:presentingViewController:
    @brief Displays an alert view with given title, message and action title  on top of the
        specified view controller.
    @param title The title of the alert.
    @param message The message of the alert.
    @param actionTitle The title of the action button.
    @param presentingViewController The controller which shows alert.
 */
+ (void)showAlertWithTitle:(nullable NSString *)title
                     message:(NSString *)message
                 actionTitle:(NSString *)actionTitle
    presentingViewController:(UIViewController *)presentingViewController;

/** @fn showSignInAlertWithEmail:provider:handler:
    @brief Displays an alert to conform with user whether she wants to proceed with the provider.
    @param email The email address to sign in with.
    @param provider The identity provider to sign in with.
    @param signinHandler Handler for the sign in action of the alert.
    @param cancelHandler Handler for the cancel action of the alert.
 */
+ (void)showSignInAlertWithEmail:(NSString *)email
                        provider:(id<FUIAuthProvider>)provider
        presentingViewController:(UIViewController *)presentingViewController
                   signinHandler:(FUIAuthAlertActionHandler)signinHandler
                   cancelHandler:(FUIAuthAlertActionHandler)cancelHandler;

/** @fn pushViewController:
    @brief Push the view controller to the navigation controller of the current view controller
        with animation. The pushed view controller will have a fixed "Back" title for back button.
    @param viewController The view controller to be pushed.
 */
- (void)pushViewController:(UIViewController *)viewController;

/** @fn pushViewController:
    @brief Push the view controller to the navigation controller of the current view controller
        with animation. The pushed view controller will have a fixed "Back" title for back button.
    @param viewController The view controller to be pushed.
    @param navigationController The controller where view controller is pushed.
 */
+ (void)pushViewController:(UIViewController *)viewController
      navigationController:(UINavigationController *)navigationController;

/** @fn onBack
    @brief Pops the view controller from navigation stack. If current controller is root 
    works as @c cancelAuthorization
 */
- (void)onBack;

/** @fn incrementActivity
    @brief Increment the current activity count. If there's positive number of activities, display
        and animate the activity indicator with a short period of delay.
    @remarks Calls to @c incrementActivity and @c decrementActivity should be balanced.
 */
- (void)incrementActivity;

/** @fn decrementActivity
    @brief Decrement the current activity count. If the count reaches 0, stop and hide the
        activity indicator.
    @remarks Calls to @c incrementActivity and @c decrementActivity should be balanced.
 */
- (void)decrementActivity;

/** @fn cancelAuthorization
    @brief Cancels Authorization flow, calls UI delegate callbacks and hides UI
 */
- (void)cancelAuthorization;

/** @fn providerLocalizedName:
    @brief Maps provider Id to localized provider name.
 */
+ (NSString *)providerLocalizedName:(NSString *)providerId;

/** @fn addActivityIndicator:
    @brief Creates and add activity indicator to the center of the specified view.
    @param view The View where indicator is shown.
 */
+ (UIActivityIndicatorView *)addActivityIndicator:(UIView *)view;

@end

NS_ASSUME_NONNULL_END
