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

#import "FirebaseAuthUI/Sources/FUIAccountSettingsOperationForgotPassword.h"

#import "FirebaseAuthUI/Sources/FUIAccountSettingsOperation_Internal.h"
#import "FirebaseAuthUI/Sources/Public/FirebaseAuthUI/FUIAuthBaseViewController_Internal.h"

NS_ASSUME_NONNULL_BEGIN

@implementation FUIAccountSettingsOperationForgotPassword

- (FUIAccountSettingsOperationType)operationType {
  return FUIAccountSettingsOperationTypeForgotPassword;
}

- (void)execute:(BOOL)showDialog {
  [self onForgotPassword];
}

- (void)onForgotPassword {
  __block FUIStaticContentTableViewCell *inputCell =
  [FUIStaticContentTableViewCell cellWithTitle:FUILocalizedString(kStr_Email)
                                         value:self.delegate.auth.currentUser.email
                                         placeholder:FUILocalizedString(kStr_PlaceholderEnterEmail)
                                          type:FUIStaticContentTableViewCellTypeInput
                                        action:nil];
  FUIStaticContentTableViewContent *contents =
      [FUIStaticContentTableViewContent
           contentWithSections:@[
                                 [FUIStaticContentTableViewSection sectionWithTitle:nil
                                                                              cells:@[inputCell]],
                                ]];

  UIViewController *controller =
      [[FUIStaticContentTableViewController alloc]
           initWithContents:contents
                  nextTitle:FUILocalizedString(kStr_Send)
                 nextAction:^{ [self onPasswordRecovery:inputCell.value]; }
                 headerText:FUILocalizedString(kStr_PasswordRecoveryMessage)];
  controller.title = FUILocalizedString(kStr_PasswordRecoveryTitle);
  [self.delegate pushViewController:controller];
}

- (void)onPasswordRecovery:(NSString *)email {
  if (![[FUIAuthBaseViewController class] isValidEmail:email]) {
    [self showAlertWithMessage:FUILocalizedString(kStr_InvalidEmailError)];
    return;
  }

  [self.delegate incrementActivity];

  [self.delegate.auth sendPasswordResetWithEmail:email
                             completion:^(NSError *_Nullable error) {
    [self.delegate decrementActivity];

    if (error) {
      [self finishOperationWithError:error];
      return;
    }

    NSString *message = [NSString stringWithFormat:
                            FUILocalizedString(kStr_PasswordRecoveryEmailSentMessage), email];
    UIAlertController *alertController =
        [UIAlertController alertControllerWithTitle:nil
                                            message:message
                                     preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:FUILocalizedString(kStr_OK)
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *_Nonnull action) {
                                [self finishOperationWithError:error];
                              }];
    [alertController addAction:okAction];
    [self.delegate presentViewController:alertController];
  }];
}

@end

NS_ASSUME_NONNULL_END
