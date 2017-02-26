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

#import "FUIAccountSettingsViewController+Internal.h"

#import "FUIAuthStrings.h"
#import "FUIStaticContentTableViewController.h"
#import <FirebaseAuth/FirebaseAuth.h>

@implementation FUIAccountSettingsViewController (ChangeName)

- (void)changeName {
  __block FUIStaticContentTableViewCell *cell =
      [FUIStaticContentTableViewCell cellWithTitle:[FUIAuthStrings name]
                                             value:self.auth.currentUser.displayName
                                            action:nil
                                              type:FUIStaticContentTableViewCellTypeInput];
  FUIStaticContentTableViewContent *contents =
    [FUIStaticContentTableViewContent contentWithSections:@[
      [FUIStaticContentTableViewSection sectionWithTitle:nil
                                                   cells:@[cell]],
    ]];

  UIViewController *controller =
      [[FUIStaticContentTableViewController alloc] initWithAuthUI:self.authUI
                                                         contents:contents nextTitle:[FUIAuthStrings save]
                                                       nextAction:^{
        [self onSaveName:cell.value];
      }];
  controller.title = @"Edit name";
  [self pushViewController:controller];
}

- (void)onSaveName:(NSString *)username {
  [self incrementActivity];
  FIRUserProfileChangeRequest *request = [self.auth.currentUser profileChangeRequest];
  request.displayName = username;
  [request commitChangesWithCompletion:^(NSError *_Nullable error) {
    [self decrementActivity];

    if (error) {
      [self finishSignUpWithUser:nil error:error];
      return;
    }
    [self finishSignUpWithUser:self.auth.currentUser error:nil];
    [self onBack];
    [self updateUI];
  }];
}

@end
