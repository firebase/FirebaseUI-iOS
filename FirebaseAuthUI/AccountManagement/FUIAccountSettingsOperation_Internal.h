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

#import "FUIAccountSettingsOperation.h"

#import <FirebaseAuth/FirebaseAuth.h>

#import "FUIAccountSettingsOperationType.h"
#import "FUIAuthStrings.h"
#import "FUIAuth_Internal.h"
#import "FUIStaticContentTableViewController.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^FUIAccountSettingsChooseProviderHandler)(id<FIRUserInfo> provider);
typedef void(^FUIAccountSettingsReauthenticateHandler)(void);

/** @class FUIAccountSettingsOperation
    @brief Internal methods which are not exposed for public usage.
 */
@interface FUIAccountSettingsOperation (Internal)

/** @fn initWithDelegate:
    @brief Creates new instance of @c FUIAccountSettingsOperation.
 */
- (nullable instancetype)initWithDelegate:(id<FUIAccountSettingsOperationUIDelegate>)delegate;

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

/** @fn showSelectProviderDialog:alertTitle:alertMessage:alertCloseButton:
    @brief Displays alert dialog with all available 3P providers.
    @param handler Block which is called when user selects any of 3P providers.
    @param title The title of the dialog
    @param message The message displayed in the alert body.
    @param closeActionTitle The title of the close button.
 */
- (void)showSelectProviderDialog:(nullable FUIAccountSettingsChooseProviderHandler)handler
                      alertTitle:(nullable NSString *)title
                    alertMessage:(nullable NSString *)message
                alertCloseButton:(nullable NSString *)closeActionTitle;

/** @fn showVerifyDialog:message:
    @brief Displays alert dialog when user need to verify it's identity.
    @param handler Block which is called when user selects any of 3P providers.
    @param message The message displayed in the alert body.
 */
- (void)showVerifyDialog:(nullable FUIAccountSettingsReauthenticateHandler)handler
                 message:(NSString *)message;


/** @fn showVerifyPasswordView:message:
    @brief Displays view with password input field when user need to verify it's identity.
    @param handler Block which is called when user selects any of 3P providers.
    @param message The message displayed in the alert body.
 */
- (void)showVerifyPasswordView:(nullable FUIAccountSettingsReauthenticateHandler)handler
                       message:(NSString *)message;
                       
- (void)showAlertWithMessage:(NSString *)message;

@end

NS_ASSUME_NONNULL_END
