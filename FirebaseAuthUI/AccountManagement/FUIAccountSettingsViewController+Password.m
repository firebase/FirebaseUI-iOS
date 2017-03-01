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


@implementation FUIAccountSettingsViewController (Password)

- (void)showUpdatePasswordDialog:(BOOL)newPassword {
  NSString *message;
  if (newPassword) {
    message = @"To add password to your account, you will need to sign in again.";
  } else {
    message = @"To change password to your account, you will need to sign in again.";
  }

  [self showVerifyDialog:^{ [self showUpdatePassword:newPassword]; } message:message];

}

- (void)showUpdatePasswordView {
  [self showVerifyPasswordView:^{
    [self showUpdatePassword:NO];
  }
                       message:@"In oreder to change your password, you first need to enter your current password."];
}

- (void)showUpdatePassword:(BOOL)newPassword {
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
                                                          nextTitle:@"Save"
                                                       nextAction:^{
        [self updatePasswordForCurrentUser:passwordCell.value];
      }];
  if (newPassword) {
    controller.title = @"Add password";
  } else {
    controller.title = @"Change password";
  }
  [self pushViewController:controller];

}

- (void)updatePasswordForCurrentUser:(NSString *)password {
  if (!password.length) {
    [self showAlertWithMessage:[FUIAuthStrings weakPasswordError]];
  } else {
    NSLog(@"%s %@", __FUNCTION__, password);
    [self incrementActivity];
    [self.auth.currentUser updatePassword:password completion:^(NSError * _Nullable error) {
      [self decrementActivity];
      NSLog(@"updatePassword error %@", error);
      if (!error) {
        [self popToRoot];
        [self updateUI];
      } else {
        [self finishSignUpWithUser:self.auth.currentUser error:error];
      }
    }];
  }
}


@end
