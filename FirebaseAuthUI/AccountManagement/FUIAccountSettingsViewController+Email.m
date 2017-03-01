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

@implementation FUIAccountSettingsViewController (Email)

- (void)showUpdateEmailDialog {
  NSString *message;
    message = @"To change email address associated with your your account, you will need to sign in again.";
  [self showVerifyDialog:^{ [self showUpdateEmail]; } message:message];

}

- (void)showUpdateEmailView {
  [self showVerifyPasswordView:^{
    [self showUpdateEmail];
  }
                       message:@"In oreder to change your password, you first need to enter your current password."];
}

- (void)showUpdateEmail {
  __block FUIStaticContentTableViewCell *cell =
      [FUIStaticContentTableViewCell cellWithTitle:[FUIAuthStrings email]
                                             value:self.auth.currentUser.email
                                            action:nil
                                              type:FUIStaticContentTableViewCellTypeInput];
  FUIStaticContentTableViewContent *contents =
    [FUIStaticContentTableViewContent contentWithSections:@[
      [FUIStaticContentTableViewSection sectionWithTitle:nil
                                                   cells:@[cell]],
    ]];


  UIViewController *controller =
      [[FUIStaticContentTableViewController alloc] initWithContents:contents
                                                          nextTitle:[FUIAuthStrings save]
                                                       nextAction:^{
        [self updateEmailForCurrentUser:cell.value];
      }];
  controller.title = @"Edit email";
  [self pushViewController:controller];

}

- (void)updateEmailForCurrentUser:(NSString *)email {
  if (![[self class] isValidEmail:email]) {
    [self showAlertWithMessage:[FUIAuthStrings invalidEmailError]];
  } else {
    [self incrementActivity];
    [self.auth.currentUser updateEmail:email completion:^(NSError * _Nullable error) {
      [self decrementActivity];
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
