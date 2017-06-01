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

#import "FUIAuthBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface FUIAuthBaseViewController (Internal)

/** @typedef FUIAuthAlertActionHandler
    @brief The type of block called when an alert view is dismissed by a user action.
 */
typedef void (^FUIAuthAlertActionHandler)(void);

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

/** @fn providerLocalizedName:
    @brief Maps provider Id to localized provider name.
 */
+ (NSString *)providerLocalizedName:(NSString *)providerId;

/** @fn addActivityIndicator:
    @brief Creates and add activity indicator to the center of the specified view.
    @param view The View where indicator is shown.
 */
+ (UIActivityIndicatorView *)addActivityIndicator:(UIView *)view;

/** @fn barItemWithTitle:target:action:
    @brief Creates multiline @c UIBarButtonItem of fixed width.
    @param title The title of the button.
    @param target The target object of the @c UIBarButtonItem .
    @param action The action called when button is selected.
 */
+ (UIBarButtonItem *)barItemWithTitle:(NSString *)title
                               target:(nullable id)target
                               action:(SEL)action;

/** @fn enableDynamicCellHeightForTableView:
    @brief Configures table view in the way than it resizes rows according to their height.
    @param tableView The tableView which is going to be configured.
 */
- (void)enableDynamicCellHeightForTableView:(UITableView *)tableView;

@end

NS_ASSUME_NONNULL_END
