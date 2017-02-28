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

#import "FUIAccountSettingsViewController+Common.h"

@implementation FUIAccountSettingsViewController (DeleteAccount)

- (void)deleteAccountWithLinkedProvider {
  [self showSelectProviderDialog:^(id<FIRUserInfo> provider) {
    if (![provider.providerID isEqualToString:FIREmailPasswordAuthProviderID]) {
      [self reauthenticateWithProviderUI:provider actionHandler:^{
        [self showDeleteAccountView];
      }];
    } else {
      [self showDeleteAccountViewWithPassword];
    }
  } alertTitle:@"Delete Account?"
                    alertMessage:@"This will erase all data associated with your account, and can't be undone You will need t osign in again to complete this action"
                alertCloseButton:[FUIAuthStrings cancel]];
}

- (void)showDeleteAccountView {
  NSString *message = @"This will erase all data assosiated with your account, and can't be undone. Are you sure you want to delete your account?";
  UIViewController *controller = [[FUIStaticContentTableViewController alloc]
                                    initWithContents:nil
                                    nextTitle:@"Delete"
                                    nextAction:^{ [self onDeleteAccountViewNextAction]; }
                                    headerText:message];
  // TODO: add localization
  controller.title = @"Delete account";
  [self pushViewController:controller];

}

- (void)showDeleteAccountViewWithPassword {
  __block FUIStaticContentTableViewCell *passwordCell =
  [FUIStaticContentTableViewCell cellWithTitle:[FUIAuthStrings password]
                                        action:nil
                                          type:FUIStaticContentTableViewCellTypePassword];
  FUIStaticContentTableViewContent *contents =
      [FUIStaticContentTableViewContent
           contentWithSections:@[
                                 [FUIStaticContentTableViewSection sectionWithTitle:nil
                                                                              cells:@[passwordCell]],
                                ]];

  NSString *message = @"This will erase all data assosiated with your account, and can't be undone. Are you sure you want to delete your account?";
  UIViewController *controller =
      [[FUIStaticContentTableViewController alloc]
          initWithContents:contents
                 nextTitle:@"Delete"
                nextAction:^{ [self deleteCurrentAccountWithPassword:passwordCell.value]; }
                headerText:message
                footerText:@"Forgot Password?"
              footerAction:^{ [self onForgotPassword]; }];
  // TODO: add localization
  controller.title = @"Delete account";
  [self pushViewController:controller];
}

- (void)onDeleteAccountViewNextAction {
  UIAlertController *alertController =
  [UIAlertController alertControllerWithTitle:@"Delete account?"
                                      message:@"This action can't be undone"
                               preferredStyle:UIAlertControllerStyleAlert];
  UIAlertAction *deleteAction =
      [UIAlertAction actionWithTitle:@"Delete Account"
                               style:UIAlertActionStyleDestructive
                             handler:^(UIAlertAction * _Nonnull action) {
                               [self deleteCurrentAccount];
                             }];
  UIAlertAction *action =
      [UIAlertAction actionWithTitle:[FUIAuthStrings cancel]
                               style:UIAlertActionStyleCancel
                             handler:nil];
  [alertController addAction:deleteAction];
  [alertController addAction:action];
  [self presentViewController:alertController animated:YES completion:nil];

}

- (void)deleteCurrentAccountWithPassword:(NSString *)password {
  [self reauthenticateWithPassword:password actionHandler:^{
    [self deleteCurrentAccount];
  }];
}

- (void)deleteCurrentAccount {
  [self incrementActivity];
  [self.auth.currentUser deleteWithCompletion:^(NSError * _Nullable error) {
    [self decrementActivity];
    if (!error) {
      [self onBack];
      [self updateUI];
    } else {
      [self finishSignUpWithUser:self.auth.currentUser error:error];
    }
  }];
}

- (void)onForgotPassword {
  __block FUIStaticContentTableViewCell *inputCell =
  [FUIStaticContentTableViewCell cellWithTitle:[FUIAuthStrings email]
                                        value:self.auth.currentUser.email
                                        action:nil
                                          type:FUIStaticContentTableViewCellTypeInput];
  FUIStaticContentTableViewContent *contents =
      [FUIStaticContentTableViewContent
           contentWithSections:@[
                                 [FUIStaticContentTableViewSection sectionWithTitle:nil
                                                                              cells:@[inputCell]],
                                ]];

  UIViewController *controller =
      [[FUIStaticContentTableViewController alloc]
           initWithContents:contents
                  nextTitle:[FUIAuthStrings send]
                 nextAction:^{ [self onPasswordRecovery:inputCell.value]; }
                 headerText:[FUIAuthStrings passwordRecoveryMessage]];
  controller.title = [FUIAuthStrings passwordRecoveryTitle];
  [self pushViewController:controller];
}

- (void)onPasswordRecovery:(NSString *)email {
  if (![[self class] isValidEmail:email]) {
    [self showAlertWithMessage:[FUIAuthStrings invalidEmailError]];
    return;
  }

  [self incrementActivity];

  [self.auth sendPasswordResetWithEmail:email
                             completion:^(NSError *_Nullable error) {
                               // The dispatch is a workaround for a bug in FirebaseAuth 3.0.2, which doesn't call the
                               // completion block on the main queue.
                               dispatch_async(dispatch_get_main_queue(), ^{
                                 [self decrementActivity];

                                 if (error) {
                                   if (error.code == FIRAuthErrorCodeUserNotFound) {
                                     [self showAlertWithMessage:[FUIAuthStrings userNotFoundError]];
                                     return;
                                   }

//                                   [self.navigationController dismissViewControllerAnimated:YES completion:^{
                                     [self.authUI invokeResultCallbackWithUser:nil error:error];
//                                   }];
                                   return;
                                 }

                                 NSString *message =
                                 [NSString stringWithFormat:[FUIAuthStrings passwordRecoveryEmailSentMessage], email];
                                 [self showAlertWithMessage:message];
                               });
                             }];
}

@end
