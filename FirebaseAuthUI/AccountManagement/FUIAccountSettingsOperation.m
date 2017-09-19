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
#import "FUIAuthBaseViewController_Internal.h"
#import "FUIAuthErrorUtils.h"

NS_ASSUME_NONNULL_BEGIN

@implementation FUIAccountSettingsOperation

+ (instancetype)executeOperationWithDelegate:(id<FUIAccountSettingsOperationUIDelegate>)delegate
                          showDialog:(BOOL)showDialog {
  FUIAccountSettingsOperation *operation = [[self alloc] initWithDelegate:delegate];
  [operation execute:showDialog];
  return operation;
}

+ (instancetype)executeOperationWithDelegate:(id<FUIAccountSettingsOperationUIDelegate>)delegate {
  FUIAccountSettingsOperation *operation = [[self alloc] initWithDelegate:delegate];
  [operation execute:NO];
  return operation;
}

- (instancetype)initWithDelegate:(id<FUIAccountSettingsOperationUIDelegate>)operationDelegate {
  if (self = [super init]) {
    _delegate = operationDelegate;
  }
  return self;
}

- (void)execute:(BOOL)showDialog {
  NSAssert(NO, @"Expected execute: to be overwritten by subclass");
}

- (FUIAccountSettingsOperationType)operationType {
  NSAssert(NO, @"Expected execute: to be overwritten by subclass");
  return FUIAccountSettingsOperationTypeUnsupported;
}

#pragma mark - protected methods

- (void)finishOperationWithError:(nullable NSError *)error {
  if (error) {
    switch (error.code) {
      case FIRAuthErrorCodeEmailAlreadyInUse:
        [self showAlertWithMessage:FUILocalizedString(kStr_EmailAlreadyInUseError)];
        break;
      case FIRAuthErrorCodeInvalidEmail:
        [self showAlertWithMessage:FUILocalizedString(kStr_InvalidEmailError)];
        break;
      case FIRAuthErrorCodeWeakPassword:
        [self showAlertWithMessage:FUILocalizedString(kStr_WeakPasswordError)];
        break;
      case FIRAuthErrorCodeTooManyRequests:
        [self showAlertWithMessage:FUILocalizedString(kStr_SignUpTooManyTimesError)];
        break;
      case FIRAuthErrorCodeWrongPassword:
        [self showAlertWithMessage:FUILocalizedString(kStr_WrongPasswordError)];
        break;
      case FIRAuthErrorCodeUserNotFound:
        [self showAlertWithMessage:FUILocalizedString(kStr_UserNotFoundError)];
        break;
      case FIRAuthErrorCodeUserDisabled:
        [self showAlertWithMessage:FUILocalizedString(kStr_AccountDisabledError)];
        break;
      case FUIAuthErrorCodeCantFindProvider: {
        NSString *message = [NSString stringWithFormat:FUILocalizedString(kStr_CantFindProvider),
          error.userInfo[FUIAuthErrorUserInfoProviderIDKey]];
        [self showAlertWithMessage:message];
        break;
      }
      case FIRAuthErrorCodeUserMismatch:
        [self showAlertWithMessage:FUILocalizedString(kStr_EmailsDontMatch)];
        break;
    }
  }

  // TODO: Assistant Settings will be released later.
  // [self.delegate.authUI invokeOperationCallback:[self operationType] error:error];
}

