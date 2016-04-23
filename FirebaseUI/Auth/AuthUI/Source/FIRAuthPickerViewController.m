//
//  Copyright (c) 2016 Google Inc.
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

#import "FIRAuthPickerViewController.h"

#import <FirebaseAuth/FirebaseAuth.h>
#import "FIRAuthProviderUI.h"
#import "FIRAuthUIErrorUtils.h"
#import "FIRAuthUIStrings.h"
#import "FIRAuthUI_Internal.h"
#import "FIREmailEntryViewController.h"
#import "FIRPasswordVerificationViewController.h"

/** @var kCellReuseIdentifier
    @brief The reuse identifier for table view cell.
 */
static NSString *const kCellReuseIdentifier = @"cellReuseIdentifier";

static NSString *const kErrorUserInfoEmailKey = @"FIRAuthErrorUserInfoEmailKey";

@interface FIRAuthPickerViewController () <UITableViewDataSource, UITableViewDelegate>
@end

@implementation FIRAuthPickerViewController

- (instancetype)initWithAuthUI:(FIRAuthUI *)authUI {
  self = [super initWithAuthUI:authUI];
  if (self) {
    self.title = [FIRAuthUIStrings authPickerTitle];
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  UIBarButtonItem *cancelBarButton =
      [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                    target:self
                                                    action:@selector(cancel)];
  self.navigationItem.leftBarButtonItem = cancelBarButton;
}

#pragma mark - Actions

- (void)signInWithEmail {
  UIViewController *controller =
      [[FIREmailEntryViewController alloc] initWithAuthUI:self.authUI];
  [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.authUI.signInProviders.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellReuseIdentifier];
  if (!cell) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                  reuseIdentifier:kCellReuseIdentifier];
  }

  NSArray<id<FIRAuthProviderUI>> *signInProviders = self.authUI.signInProviders;
  NSString *cellText;
  if (indexPath.row == signInProviders.count) {
    cellText = [FIRAuthUIStrings signInWithEmail];
  } else {
    cellText = signInProviders[indexPath.row].signInLabel;
  }
  cell.textLabel.text = [cellText uppercaseStringWithLocale:[NSLocale currentLocale]];
  cell.textLabel.font = [UIFont systemFontOfSize:14];
  cell.textLabel.textColor = [UIColor grayColor];
  #warning TODO(chaowei) add provider/email icon to the cell.
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  NSArray<id<FIRAuthProviderUI>> *signInProviders = self.authUI.signInProviders;
  if (indexPath.row == signInProviders.count) {
    [self signInWithEmail];
  } else {
    [self signInWithProvider:signInProviders[indexPath.row]];
  }
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)signInWithProvider:(id<FIRAuthProviderUI>)provider {
  [provider FIRAuth:self.auth
      signInWithPresentingViewController:self
                              completion:^(FIRAuthCredential *_Nullable credential,
                                           NSError *_Nullable error) {
    if (error) {
      [self.navigationController dismissViewControllerAnimated:YES completion:^{
        [self.authUI invokeResultCallbackWithUser:nil error:error];
      }];
      return;
    }

    [self.auth signInWithCredential:credential
                         completion:^(FIRUser *_Nullable user, NSError *_Nullable error) {
      if (error && error.code == FIRAuthErrorCodeEmailAlreadyInUse) {
        NSString *email = error.userInfo[kErrorUserInfoEmailKey];
        [self handleAccountLinkingForEmail:email newCredential:credential];
        return;
      }

      [self.navigationController dismissViewControllerAnimated:YES completion:^{
        [self.authUI invokeResultCallbackWithUser:user error:error];
      }];
    }];
  }];
}

- (void)handleAccountLinkingForEmail:(NSString *)email
                       newCredential:(FIRAuthCredential *)newCredential {
  [self.auth fetchProvidersForEmail:email
                         completion:^(NSArray<NSString *> *_Nullable providers,
                                      NSError *_Nullable error) {
    if (error) {
      if (error.code == FIRAuthErrorCodeInvalidEmail) {
        // This should never happen because the email address comes from the backend.
        [self showAlertWithTitle:[FIRAuthUIStrings error]
                         message:[FIRAuthUIStrings invalidEmailError]];
      } else {
        [self.navigationController dismissViewControllerAnimated:YES completion:^{
          [self.authUI invokeResultCallbackWithUser:nil error:error];
        }];
      }
      return;
    }
    if (!providers.count) {
      // This should never happen because the user must be registered.
      [self showAlertWithTitle:[FIRAuthUIStrings error]
                       message:[FIRAuthUIStrings cannotAuthenticateError]];
      return;
    }
    NSString *bestProviderID = providers[0];
    if ([bestProviderID isEqual:FIREmailPasswordAuthProviderID]) {
      // Password verification.
      UIViewController *controller =
          [[FIRPasswordVerificationViewController alloc] initWithAuthUI:self.authUI
                                                                  email:email
                                                          newCredential:newCredential];
      [self.navigationController pushViewController:controller animated:YES];
      return;
    }
    id<FIRAuthProviderUI> bestProvider = [self providerWithID:bestProviderID];
    if (!bestProvider) {
      // Unsupported provider.
      [self showAlertWithTitle:[FIRAuthUIStrings error]
                       message:[FIRAuthUIStrings cannotAuthenticateError]];
      return;
    }

    [self showSignInAlertWithEmail:email provider:bestProvider handler:^{
      [bestProvider FIRAuth:self.auth
          signInWithPresentingViewController:self
                                  completion:^(FIRAuthCredential *_Nullable credential,
                                               NSError *_Nullable error) {
        [self.auth signInWithCredential:credential completion:^(FIRUser *_Nullable user,
                                                                NSError *_Nullable error) {
          if (error) {
            [self.navigationController dismissViewControllerAnimated:YES completion:^{
              [self.authUI invokeResultCallbackWithUser:nil error:error];
            }];
            return;
          }

          [user linkWithCredential:newCredential completion:^(FIRUser *_Nullable user,
                                                              NSError *_Nullable error) {
            // Ignore any error (most likely caused by email mismatch) and treat the user as
            // successfully signed in.
            [self.navigationController dismissViewControllerAnimated:YES completion:^{
              [self.authUI invokeResultCallbackWithUser:user error:nil];
            }];
          }];
        }];
      }];
    }];
  }];
}

#pragma mark - Utilities

- (nullable id<FIRAuthProviderUI>)providerWithID:(NSString *)providerID {
  NSArray<id<FIRAuthProviderUI>> *signInProviders = self.authUI.signInProviders;
  for (id<FIRAuthProviderUI> provider in signInProviders) {
    if ([provider.providerID isEqual:providerID]) {
      return provider;
    }
  }
  return nil;
}

- (void)cancel {
  [self.navigationController dismissViewControllerAnimated:YES completion:^{
    NSError *error = [FIRAuthUIErrorUtils userCancelledSignInError];
    [self.authUI invokeResultCallbackWithUser:nil error:error];
  }];
}

@end
