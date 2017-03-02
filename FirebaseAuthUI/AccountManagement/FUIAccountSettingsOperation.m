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

#import "FUIAccountSettingsOperation_Internal.h"

#import "FUIAuthBaseViewController.h"
#import "FUIAccountSettingsOperationUnlinkAccount.h"
#import "FUIAccountSettingsOperationUpdateName.h"
#import "FUIAccountSettingsOperationDeleteAccount.h"
#import "FUIAccountSettingsOperationUpdateEmail.h"
#import "FUIAccountSettingsOperationUpdatePassword.h"
#import "FUIAccountSettingsOperationForgotPassword.h"
#import "FUIAccountSettingsOperationSignOut.h"

@implementation FUIAccountSettingsOperation

+ (instancetype)createOperation:(FUIAccountSettingsOperationType)operationType
                   withDelegate:(id<FUIAccountSettingsOperationDelegate>)delegate {
  return [[[self classForOperation:operationType] alloc] initWithDelegate:delegate];
}

- (instancetype)initWithDelegate:(id<FUIAccountSettingsOperationDelegate>)delegate {
  if (self = [super init]) {
    _delegate = delegate;
  }

  return self;
}

- (void)execute:(BOOL)showDialog {
  
}

#pragma mark - protected methods

- (void)finishOperationWithUser:(nullable FIRUser *)user error:(NSError *)error {
  if (error) {
    switch (error.code) {
      case FIRAuthErrorCodeEmailAlreadyInUse:
        [self showAlertWithMessage:[FUIAuthStrings emailAlreadyInUseError]];
        return;
      case FIRAuthErrorCodeInvalidEmail:
        [self showAlertWithMessage:[FUIAuthStrings invalidEmailError]];
        return;
      case FIRAuthErrorCodeWeakPassword:
        [self showAlertWithMessage:[FUIAuthStrings weakPasswordError]];
        return;
      case FIRAuthErrorCodeTooManyRequests:
        [self showAlertWithMessage:[FUIAuthStrings signUpTooManyTimesError]];
        return;
      case FIRAuthErrorCodeWrongPassword:
        [self showAlertWithMessage:[FUIAuthStrings wrongPasswordError]];
        return;
      case FIRAuthErrorCodeUserNotFound:
        [self showAlertWithMessage:[FUIAuthStrings userNotFoundError]];
        return;
      case FIRAuthErrorCodeUserDisabled:
        [self showAlertWithMessage:[FUIAuthStrings accountDisabledError]];
        return;
      case FIRAuthErrorCodeUserMismatch:
        [self showAlertWithMessage:@"Emails don't match"];
        return;
    }
  }

  [[FUIAuth defaultAuthUI] invokeResultCallbackWithUser:user error:nil];
}

- (void)showSelectProviderDialog:(FUIAccountSettingsChooseProviderHandler)handler
                      alertTitle:(NSString *)title
                    alertMessage:(NSString *)message
                alertCloseButton:(nullable NSString *)closeActionTitle {
  UIAlertController *alert =
  [UIAlertController alertControllerWithTitle:title
                                      message:message
                               preferredStyle:UIAlertControllerStyleAlert];

  for (id<FIRUserInfo> provider in _delegate.auth.currentUser.providerData) {
    UIAlertAction* action = [UIAlertAction
                             actionWithTitle:provider.providerID
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * _Nonnull action) {
                               if (handler) {
                                 handler(provider);
                               }
                             }];
    [alert addAction:action];
  }
  UIAlertAction* closeButton = [UIAlertAction
                                actionWithTitle:closeActionTitle
                                style:UIAlertActionStyleCancel
                                handler:nil];
  [alert addAction:closeButton];
  [_delegate presentViewController:alert];

}

- (void)showAlertWithMessage:(NSString *)message {
  UIAlertController *alertController =
  [UIAlertController alertControllerWithTitle:nil
                                      message:message
                               preferredStyle:UIAlertControllerStyleAlert];
  UIAlertAction *okAction =
  [UIAlertAction actionWithTitle:[FUIAuthStrings OK]
                           style:UIAlertActionStyleDefault
                         handler:nil];
  [alertController addAction:okAction];
  [_delegate presentViewController:alertController];
}

