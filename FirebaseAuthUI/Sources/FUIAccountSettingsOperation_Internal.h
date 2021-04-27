//
//  Copyright (c) 2017 Google Inc.
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

#import "FirebaseAuthUI/Sources/FUIAccountSettingsOperation.h"

#import <FirebaseAuth/FirebaseAuth.h>

#import "FirebaseAuthUI/Sources/Public/FirebaseAuthUI/FUIAccountSettingsOperationType.h"
#import "FirebaseAuthUI/Sources/Public/FirebaseAuthUI/FUIAuthStrings.h"
#import "FirebaseAuthUI/Sources/Public/FirebaseAuthUI/FUIAuth_Internal.h"
#import "FirebaseAuthUI/Sources/FUIStaticContentTableViewController.h"

NS_ASSUME_NONNULL_BEGIN

/** @typedef FUIAccountSettingsChooseProviderHandler
    @brief The type of block invoked when a select provider dialog button is tapped.
 */
typedef void(^FUIAccountSettingsChooseProviderHandler)(id<FIRUserInfo> provider);

/** @typedef FUIAccountSettingsReauthenticateHandler
    @brief The type of block invoked when reathentication operation is finished.
 */
typedef void(^FUIAccountSettingsReauthenticateHandler)(void);

/** Internal methods which are not exposed for public usage. */
@interface FUIAccountSettingsOperation ()

/** @fn initWithDelegate:
    @brief Creates new instance of @c FUIAccountSettingsOperation.
 */
- (instancetype)initWithDelegate:(id<FUIAccountSettingsOperationUIDelegate>)delegate;

/** @fn finishOperationWithError:
    @brief Callback which is used for notification of operation result.
 */
- (void)finishOperationWithError:(nullable NSError *)error;

/** @fn reauthenticateWithProvider:actionHandler:
    @brief Reauthenticates currently logged-in user with specified 3P porviderID.
    @param providerID The ID of third party provider.
    @param handler Block which is called when user was re-authenticated. 
 */
- (void)reauthenticateWithProvider:(NSString *)providerID
                     actionHandler:(nullable FUIAccountSettingsReauthenticateHandler)handler;

/** @fn reauthenticateWithPassword:actionHandler:
    @brief Reauthenticates currently logged-in user with 'password' auth provider.
    @param password Value of the password used for re-authentication of currently loggen-in user.
    @param handler Block which is called when user was re-authenticated. 
 */
- (void)reauthenticateWithPassword:(NSString *)password
                     actionHandler:(nullable FUIAccountSettingsReauthenticateHandler)handler;

/** @fn showSelectProviderDialogWithAlertTitle:alertMessage:alertCloseButton:providerHandler:
    @brief Displays alert dialog with all available 3P providers.
    @param title The title of the dialog
    @param message The message displayed in the alert body.
    @param closeActionTitle The title of the close button.
    @param handler Block which is called when user selects any of 3P providers.
 */
- (void)showSelectProviderDialogWithAlertTitle:(nullable NSString *)title
                                  alertMessage:(nullable NSString *)message
                              alertCloseButton:(nullable NSString *)closeActionTitle
                               providerHandler:(nullable FUIAccountSettingsChooseProviderHandler)
                                               handler;

/** @fn showVerifyDialogWithMessage:providerHandler:
    @brief Displays alert dialog when user need to verify it's identity.
    @param message The message displayed in the alert body.
    @param handler Block which is called when user selects any of 3P providers.
 */
- (void)showVerifyDialogWithMessage:(NSString *)message
                    providerHandler:(nullable FUIAccountSettingsReauthenticateHandler)handler;

/** @fn showVerifyPasswordViewWithMessage:providerHandler:
    @brief Displays view with password input field when user need to verify it's identity.
    @param message The message displayed in the alert body.
    @param handler Block which is called when user selects any of 3P providers.
 */
- (void)showVerifyPasswordViewWithMessage:(NSString *)message
                          providerHandler:(nullable FUIAccountSettingsReauthenticateHandler)handler;
                       
/** @fn showAlertWithMessage:message:
    @brief Displays alert view with with specified message and OK button.
    @param message The message displayed in the alert body.
 */
- (void)showAlertWithMessage:(NSString *)message;

/** @property delegate
    @brief The operation UI delegate which handles all UI callbacks.
 */
@property(nonatomic, weak, readonly) id<FUIAccountSettingsOperationUIDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
