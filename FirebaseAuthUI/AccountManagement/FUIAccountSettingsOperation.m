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

#import "FUIAccountSettingsOperationDeleteAccount.h"
#import "FUIAccountSettingsOperationForgotPassword.h"
#import "FUIAccountSettingsOperationSignOut.h"
#import "FUIAccountSettingsOperationUnlinkAccount.h"
#import "FUIAccountSettingsOperationUpdateEmail.h"
#import "FUIAccountSettingsOperationUpdateName.h"
#import "FUIAccountSettingsOperationUpdatePassword.h"
#import "FUIAuthBaseViewController.h"
#import "FUIAuthErrorUtils.h"

NS_ASSUME_NONNULL_BEGIN

@implementation FUIAccountSettingsOperation

+ (void)executeOperationWithDelegate:(id<FUIAccountSettingsOperationUIDelegate>)delegate
                                 showDialog:(BOOL)showDialog {
  [[[self alloc] initWithDelegate:delegate] execute:showDialog];
}

+ (void)executeOperationWithDelegate:(id<FUIAccountSettingsOperationUIDelegate>)delegate {
  [[[self alloc] initWithDelegate:delegate] execute:NO];
}

- (instancetype)initWithDelegate:(id<FUIAccountSettingsOperationUIDelegate>)delegate {
  if (self = [super init]) {
    _delegate = delegate;
  }

  return self;
}

- (void)execute:(BOOL)showDialog {
  // This method should always be overriden.
  [self doesNotRecognizeSelector:_cmd];
}

- (FUIAccountSettingsOperationType)operationType {
    static NSDictionary* classMap = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      classMap = @{
        NSStringFromClass([FUIAccountSettingsOperationUpdateName class]) :
            @(FUIAccountSettingsOperationTypeUpdateName),
        NSStringFromClass([FUIAccountSettingsOperationUpdatePassword class]) :
            @(FUIAccountSettingsOperationTypeUpdatePassword),
          NSStringFromClass([FUIAccountSettingsOperationForgotPassword class]) : @(FUIAccountSettingsOperationTypeForgotPassword),
        NSStringFromClass([FUIAccountSettingsOperationUpdateEmail class]) :
            @(FUIAccountSettingsOperationTypeUpdateEmail),
        NSStringFromClass([FUIAccountSettingsOperationUnlinkAccount class]) :
            @(FUIAccountSettingsOperationTypeUnlinkAccount),
        NSStringFromClass([FUIAccountSettingsOperationSignOut class]) :
            @(FUIAccountSettingsOperationTypeSignOut),
        NSStringFromClass([FUIAccountSettingsOperationDeleteAccount class]) :
            @(FUIAccountSettingsOperationTypeDeleteAccount)
      };
    });
  return [classMap[NSStringFromClass([self class])] integerValue];
}

#pragma mark - protected methods

- (void)finishOperationWithError:(nullable NSError *)error {
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
      case FUIAuthErrorCodeCantFindProvider:
        {
          NSString *message = [NSString stringWithFormat:@"Can't find provider for %@",
            error.userInfo[FUIAuthErrorUserInfoProviderIDKey]];
          [self showAlertWithMessage:message];
          return;
        }
      case FIRAuthErrorCodeUserMismatch:
        [self showAlertWithMessage:@"Emails don't match"];
        return;
    }
  }

  [[FUIAuth defaultAuthUI] invokeOperationCallback:[self operationType] error:error];
}

- (void)showSelectProviderDialog:(nullable FUIAccountSettingsChooseProviderHandler)handler
                      alertTitle:(nullable NSString *)title
                    alertMessage:(nullable NSString *)message
                alertCloseButton:(nullable NSString *)closeActionTitle {
  UIAlertController *alert =
  [UIAlertController alertControllerWithTitle:title
                                      message:message
                               preferredStyle:UIAlertControllerStyleAlert];

  for (id<FIRUserInfo> provider in _delegate.auth.currentUser.providerData) {
    UIAlertAction* action = [UIAlertAction actionWithTitle:provider.providerID
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * _Nonnull action) {
      if (handler) {
        handler(provider);
      }
    }];
    [alert addAction:action];
  }
  UIAlertAction* closeButton = [UIAlertAction actionWithTitle:closeActionTitle
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
  UIAlertAction *okAction = [UIAlertAction actionWithTitle:[FUIAuthStrings OK]
                                                     style:UIAlertActionStyleDefault
                                                   handler:nil];
  [alertController addAction:okAction];
  [_delegate presentViewController:alertController];
}

- (void)reauthenticateWithProvider:(NSString *)providerID
                    actionHandlier:(nullable FUIAccountSettingsReauthenticateHandler)handler {

  id providerUI;
  for (id<FUIAuthProvider> authProvider in _delegate.authUI.providers) {
    if ([providerID isEqualToString:authProvider.providerID]) {
      providerUI = authProvider;
      break;
    }
  }

  if (!providerUI) {
    // TODO: Show alert or print error
    NSError *error = [FUIAuthErrorUtils errorWithCode:FUIAuthErrorCodeCantFindProvider
                                             userInfo:@{
      FUIAuthErrorUserInfoProviderIDKey : providerID
    }];
    [self finishOperationWithError:error];
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
     [self finishOperationWithError:error];
     return;
    }
    [_delegate.auth.currentUser reauthenticateWithCredential:credential
                                                  completion:^(NSError *_Nullable error) {
      [_delegate decrementActivity];
      if (error) {
        [self finishOperationWithError:error];
      } else {
        if (handler) {
          handler();
        }
      }
    }];
  }];
}

- (void)reauthenticateWithPassword:(NSString *)password
                     actionHandler:(nullable FUIAccountSettingsReauthenticateHandler)handler {
  if (password.length <= 0) {
    [self showAlertWithMessage:[FUIAuthStrings invalidPasswordError]];
    return;
  }

  [_delegate incrementActivity];

  [_delegate.auth signInWithEmail:_delegate.auth.currentUser.email
                    password:password
                  completion:^(FIRUser *_Nullable user, NSError *_Nullable error) {
    [_delegate decrementActivity];

    [self finishOperationWithError:error];
    if (!error && handler) {
      handler();
    }
  }];
}

- (void)showVerifyDialog:(nullable FUIAccountSettingsReauthenticateHandler)handler
                 message:(NSString *)message {
  [self showSelectProviderDialog:^(id<FIRUserInfo> provider) {
    if (![provider.providerID isEqualToString:FIREmailPasswordAuthProviderID]) {
      [self reauthenticateWithProvider:provider.providerID actionHandler:handler];
    } else {
      [self showVerifyPasswordView:handler message:message];
    }
  }
                      alertTitle:@"Verify it's you"
                    alertMessage:message
                alertCloseButton:[FUIAuthStrings cancel]];
}

- (void)showVerifyPasswordView:(nullable FUIAccountSettingsReauthenticateHandler)handler
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
                                                         footerText:@"Forgot password?"
                                                       footerAction:^{
        [FUIAccountSettingsOperationForgotPassword executeOperationWithDelegate:_delegate];
      }];
  controller.title = @"Verify it's you";
  [_delegate pushViewController:controller];
}

@end

NS_ASSUME_NONNULL_END
