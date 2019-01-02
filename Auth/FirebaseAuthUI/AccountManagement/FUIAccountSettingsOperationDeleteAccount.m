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

#import "FUIAccountSettingsOperationDeleteAccount.h"

#import "FUIAccountSettingsOperation_Internal.h"
#import "FUIAccountSettingsOperationForgotPassword.h"

NS_ASSUME_NONNULL_BEGIN

@implementation FUIAccountSettingsOperationDeleteAccount

- (FUIAccountSettingsOperationType)operationType {
  return FUIAccountSettingsOperationTypeDeleteAccount;
}

- (void)execute:(BOOL)showDialog {
  if (showDialog) {
    [self showDeleteAccountDialog];
  } else {
    [self showDeleteAccountViewWithPassword];
  }
}

- (void)showDeleteAccountDialog {
  [self showSelectProviderDialogWithAlertTitle:
      FUILocalizedString(kStr_DeleteAccountConfirmationTitle)
                                  alertMessage:FUILocalizedString(kStr_DeleteAccountBody)
                              alertCloseButton:FUILocalizedString(kStr_Cancel)
                               providerHandler:^(id<FIRUserInfo> provider) {
    if (![provider.providerID isEqualToString:FIREmailAuthProviderID]) {
      [self reauthenticateWithProvider:provider.providerID actionHandler:^{
        [self showDeleteAccountView];
      }];
    } else {
      [self showDeleteAccountViewWithPassword];
    }
  }];
}

- (void)showDeleteAccountViewWithPassword {
  __block FUIStaticContentTableViewCell *passwordCell =
  [FUIStaticContentTableViewCell cellWithTitle:FUILocalizedString(kStr_Password)
                                         value:nil
                                   placeholder:FUILocalizedString(kStr_PlaceholderEnterPassword)
                                          type:FUIStaticContentTableViewCellTypePassword
                                        action:nil];
  FUIStaticContentTableViewContent *contents =
      [FUIStaticContentTableViewContent contentWithSections:@[
   [FUIStaticContentTableViewSection sectionWithTitle:nil cells:@[passwordCell]],
  ]];

  NSString *message = FUILocalizedString(kStr_DeleteAccountConfirmationMessage);
  UIViewController *controller =
      [[FUIStaticContentTableViewController alloc]
          initWithContents:contents
                 nextTitle:FUILocalizedString(kStr_Delete)
                nextAction:^{ [self deleteCurrentAccountWithPassword:passwordCell.value]; }
                headerText:message
                footerText:FUILocalizedString(kStr_ForgotPassword)
              footerAction:^{
        [FUIAccountSettingsOperationForgotPassword executeOperationWithDelegate:self.delegate];
      }];
  controller.title = FUILocalizedString(kStr_DeleteAccountControllerTitle);
  [self.delegate pushViewController:controller];
}

- (void)showDeleteAccountView {
  NSString *message = FUILocalizedString(kStr_DeleteAccountConfirmationMessage);
  UIViewController *controller =
      [[FUIStaticContentTableViewController alloc] initWithContents:nil
                                                          nextTitle:FUILocalizedString(kStr_Delete)
                                                         nextAction:^{
        [self onDeleteAccountViewNextAction];
      }
                                                         headerText:message];
  controller.title = FUILocalizedString(kStr_DeleteAccountControllerTitle);
  [self.delegate pushViewController:controller];

}

- (void)onDeleteAccountViewNextAction {
  UIAlertController *alertController =
    [UIAlertController alertControllerWithTitle:FUILocalizedString(kStr_DeleteAccountConfirmationTitle)
                                        message:FUILocalizedString(kStr_ActionCantBeUndone)
                                 preferredStyle:UIAlertControllerStyleAlert];
  UIAlertAction *deleteAction =
      [UIAlertAction actionWithTitle:FUILocalizedString(kStr_DeleteAccountControllerTitle)
                               style:UIAlertActionStyleDestructive
                             handler:^(UIAlertAction *_Nonnull action) {
       [self deleteCurrentAccount];
      }];
  UIAlertAction *action =
      [UIAlertAction actionWithTitle:FUILocalizedString(kStr_Cancel)
                               style:UIAlertActionStyleCancel
                             handler:nil];
  [alertController addAction:deleteAction];
  [alertController addAction:action];
  [self.delegate presentViewController:alertController];

}

- (void)deleteCurrentAccountWithPassword:(NSString *)password {
  [self reauthenticateWithPassword:password actionHandler:^{
    [self deleteCurrentAccount];
  }];
}

- (void)deleteCurrentAccount {
  [self.delegate incrementActivity];
  [self.delegate.auth.currentUser deleteWithCompletion:^(NSError *_Nullable error) {
    [self.delegate decrementActivity];
    [self finishOperationWithError:error];
    if (!error) {
      [self.delegate presentBaseController];
    }
  }];
}

@end

NS_ASSUME_NONNULL_END
