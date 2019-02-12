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

/**
 * The methods in this category are exposed so that the FirebaseUI provider frameworks
 * can make use of them. They may change in non-breaking releases and should not be
 * used publicly.
 */
@interface FUIAuthBaseViewController (Internal)

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

/** @fn showAlertWithMessage:
    @brief Displays an alert view with given title and message on top of the current view
        controller.
    @param message The message of the alert.
 */
+ (void)showAlertWithMessage:(NSString *)message;

/** @fn showAlertWithMessage:presentingViewController:
    @brief Displays an alert view with given title and message on top of the current view
        controller.
    @param message The message of the alert.
    @param presentingViewController The controller which shows alert.
 */
+ (void)showAlertWithMessage:(NSString *)message
    presentingViewController:(nullable UIViewController *)presentingViewController;

/** @fn showAlertWithTitle:message:
    @brief Displays an alert view with given title, message and action title on top of the
        specified view controller.
    @param title The title of the alert.
    @param message The message of the alert.
    @param presentingViewController The controller which shows alert.
*/
+ (void)showAlertWithTitle:(nullable NSString *)title
                   message:(nullable NSString *)message
  presentingViewController:(nullable UIViewController *)presentingViewController;

/** @fn showAlertWithTitle:message:actionTitle:actionHandler:dismissTitle:dismissHandler:
    @brief Displays an alert view with given title, message and action title on top of the
        specified view controller.
    @param title The title of the alert.
    @param message The message of the alert.
    @param actionTitle The title of the action button.
    @param actionHandler The block to execute if the action button is tapped.
    @param dismissTitle The title of the dismiss button.
    @param dismissHandler The block to execute if the cancel button is tapped.
    @param presentingViewController The controller which shows alert.
*/
+ (void)showAlertWithTitle:(nullable NSString *)title
                   message:(nullable NSString *)message
               actionTitle:(nullable NSString *)actionTitle
             actionHandler:(nullable FUIAuthAlertActionHandler)actionHandler
              dismissTitle:(nullable NSString *)dismissTitle
            dismissHandler:(nullable FUIAuthAlertActionHandler)dismissHandler
  presentingViewController:(nullable UIViewController *)presentingViewController;

/** @fn showSignInAlertWithEmail:providerShortName:providerSignInLabel:handler:
    @brief Displays an alert to conform with user whether she wants to proceed with the provider.
    @param email The email address to sign in with.
    @param providerShortName The name of the provider as displayed in the sign-in alert message.
    @param providerSignInLabel The name of the provider as displayed in the sign-in alert button.
    @param signinHandler Handler for the sign in action of the alert.
    @param cancelHandler Handler for the cancel action of the alert.
 */
+ (void)showSignInAlertWithEmail:(NSString *)email
               providerShortName:(NSString *)providerShortName
             providerSignInLabel:(NSString *)providerSignInLabel
        presentingViewController:(UIViewController *)presentingViewController
                   signinHandler:(FUIAuthAlertActionHandler)signinHandler
                   cancelHandler:(FUIAuthAlertActionHandler)cancelHandler;

/** @fn pushViewController:
    @brief Push the view controller to the navigation controller of the current view controller
        with animation. The pushed view controller will have a fixed "Back" title for back button.
    @param viewController The view controller to be pushed.
 */
- (void)pushViewController:(UIViewController *)viewController;

/** @fn dismissNavigationControllerAnimated:completion:
    @brief dismiss navigation controller if it is not the rootViewController. If it is set as
        the rootViewController only perform the completion block.
    @param animated Use animation when dismissing the ViewControler.
    @param completion Code to be executed upon completion
 */
- (void)dismissNavigationControllerAnimated:(BOOL)animated
                                 completion:(void (^)(void))completion;

/** @fn pushViewController:
    @brief Push the view controller to the navigation controller of the current view controller
        with animation. The pushed view controller will have a fixed "Back" title for back button.
    @param viewController The view controller to be pushed.
    @param navigationController The controller where view controller is pushed.
 */
+ (void)pushViewController:(UIViewController *)viewController
      navigationController:(UINavigationController *)navigationController;

/** @fn providerLocalizedName:
    @brief Maps provider Id to localized provider name.
 */
+ (NSString *)providerLocalizedName:(NSString *)providerId;

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
