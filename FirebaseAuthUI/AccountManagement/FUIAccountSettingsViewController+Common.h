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

#import "FUIAccountSettingsViewController+ChangeName.h"
#import "FUIAccountSettingsViewController+Password.h"
#import "FUIAccountSettingsViewController+DeleteAccount.h"
#import "FUIAccountSettingsViewController.h"
#import "FUIAuthStrings.h"
#import "FUIAuth_Internal.h"
#import "FUIStaticContentTableViewController.h"
#import <FirebaseAuth/FirebaseAuth.h>
#import <FirebaseCore/FirebaseCore.h>

@protocol FIRUserInfo;

typedef void(^FUIAccountSettingsChoseProvider)(id<FIRUserInfo> provider);
typedef void(^FUIAccountSettingsreauthenticateHandler)(void);


@interface FUIAccountSettingsViewController (Common)

- (void)finishSignUpWithUser:(FIRUser *)user error:(NSError *)error;

- (void)updateUI;

- (void)showSelectProviderDialog:(FUIAccountSettingsChoseProvider)handler
                      alertTitle:(NSString *)title
                    alertMessage:(NSString *)message
                alertCloseButton:(nullable NSString *)closeActionTitle;

- (void)reauthenticateWithProviderUI:(id<FIRUserInfo>)provider
               actionHandler:(FUIAccountSettingsreauthenticateHandler)handler;

- (void)reauthenticateWithPassword:(NSString *)password
                     actionHandler:(FUIAccountSettingsreauthenticateHandler)handler;

- (void)showVerifyDialog:(FUIAccountSettingsreauthenticateHandler)handler
                 message:(NSString *)message;

- (void)showVerifyPasswordView:(FUIAccountSettingsreauthenticateHandler)handler
                       message:(NSString *)message;

- (void)onForgotPassword;

/** @fn popToRoot
    @brief Pops the view controller to root navigation controller.
 */
 - (void)popToRoot;

@end
