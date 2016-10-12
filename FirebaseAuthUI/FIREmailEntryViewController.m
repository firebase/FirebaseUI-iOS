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

#import "FIREmailEntryViewController.h"

#import <FirebaseAuth/FirebaseAuth.h>
#import "FIRAuthProviderUI.h"
#import "FIRAuthUIStrings.h"
#import "FIRAuthUITableViewCell.h"
#import "FIRAuthUIUtils.h"
#import "FIRAuthUI_Internal.h"
#import "FIRPasswordSignInViewController.h"
#import "FIRPasswordSignUpViewController.h"

/** @var kCellReuseIdentifier
    @brief The reuse identifier for table view cell.
 */
static NSString *const kCellReuseIdentifier = @"cellReuseIdentifier";

/** @var kAppIDCodingKey
    @brief The key used to encode the app ID for NSCoding.
 */
static NSString *const kAppIDCodingKey = @"appID";

/** @var kAuthUICodingKey
    @brief The key used to encode @c FIRAuthUI instance for NSCoding.
 */
static NSString *const kAuthUICodingKey = @"authUI";

/** @var kEmailCellAccessibilityID
    @brief The Accessibility Identifier for the @c email sign in cell.
 */
static NSString *const kEmailCellAccessibilityID = @"EmailCellAccessibilityID";

/** @var kNextButtonAccessibilityID
    @brief The Accessibility Identifier for the @c next button.
 */
static NSString *const kNextButtonAccessibilityID = @"NextButtonAccessibilityID";

@interface FIREmailEntryViewController () <UITableViewDataSource, UITextFieldDelegate>
@end

@implementation FIREmailEntryViewController {
  /** @var _emailField
      @brief The @c UITextField that user enters email address into.
   */
  UITextField *_emailField;
}

- (instancetype)initWithAuthUI:(FIRAuthUI *)authUI {
  self = [super initWithAuthUI:authUI];
  if (self) {
    self.title = [FIRAuthUIStrings signInWithEmail];
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  UIBarButtonItem *nextButtonItem =
      [[UIBarButtonItem alloc] initWithTitle:[FIRAuthUIStrings next]
                                       style:UIBarButtonItemStylePlain
                                      target:self
                                      action:@selector(next)];
  nextButtonItem.accessibilityIdentifier = kNextButtonAccessibilityID;
  self.navigationItem.rightBarButtonItem = nextButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  if (self.navigationController.viewControllers.firstObject == self) {
    UIBarButtonItem *cancelBarButton =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                  target:self
                                                  action:@selector(cancelAuthorization)];
    self.navigationItem.leftBarButtonItem = cancelBarButton;
  }
}

#pragma mark - Actions

- (void)next {
  [self onNext:_emailField.text];
}

- (void)onNext:(NSString *)emailText {
  if (![[self class] isValidEmail:emailText]) {
    [self showAlertWithMessage:[FIRAuthUIStrings invalidEmailError]];
    return;
  }

  [self incrementActivity];

  [self.auth fetchProvidersForEmail:emailText
                         completion:^(NSArray<NSString *> *_Nullable providers,
                                      NSError *_Nullable error) {
    [self decrementActivity];

    if (error) {
      if (error.code == FIRAuthErrorCodeInvalidEmail) {
        [self showAlertWithMessage:[FIRAuthUIStrings invalidEmailError]];
      } else {
        [self.navigationController dismissViewControllerAnimated:YES completion:^{
          [self.authUI invokeResultCallbackWithUser:nil error:error];
        }];
      }
      return;
    }

    id<FIRAuthProviderUI> provider = [self bestProviderFromProviderIDs:providers];
    if (provider) {
      NSString *email = emailText;
      [self showSignInAlertWithEmail:email
                            provider:provider
                             handler:^{
        [self signInWithProvider:provider email:email];
      }];
    } else if ([providers containsObject:FIREmailPasswordAuthProviderID]) {
      UIViewController *controller =
          [[FIRPasswordSignInViewController alloc] initWithAuthUI:self.authUI
                                                            email:emailText];
      [self pushViewController:controller];
    } else {
      if (providers.count) {
        // There's some unsupported providers, surface the error to the user.
        [self showAlertWithMessage:[FIRAuthUIStrings cannotAuthenticateError]];
      } else {
        // New user.
        UIViewController *controller =
            [[FIRPasswordSignUpViewController alloc] initWithAuthUI:self.authUI
                                                              email:emailText];
        [self pushViewController:controller];
      }
    }
  }];
}

