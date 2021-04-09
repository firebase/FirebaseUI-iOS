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

#import "FirebaseAuthUI/Sources/FUIAccountSettingsOperationUpdatePassword.h"

#import "FirebaseAuthUI/Sources/FUIAccountSettingsOperation_Internal.h"

NS_ASSUME_NONNULL_BEGIN

@interface FUIAccountSettingsOperationUpdatePassword ()
{
  BOOL _newPassword;
}
@end

@implementation FUIAccountSettingsOperationUpdatePassword

+ (instancetype)executeOperationWithDelegate:(id<FUIAccountSettingsOperationUIDelegate>)delegate
                                  showDialog:(BOOL)showDialog
                                 newPassword:(BOOL)newPassword {
  FUIAccountSettingsOperationUpdatePassword *operation =
      [[self alloc] initWithDelegate:delegate newPassword:newPassword];
  [operation execute:showDialog];
  return operation;
}

- (instancetype)initWithDelegate:(id<FUIAccountSettingsOperationUIDelegate>)delegate
                     newPassword:(BOOL)newPassword {
  if (self = [super initWithDelegate:delegate]) {
    _newPassword = newPassword;
  }
  return self;
}

- (FUIAccountSettingsOperationType)operationType {
  return FUIAccountSettingsOperationTypeUpdatePassword;
}

- (void)execute:(BOOL)showDialog {
  if (showDialog) {
    [self showUpdatePasswordDialog:_newPassword];
  } else {
    [self showUpdatePasswordView];
  }
}

- (void)showUpdatePasswordDialog:(BOOL)newPassword {
  NSString *message;
  if (newPassword) {
    message = FUILocalizedString(kStr_AddPasswordAlertMessage);
  } else {
    message = FUILocalizedString(kStr_EditPasswordAlertMessage);
  }

  [self showVerifyDialogWithMessage:message
                    providerHandler:^{ [self showUpdatePassword:newPassword]; }];

}

- (void)showUpdatePasswordView {
  [self showVerifyPasswordViewWithMessage:
      FUILocalizedString(kStr_ReauthenticateEditPasswordAlertMessage)
                          providerHandler:^{ [self showUpdatePassword:NO]; }];
}

- (void)showUpdatePassword:(BOOL)newPassword {
  NSString *placeHolder = newPassword ? FUILocalizedString(kStr_PlaceholderChosePassword) :
                                        FUILocalizedString(kStr_PlaceholderNewPassword);
  __block FUIStaticContentTableViewCell *passwordCell =
      [FUIStaticContentTableViewCell cellWithTitle:FUILocalizedString(kStr_Password)
                                             value:nil
                                       placeholder:placeHolder
                                              type:FUIStaticContentTableViewCellTypePassword
                                            action:nil];
  FUIStaticContentTableViewContent *contents =
    [FUIStaticContentTableViewContent contentWithSections:@[
      [FUIStaticContentTableViewSection sectionWithTitle:nil
                                                   cells:@[passwordCell]],
    ]];

  UIViewController *controller =
      [[FUIStaticContentTableViewController alloc] initWithContents:contents
                                                          nextTitle:FUILocalizedString(kStr_Save)
                                                       nextAction:^{
        [self updatePasswordForCurrentUser:passwordCell.value];
      }];
  if (newPassword) {
    controller.title = FUILocalizedString(kStr_AddPasswordTitle);
  } else {
    controller.title = FUILocalizedString(kStr_EditPasswordTitle);
  }
  [self.delegate pushViewController:controller];

}

- (void)updatePasswordForCurrentUser:(NSString *)password {
  if (!password.length) {
    [self showAlertWithMessage:FUILocalizedString(kStr_WeakPasswordError)];
  } else {
    [self.delegate incrementActivity];
    [self.delegate.auth.currentUser updatePassword:password completion:^(NSError *_Nullable error) {
      [self.delegate decrementActivity];
      [self finishOperationWithError:error];
      if (!error) {
        [self.delegate presentBaseController];
      }
    }];
  }
}

@end

NS_ASSUME_NONNULL_END
