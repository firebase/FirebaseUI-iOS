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

#import "FirebaseAuthUI/Sources/FUIAccountSettingsOperationUpdateEmail.h"

#import "FirebaseAuthUI/Sources/FUIAccountSettingsOperation_Internal.h"
#import "FirebaseAuthUI/Sources/Public/FirebaseAuthUI/FUIAuthBaseViewController_Internal.h"

NS_ASSUME_NONNULL_BEGIN

@implementation FUIAccountSettingsOperationUpdateEmail

- (FUIAccountSettingsOperationType)operationType {
  return FUIAccountSettingsOperationTypeUpdateEmail;
}

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
  [self showVerifyDialogWithMessage:message providerHandler:^{ [self showUpdateEmail]; }];

}

- (void)showUpdateEmailView {
  [self showVerifyPasswordViewWithMessage:
      FUILocalizedString(kStr_UpdateEmailVerificationAlertMessage)
                          providerHandler:^{ [self showUpdateEmail]; }];
}

- (void)showUpdateEmail {
  __block FUIStaticContentTableViewCell *cell =
      [FUIStaticContentTableViewCell cellWithTitle:FUILocalizedString(kStr_Email)
                                             value:self.delegate.auth.currentUser.email
                                       placeholder:FUILocalizedString(kStr_PlaceholderEnterEmail)
                                              type:FUIStaticContentTableViewCellTypeInput
                                            action:nil];
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
  [self.delegate pushViewController:controller];

}

- (void)updateEmailForCurrentUser:(NSString *)email {
  if (![[FUIAuthBaseViewController class] isValidEmail:email]) {
    [self showAlertWithMessage:FUILocalizedString(kStr_InvalidEmailError)];
  } else {
    [self.delegate incrementActivity];
    [self.delegate.auth.currentUser updateEmail:email completion:^(NSError *_Nullable error) {
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