- (void)reauthenticateWithProviderUI:(id<FIRUserInfo>)provider
               actionHandler:(FUIAccountSettingsReauthenticateHandler)handler {

  id providerUI;
  for (id<FUIAuthProvider> authProvider in _delegate.authUI.providers) {
    if ([provider.providerID isEqualToString:authProvider.providerID]) {
      providerUI = authProvider;
      break;
    }
  }

  if (!providerUI) {
    // TODO: Show alert or print error
    NSLog(@"Can't find provider for %@", provider.providerID);
    return;
  }

  [_delegate incrementActivity];
  // Sign out first to make sure sign in starts with a clean state.
  [providerUI signOut];
  [providerUI signInWithEmail:_delegate.auth.currentUser.email
     presentingViewController:_delegate
                   completion:^(FIRAuthCredential *_Nullable credential,
                                NSError *_Nullable error) {
                     if (error) {
                       [_delegate decrementActivity];
                       [self finishOperationWithUser:_delegate.auth.currentUser error:error];
                       return;
                     }
                     [_delegate.auth.currentUser reauthenticateWithCredential:credential
                                                              completion:^(NSError *_Nullable error) {
                                                                [_delegate decrementActivity];
                                                                if (error) {
                                                                  [self finishOperationWithUser:_delegate.auth.currentUser error:error];
                                                               } else {
                                                                  if (handler) {
                                                                    handler();
                                                                  }
                                                                }
                                                                
                                                              }];
                   }];
}

- (void)reauthenticateWithPassword:(NSString *)password
                     actionHandler:(FUIAccountSettingsReauthenticateHandler)handler {
  if (password.length <= 0) {
    [self showAlertWithMessage:[FUIAuthStrings invalidPasswordError]];
    return;
  }

  [_delegate incrementActivity];

  [_delegate.auth signInWithEmail:_delegate.auth.currentUser.email
                    password:password
                  completion:^(FIRUser *_Nullable user, NSError *_Nullable error) {
                    [_delegate decrementActivity];

                    [self finishOperationWithUser:user error:error];
                    if (!error && handler) {
                      handler();
                    }
                  }];
}

- (void)showVerifyDialog:(FUIAccountSettingsReauthenticateHandler)handler
                 message:(NSString *)message {
  [self showSelectProviderDialog:^(id<FIRUserInfo> provider) {
    if (![provider.providerID isEqualToString:FIREmailPasswordAuthProviderID]) {
      [self reauthenticateWithProviderUI:provider actionHandler:handler];
    } else {
      [self showVerifyPasswordView:handler message:message];
    }
  } alertTitle:@"Verify it's you"
                    alertMessage:message
                alertCloseButton:[FUIAuthStrings cancel]];
}

- (void)showVerifyPasswordView:(FUIAccountSettingsReauthenticateHandler)handler
                       message:(NSString *)message {
  __block FUIStaticContentTableViewCell *passwordCell =
      [FUIStaticContentTableViewCell cellWithTitle:[FUIAuthStrings password]
                                            action:nil
                                              type:FUIStaticContentTableViewCellTypePassword];
  FUIStaticContentTableViewContent *contents =
    [FUIStaticContentTableViewContent contentWithSections:@[
      [FUIStaticContentTableViewSection sectionWithTitle:nil
                                                   cells:@[passwordCell]],
    ]];


  UIViewController *controller =
      [[FUIStaticContentTableViewController alloc] initWithContents:contents
                                                          nextTitle:[FUIAuthStrings next]
                                                       nextAction:^{
        [self reauthenticateWithPassword:passwordCell.value actionHandler:handler];
      }
      headerText:message
      footerText:@"Forgot password?" footerAction:^{
        [[FUIAccountSettingsOperation createOperation:FUIAccountSettingsOperationTypeForgotPassword withDelegate:_delegate ] execute:NO];
      }];
  controller.title = @"Verify it's you";
  [_delegate pushViewController:controller];
}



#pragma mark - helper methods

+ (Class)classForOperation:(FUIAccountSettingsOperationType)operationType {
  Class operationClass;
  switch (operationType) {
    case FUIAccountSettingsOperationTypeUnlinkAccount:
      operationClass = [FUIAccountSettingsOperationUnlinkAccount class];
      break;
    case FUIAccountSettingsOperationTypeUpdateName:
      operationClass = [FUIAccountSettingsOperationUpdateName class];
      break;
    case FUIAccountSettingsOperationTypeDeleteAccount:
      operationClass = [FUIAccountSettingsOperationDeleteAccount class];
      break;
    case FUIAccountSettingsOperationTypeUpdateEmail:
      operationClass = [FUIAccountSettingsOperationUpdateEmail class];
      break;
    case FUIAccountSettingsOperationTypeUpdatePassword:
      operationClass = [FUIAccountSettingsOperationUpdatePassword class];
      break;
    case FUIAccountSettingsOperationTypeForgotPassword:
      operationClass = [FUIAccountSettingsOperationForgotPassword class];
      break;
    case FUIAccountSettingsOperationTypeSignOut:
      operationClass = [FUIAccountSettingsOperationSignOut class];
      break;

    default:
      break;
  }

  return operationClass;
  
}

@end
