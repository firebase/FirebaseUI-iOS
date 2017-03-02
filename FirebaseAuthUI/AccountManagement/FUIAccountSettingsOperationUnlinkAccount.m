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

#import "FUIAccountSettingsOperationUnlinkAccount.h"

#import "FUIAccountSettingsOperation_Internal.h"

@implementation FUIAccountSettingsOperationUnlinkAccount

- (void)execute:(BOOL)showDialog {
  __block FUIStaticContentTableViewCell *cell =
      [FUIStaticContentTableViewCell cellWithTitle:self.provider.providerID
                                             value:self.provider.displayName
                                            action:nil
                                              type:FUIStaticContentTableViewCellTypeDefault];
  FUIStaticContentTableViewContent *contents =
    [FUIStaticContentTableViewContent contentWithSections:@[
      [FUIStaticContentTableViewSection sectionWithTitle:nil
                                                   cells:@[cell]],
    ]];


  UIViewController *controller =
      [[FUIStaticContentTableViewController alloc] initWithContents:contents
                                                          nextTitle:@"Unlink"
                                                       nextAction:^{
          [self showUnlinkConfirmationDialog];
      }];
  controller.title = @"Linked account";
  [_delegate pushViewController:controller];
}

- (void)showUnlinkConfirmationDialog {
  UIAlertController *alertController =
  [UIAlertController alertControllerWithTitle:@"Unlink account?"
                                      message:@"You will no longer be able to sign in using your account"
                               preferredStyle:UIAlertControllerStyleAlert];
  UIAlertAction *action =
  [UIAlertAction actionWithTitle:@"Unlink account"
                           style:UIAlertActionStyleDestructive
                         handler:^(UIAlertAction *_Nonnull action) {
                           [self unlinkAcount];
                         }];
  [alertController addAction:action];
  UIAlertAction *cancelAction =
  [UIAlertAction actionWithTitle:[FUIAuthStrings cancel]
                           style:UIAlertActionStyleCancel
                         handler:nil];
  [alertController addAction:cancelAction];
  [_delegate presentViewController:alertController];
}

- (void)unlinkAcount {
  [[FIRAuth auth].currentUser unlinkFromProvider:self.provider.providerID
                                      completion:^(FIRUser * _Nullable user,
                                                   NSError * _Nullable error) {
      [self finishOperationWithUser:user error:error];
      [_delegate presentBaseController];
  }];
}

@end
