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

- (void)showAddPasswordDialog {
  [self showSelectProviderDialog:^(id<FIRUserInfo> provider) {
    [self reauthenticateWithProviderUI:provider actionHandler:^{
      [self showAddPassword:YES];
    }];
  } alertTitle:@"Verify it's you"
                    alertMessage:@"To add password to your account, you will need to sign in again."
                alertCloseButton:[FUIAuthStrings cancel]];
}

- (void)showAddPassword:(BOOL)newPassword {
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
        [self onSetPasswordForCurrentUser:passwordCell.value];
      }];
  if (newPassword) {
    controller.title = @"Add password";
  } else {
    controller.title = @"Change password";
  }
  [self pushViewController:controller];

}

- (void)showVerifyPassword {
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
                                                          nextTitle:[FUIAuthStrings next]
                                                       nextAction:^{
        [self reauthenticateWithPassword:passwordCell.value actionHandler:^{
          [self showAddPassword:NO];
        }];
      }
      headerText:@"In oreder to change your password, you first need to enter your current password."
      footerText:@"Forgot password?" footerAction:^{
        [self onForgotPassword];
      }];
  controller.title = @"Verify it's you";
  [self pushViewController:controller];
}


- (void)onSetPasswordForCurrentUser:(NSString *)password {
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

- (void)linkAccount:(NSString *)password withCredential:(FIRAuthCredential *_Nullable)credential {
  [self incrementActivity];
//  [self.auth.currentUser updatePassword:password completion:^(NSError * _Nullable error) {
//    [self decrementActivity];
//    NSLog(@"updatePassword error %@", error);
//  }];

//  [self.auth signInWithEmail:self.auth.currentUser.email
//                    password:password
//                  completion:^(FIRUser *_Nullable user, NSError *_Nullable error) {
//                    if (error) {
//                      [self decrementActivity];
//
//                      [self showAlertWithMessage:[FUIAuthStrings wrongPasswordError]];
//                      return;
//                    }
//
//                    [user linkWithCredential:credential completion:^(FIRUser * _Nullable user,
//                                                                         NSError * _Nullable error) {
//                      [self decrementActivity];
//
//                      // Ignore any error (shouldn't happen) and treat the user as successfully signed in.
//                      [self.navigationController dismissViewControllerAnimated:YES completion:^{
//                        [self.authUI invokeResultCallbackWithUser:user error:nil];
//                      }];
//                    }];
//                  }];
//

  [self.auth createUserWithEmail:self.auth.currentUser.email
                        password:password
                      completion:^(FIRUser *_Nullable user, NSError *_Nullable error) {
    if (error) {
      [self decrementActivity];

      [self finishSignUpWithUser:nil error:error];
      return;
    }

    [user linkWithCredential:credential completion:^(FIRUser * _Nullable user,
                                                         NSError * _Nullable error) {
      [self decrementActivity];

      // Ignore any error (shouldn't happen) and treat the user as successfully signed in.
//      [self.navigationController dismissViewControllerAnimated:YES completion:^{
//        [self.authUI invokeResultCallbackWithUser:user error:nil];
//      }];
      if (error) {
        [self finishSignUpWithUser:nil error:error];
        return;
      }
      [self finishSignUpWithUser:user error:nil];

    }];


//    FIRUserProfileChangeRequest *request = [user profileChangeRequest];
//    request.displayName = username;
//    [request commitChangesWithCompletion:^(NSError *_Nullable error) {
//      [self decrementActivity];
//
//      if (error) {
//        [self finishSignUpWithUser:nil error:error];
//        return;
//      }
//      [self finishSignUpWithUser:user error:nil];
//    }];
  }];

}


@end
