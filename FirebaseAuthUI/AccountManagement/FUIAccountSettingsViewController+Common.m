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

#import <FirebaseAuth/FirebaseAuth.h>
#import "FUIAuthStrings.h"
#import "FUIAuth_Internal.h"

@implementation FUIAccountSettingsViewController (Common)

- (void)finishSignUpWithUser:(FIRUser *)user error:(NSError *)error {
  if (error) {
    switch (error.code) {
      case FIRAuthErrorCodeEmailAlreadyInUse:
        [self showAlertWithMessage:[FUIAuthStrings emailAlreadyInUseError]];
        return;
      case FIRAuthErrorCodeInvalidEmail:
        [self showAlertWithMessage:[FUIAuthStrings invalidEmailError]];
        return;
      case FIRAuthErrorCodeWeakPassword:
        [self showAlertWithMessage:[FUIAuthStrings weakPasswordError]];
        return;
      case FIRAuthErrorCodeTooManyRequests:
        [self showAlertWithMessage:[FUIAuthStrings signUpTooManyTimesError]];
        return;
      case FIRAuthErrorCodeWrongPassword:
        [self showAlertWithMessage:[FUIAuthStrings wrongPasswordError]];
        return;
      case FIRAuthErrorCodeUserNotFound:
        [self showAlertWithMessage:[FUIAuthStrings userNotFoundError]];
        return;
      case FIRAuthErrorCodeUserDisabled:
        [self showAlertWithMessage:[FUIAuthStrings accountDisabledError]];
        return;
    }
  }

  [self.authUI invokeResultCallbackWithUser:user error:nil];

}

- (void)showSelectProviderDialog:(FUIAccountSettingsChoseProvider)handler
                      alertTitle:(NSString *)title
                    alertMessage:(NSString *)message
                alertCloseButton:(nullable NSString *)closeActionTitle {
  UIAlertController *alert =
  [UIAlertController alertControllerWithTitle:title
                                      message:message
                               preferredStyle:UIAlertControllerStyleAlert];

  for (id<FIRUserInfo> provider in self.auth.currentUser.providerData) {
    UIAlertAction* action = [UIAlertAction
                             actionWithTitle:provider.providerID
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * _Nonnull action) {
                               if (handler) {
                                 handler(provider);
                               }
                             }];
    [alert addAction:action];
  }
  UIAlertAction* closeButton = [UIAlertAction
                                actionWithTitle:closeActionTitle
                                style:UIAlertActionStyleCancel
                                handler:nil];
  [alert addAction:closeButton];
  [self presentViewController:alert animated:YES completion:nil];

}

- (void)reauthenticateWithProviderUI:(id<FIRUserInfo>)provider
               actionHandler:(FUIAccountSettingsreauthenticateHandler)handler {

  id providerUI;
  for (id<FUIAuthProvider> authProvider in self.authUI.providers) {
    if ([provider.providerID isEqualToString:authProvider.providerID]) {
      providerUI = authProvider;
      break;
    }
  }

  if (!providerUI) {
    // TODO: Show alert or print error
    NSLog(@"Can't find provider for %@", provider.providerID);
    return;
  }

  [self incrementActivity];
  // Sign out first to make sure sign in starts with a clean state.
  [providerUI signOut];
  [providerUI signInWithEmail:self.auth.currentUser.email
     presentingViewController:self
                   completion:^(FIRAuthCredential *_Nullable credential,
                                NSError *_Nullable error) {
                     if (error) {
                       [self decrementActivity];

                       if (error.code == FUIAuthErrorCodeUserCancelledSignIn) {
                         // User cancelled sign in, Do nothing.
                         return;
                       }

                       // TODO: Shoul we do anything here?
                       //                       [self.navigationController dismissViewControllerAnimated:YES completion:^{
                       //                         [self.authUI invokeResultCallbackWithUser:nil error:error];
                       //                       }];
                       return;
                     }


                     //                     FIRAuth *secondAuth = [self createFIRAuth];
                     [self.auth.currentUser reauthenticateWithCredential:credential
                                                              completion:^(NSError *_Nullable error) {
                                                                [self decrementActivity];
                                                                if ((error && error.code == FIRAuthErrorCodeUserMismatch)) {
                                                                  // TODO: Shoul we do anything here? It's not possible
                                                                  //                                              NSString *email = error.userInfo[kErrorUserInfoEmailKey];
                                                                  //                                              [self handleAccountLinkingForEmail:email newCredential:credential];
                                                                  [self showAlertWithMessage:@"Emails don't match"];
                                                                } else if (error) {
                                                                  [self showAlertWithMessage:@"Reauthenticate error"];
                                                                } else {
                                                                  if (handler) {
                                                                    handler();
                                                                  }
                                                                }
                                                                
                                                              }];
                   }];
}

- (void)reauthenticateWithPassword:(NSString *)password
                     actionHandler:(FUIAccountSettingsreauthenticateHandler)handler {
  if (password.length <= 0) {
    [self showAlertWithMessage:[FUIAuthStrings invalidPasswordError]];
    return;
  }

  [self incrementActivity];

  [self.auth signInWithEmail:self.auth.currentUser.email
                    password:password
                  completion:^(FIRUser *_Nullable user, NSError *_Nullable error) {
                    [self decrementActivity];

                    [self finishSignUpWithUser:user error:error];
                    if (!error && handler) {
                      handler();
                    }
                  }];
}

- (void)showVerifyDialog:(FUIAccountSettingsreauthenticateHandler)handler
                 message:(NSString *)message {
  [self showSelectProviderDialog:^(id<FIRUserInfo> provider) {
    if (![provider.providerID isEqualToString:FIREmailPasswordAuthProviderID]) {
      [self reauthenticateWithProviderUI:provider actionHandler:handler];
    } else {
      [self showVerifyPasswordView:handler message:message];
    }
  } alertTitle:@"Verify it's you"
                    alertMessage:message
                alertCloseButton:[FUIAuthStrings cancel]];
}

- (void)showVerifyPasswordView:(FUIAccountSettingsreauthenticateHandler)handler
                       message:(NSString *)message {
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
        [self reauthenticateWithPassword:passwordCell.value actionHandler:handler];
      }
      headerText:message
      footerText:@"Forgot password?" footerAction:^{
        [self onForgotPassword];
      }];
  controller.title = @"Verify it's you";
  [self pushViewController:controller];
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

- (void)popToRoot {
  [self.navigationController popToViewController:self animated:YES];
}

@end
