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

/** @class FUIAuthBaseViewController
    @brief The base view controller that provides common methods for all subclasses.
 */
@interface FUIAuthBaseViewController : UIViewController

/** @typedef FUIAuthAlertActionHandler
 @brief The type of block called when an alert view is dismissed by a user action.
 */
typedef void (^FUIAuthAlertActionHandler)(void);

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
    @brief Convenience initializer. If your custom auth picker controller is using its
      own nib file, this initializer should be overwritten.
    @param authUI The @c FUIAuth instance that manages this view controller.
 */
- (instancetype)initWithAuthUI:(FUIAuth *)authUI;

/** @fn onBack
    @brief Pops the view controller from navigation stack. If current controller is root 
    works as @c cancelAuthorization
 */
- (void)onBack;

/** @fn cancelAuthorization
    @brief Cancels Authorization flow, calls UI delegate callbacks and hides UI
 */
- (void)cancelAuthorization;

/** @fn showSignInAlertWithEmail:provider:handler:
 @brief Displays an alert asking the user to confirm whether or not they want to proceed with the selected provider.
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

/** @fn incrementActivity
 @brief Increment the current activity count. If there's positive number of activities, display
 and animate the activity indicator with a short delay.
 @remarks Calls to @c incrementActivity and @c decrementActivity should be balanced.
 */
- (void)incrementActivity;

/** @fn decrementActivity
 @brief Decrement the current activity count. If the count reaches 0, stop and hide the
 activity indicator.
 @remarks Calls to @c incrementActivity and @c decrementActivity should be balanced.
 */
- (void)decrementActivity;

/** @fn addActivityIndicator:
 @briefCreates and adds an activity indicator to the center of the specified view.
 @param view The view where indicator is shown.
 */
+ (UIActivityIndicatorView *)addActivityIndicator:(UIView *)view;

@end

NS_ASSUME_NONNULL_END
