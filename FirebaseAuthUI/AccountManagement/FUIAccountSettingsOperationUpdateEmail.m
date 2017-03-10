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

#import "FUIAccountSettingsOperationUpdateEmail.h"

#import "FUIAccountSettingsOperation_Internal.h"
#import "FUIAuthBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@implementation FUIAccountSettingsOperationUpdateEmail

- (void)execute:(BOOL)showDialog {
  if (showDialog) {
    [self showUpdateEmailDialog];
  } else {
    [self showUpdateEmailView];
  }
}

- (void)showUpdateEmailDialog {
  NSString *message;
    message = FUILocalizedString(kStr_UpdateEmailAlertMessage);
  [self showVerifyDialog:^{ [self showUpdateEmail]; } message:message];

}

- (void)showUpdateEmailView {
  [self showVerifyPasswordView:^{ [self showUpdateEmail]; }
                       message:FUILocalizedString(kStr_UpdateEmailVerificationAlertMessage)];
}

- (void)showUpdateEmail {
  __block FUIStaticContentTableViewCell *cell =
      [FUIStaticContentTableViewCell cellWithTitle:FUILocalizedString(kStr_Email)
                                             value:_delegate.auth.currentUser.email
                                            action:nil
                                              type:FUIStaticContentTableViewCellTypeInput];
  FUIStaticContentTableViewContent *contents =
    [FUIStaticContentTableViewContent contentWithSections:@[
      [FUIStaticContentTableViewSection sectionWithTitle:nil
                                                   cells:@[cell]],
    ]];


  UIViewController *controller =
      [[FUIStaticContentTableViewController alloc] initWithContents:contents
                                                          nextTitle:FUILocalizedString(kStr_Save)
                                                       nextAction:^{
        [self updateEmailForCurrentUser:cell.value];
      }];
  controller.title = FUILocalizedString(kStr_EditEmailTitle);
  [_delegate pushViewController:controller];

}

- (void)updateEmailForCurrentUser:(NSString *)email {
  if (![[FUIAuthBaseViewController class] isValidEmail:email]) {
    [self showAlertWithMessage:FUILocalizedString(kStr_InvalidEmailError)];
  } else {
    [_delegate incrementActivity];
    [_delegate.auth.currentUser updateEmail:email completion:^(NSError * _Nullable error) {
      [_delegate decrementActivity];
      [self finishOperationWithError:error];
      if (!error) {
        [_delegate presentBaseController];
      }
    }];
  }
}

@end

NS_ASSUME_NONNULL_END