- (void)textFieldDidChange {
  [self onEmailValueChanged:_emailField.text];
}

- (void)onEmailValueChanged:(NSString *)emailText {
  self.navigationItem.rightBarButtonItem.enabled = (emailText.length > 0);
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  FIRAuthUITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellReuseIdentifier];
  if (!cell) {
    UINib *cellNib = [UINib nibWithNibName:NSStringFromClass([FIRAuthUITableViewCell class])
                                    bundle:[FIRAuthUIUtils frameworkBundle]];
    [tableView registerNib:cellNib forCellReuseIdentifier:kCellReuseIdentifier];
    cell = [tableView dequeueReusableCellWithIdentifier:kCellReuseIdentifier];
  }
  cell.label.text = [FIRAuthUIStrings email];
  cell.textField.placeholder = [FIRAuthUIStrings enterYourEmail];
  cell.textField.delegate = self;
  cell.accessibilityIdentifier = kEmailCellAccessibilityID;
  _emailField = cell.textField;
  _emailField.autocorrectionType = UITextAutocorrectionTypeNo;
  _emailField.autocapitalizationType = UITextAutocapitalizationTypeNone;
  _emailField.returnKeyType = UIReturnKeyNext;
  _emailField.keyboardType = UIKeyboardTypeEmailAddress;
  [cell.textField addTarget:self
                     action:@selector(textFieldDidChange)
           forControlEvents:UIControlEventEditingChanged];
  [self onEmailValueChanged:_emailField.text];
  return cell;
}

- (nullable id<FIRAuthProviderUI>)bestProviderFromProviderIDs:(NSArray<NSString *> *)providerIDs {
  NSArray<id<FIRAuthProviderUI>> *providers = self.authUI.providers;
  for (NSString *providerID in providerIDs) {
    for (id<FIRAuthProviderUI> provider in providers) {
      if ([providerID isEqual:provider.providerID]) {
        return provider;
      }
    }
  }
  return nil;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  if (textField == _emailField) {
    [self onNext:_emailField.text];
  }
  return NO;
}

#pragma mark - Utilities

/** @fn signInWithProvider:email:
    @brief Actually kicks off sign in with the provider.
    @param provider The identity provider to sign in with.
    @param email The email address of the user.
 */
- (void)signInWithProvider:(id<FIRAuthProviderUI>)provider email:(NSString *)email {
  [self incrementActivity];

  // Sign out first to make sure sign in starts with a clean state.
  [provider signOut];
  [provider signInWithEmail:email
   presentingViewController:self
                 completion:^(FIRAuthCredential *_Nullable credential,
                              NSError *_Nullable error) {
                   if (error) {
                     [self decrementActivity];

                     [self.navigationController dismissViewControllerAnimated:YES completion:^{
                       [self.authUI invokeResultCallbackWithUser:nil error:error];
                     }];
                     return;
                   }

                   [self.auth signInWithCredential:credential
                                        completion:^(FIRUser *_Nullable user, NSError *_Nullable error) {
                                          [self decrementActivity];
                                          
                                          [self.navigationController dismissViewControllerAnimated:YES completion:^{
                                            [self.authUI invokeResultCallbackWithUser:user error:error];
                                          }];
                                        }];
                 }];
}
@end
