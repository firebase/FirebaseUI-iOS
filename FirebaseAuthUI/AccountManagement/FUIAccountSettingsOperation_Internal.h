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


@interface FUIAccountSettingsOperation (Internal)

- (instancetype)initWithDelegate:(id<FUIAccountSettingsOperationDelegate>)delegate;

- (void)finishOperationWithError:(NSError *)error;

- (void)reauthenticateWithProviderUI:(id<FIRUserInfo>)provider
               actionHandler:(FUIAccountSettingsReauthenticateHandler)handler;

- (void)reauthenticateWithPassword:(NSString *)password
                     actionHandler:(FUIAccountSettingsReauthenticateHandler)handler;

- (void)showAlertWithMessage:(NSString *)message;

- (void)showSelectProviderDialog:(FUIAccountSettingsChooseProviderHandler)handler
                      alertTitle:(NSString *)title
                    alertMessage:(NSString *)message
                alertCloseButton:(nullable NSString *)closeActionTitle;

- (void)showVerifyDialog:(FUIAccountSettingsReauthenticateHandler)handler
                 message:(NSString *)message;

- (void)showVerifyPasswordView:(FUIAccountSettingsReauthenticateHandler)handler
                       message:(NSString *)message;
@end

NS_ASSUME_NONNULL_END