- (void)showSelectProviderDialogWithAlertTitle:(nullable NSString *)title
                                  alertMessage:(nullable NSString *)message
                              alertCloseButton:(nullable NSString *)closeActionTitle
                               providerHandler:(nullable FUIAccountSettingsChooseProviderHandler)
                                               handler; {
  UIAlertController *alert =
    [UIAlertController alertControllerWithTitle:title
                                        message:message
                                 preferredStyle:UIAlertControllerStyleAlert];
  for (id<FIRUserInfo> provider in self.delegate.auth.currentUser.providerData) {
    NSString *providerTitle =
        [NSString stringWithFormat:FUILocalizedString(kStr_SignInWithProvider),
            [FUIAuthBaseViewController providerLocalizedName:provider.providerID]];
    UIAlertAction* action = [UIAlertAction actionWithTitle:providerTitle
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *_Nonnull action) {
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
  [self.delegate presentViewController:alert];
}

- (void)showAlertWithMessage:(NSString *)message {
  UIAlertController *alertController =
      [UIAlertController alertControllerWithTitle:nil
                                          message:message
                                   preferredStyle:UIAlertControllerStyleAlert];
  UIAlertAction *okAction = [UIAlertAction actionWithTitle:FUILocalizedString(kStr_OK)
                                                     style:UIAlertActionStyleDefault
                                                   handler:nil];
  [alertController addAction:okAction];
  [self.delegate presentViewController:alertController];
}

- (void)reauthenticateWithProvider:(NSString *)providerID
                     actionHandler:(nullable FUIAccountSettingsReauthenticateHandler)handler {

  id<FUIAuthProvider> providerUI;
  for (id<FUIAuthProvider> authProvider in self.delegate.authUI.providers) {
    if ([providerID isEqualToString:authProvider.providerID]) {
      providerUI = authProvider;
      break;
    }
  }

  if (!providerUI) {
    NSError *error = [FUIAuthErrorUtils errorWithCode:FUIAuthErrorCodeCantFindProvider
                                             userInfo:@{
      FUIAuthErrorUserInfoProviderIDKey : providerID
    }];
    [self finishOperationWithError:error];
    return;
  }

  [self.delegate incrementActivity];
  // Sign out first to make sure sign in starts with a clean state.
  [providerUI signOut];
  [providerUI signInWithDefaultValue:self.delegate.auth.currentUser.email
     presentingViewController:[self.delegate presentingController]
                   completion:^(FIRAuthCredential *_Nullable credential,
                                NSError *_Nullable error,
                                _Nullable FIRAuthResultCallback result) {
    if (error) {
      [self.delegate decrementActivity];
      [self finishOperationWithError:error];
      if (result) {
        result(nil, error);
      }
      return;
    }
    [self.delegate.auth.currentUser reauthenticateWithCredential:credential
                                                  completion:^(NSError *_Nullable reauthError) {
      [self.delegate decrementActivity];
      if (result) {
        result(self.delegate.auth.currentUser, reauthError);
      }
      if (error) {
        [self finishOperationWithError:error];
      } else {
        if (handler) {
          handler();
          [self finishOperationWithError:error];
        }
      }
    }];
  }];
}

- (void)reauthenticateWithPassword:(NSString *)password
                     actionHandler:(nullable FUIAccountSettingsReauthenticateHandler)handler {
  if (password.length <= 0) {
    [self showAlertWithMessage:FUILocalizedString(kStr_InvalidPasswordError)];
    return;
  }

  [self.delegate incrementActivity];

  [self.delegate.auth signInWithEmail:self.delegate.auth.currentUser.email
                             password:password
                           completion:^(FIRUser *_Nullable user, NSError *_Nullable error) {
    [self.delegate decrementActivity];

    [self finishOperationWithError:error];
    if (!error && handler) {
      handler();
    }
  }];
}

- (void)showVerifyDialogWithMessage:(NSString *)message
                    providerHandler:(nullable FUIAccountSettingsReauthenticateHandler)handler {
  [self showSelectProviderDialogWithAlertTitle:FUILocalizedString(kStr_VerifyItsYou)
                                  alertMessage:message
                              alertCloseButton:FUILocalizedString(kStr_Cancel)
                               providerHandler:^(id<FIRUserInfo> provider) {
    if (![provider.providerID isEqualToString:FIREmailAuthProviderID]) {
      [self reauthenticateWithProvider:provider.providerID actionHandler:handler];
    } else {
      [self showVerifyPasswordViewWithMessage:message providerHandler:handler];
    }
  }];
}

- (void)showVerifyPasswordViewWithMessage:(NSString *)message
                          providerHandler:(nullable FUIAccountSettingsReauthenticateHandler)
                                          handler {
  __block FUIStaticContentTableViewCell *passwordCell =
      [FUIStaticContentTableViewCell cellWithTitle:FUILocalizedString(kStr_Password)
                                             value:nil
                                       placeholder:FUILocalizedString(kStr_PlaceholderEnterPassword)
                                              type:FUIStaticContentTableViewCellTypePassword
                                            action:nil];
  FUIStaticContentTableViewContent *contents =
    [FUIStaticContentTableViewContent contentWithSections:@[
      [FUIStaticContentTableViewSection sectionWithTitle:nil
                                                   cells:@[passwordCell]],
    ]];

  UIViewController *controller =
      [[FUIStaticContentTableViewController alloc] initWithContents:contents
                                                          nextTitle:FUILocalizedString(kStr_Next)
                                                         nextAction:^{
        [self reauthenticateWithPassword:passwordCell.value actionHandler:handler];
      }
                                                         headerText:message
                                                         footerText:
          FUILocalizedString(kStr_ForgotPassword)
                                                       footerAction:^{
        [FUIAccountSettingsOperationForgotPassword executeOperationWithDelegate:self.delegate];
      }];
  controller.title = FUILocalizedString(kStr_VerifyItsYou);
  [self.delegate pushViewController:controller];
}

@end

NS_ASSUME_NONNULL_END
