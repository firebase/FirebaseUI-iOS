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

#import "FIRPasswordSignInViewController.h"

#import <FirebaseAuth/FirebaseAuth.h>
#import "FIRAuthUIStrings.h"
#import "FIRAuthUITableViewCell.h"
#import "FIRAuthUIUtils.h"
#import "FIRAuthUI_Internal.h"
#import "FIRPasswordRecoveryViewController.h"

/** @var kCellReuseIdentifier
    @brief The reuse identifier for table view cell.
 */
static NSString *const kCellReuseIdentifier = @"cellReuseIdentifier";

@interface FIRPasswordSignInViewController () <UITableViewDataSource, UITextFieldDelegate>
@end

@implementation FIRPasswordSignInViewController {
  /** @var _email
      @brief The @c The email address of the user from the previous screen.
   */
  NSString *_email;

  /** @var _emailField
      @brief The @c UITextField that user enters email address into.
   */
  UITextField *_emailField;

  /** @var _passwordField
      @brief The @c UITextField that user enters password into.
   */
  UITextField *_passwordField;
}

- (instancetype)initWithAuthUI:(FIRAuthUI *)authUI
                         email:(NSString *_Nullable)email {
  self = [super initWithAuthUI:authUI];
  if (self) {
    _email = [email copy];

    self.title = [FIRAuthUIStrings signInTitle];
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
  self.navigationItem.rightBarButtonItem = nextButtonItem;
}

#pragma mark - Actions

- (void)next {
  if (![[self class] isValidEmail:_emailField.text]) {
    [self showAlertWithTitle:[FIRAuthUIStrings error] message:[FIRAuthUIStrings invalidEmailError]];
    return;
  }

  [self.auth signInWithEmail:_emailField.text
                    password:_passwordField.text
                  completion:^(FIRUser *_Nullable user, NSError *_Nullable error) {
    if (error) {
      switch (error.code) {
        case FIRAuthErrorCodeWrongPassword:
          [self showAlertWithTitle:[FIRAuthUIStrings error]
                           message:[FIRAuthUIStrings wrongPasswordError]];
          return;
        case FIRAuthErrorCodeUserNotFound:
          [self showAlertWithTitle:[FIRAuthUIStrings error]
                           message:[FIRAuthUIStrings accountDoesNotExistError]];
          return;
        case FIRAuthErrorCodeUserDisabled:
          [self showAlertWithTitle:[FIRAuthUIStrings error]
                           message:[FIRAuthUIStrings accountDisabledError]];
          return;
      }
    }

    [self.navigationController dismissViewControllerAnimated:YES completion:^{
      [self.authUI invokeResultCallbackWithUser:user error:error];
    }];
  }];
}

- (IBAction)forgotPassword {
  UIViewController *viewControlelr =
      [[FIRPasswordRecoveryViewController alloc] initWithAuthUI:self.authUI
                                                          email:_emailField.text];
  [self.navigationController pushViewController:viewControlelr animated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return 2;
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
  cell.textField.delegate = self;
  if (indexPath.row == 0) {
    cell.label.text = [FIRAuthUIStrings email];
    _emailField = cell.textField;
    _emailField.text = _email;
    _emailField.placeholder = [FIRAuthUIStrings enterYourEmail];
    _emailField.secureTextEntry = NO;
    _emailField.returnKeyType = UIReturnKeyNext;
    _emailField.keyboardType = UIKeyboardTypeEmailAddress;
  } else if (indexPath.row == 1) {
    cell.label.text = [FIRAuthUIStrings password];
    _passwordField = cell.textField;
    _passwordField.placeholder = [FIRAuthUIStrings enterYourPassword];
    _passwordField.secureTextEntry = YES;
    _passwordField.returnKeyType = UIReturnKeyNext;
    _passwordField.keyboardType = UIKeyboardTypeDefault;
  }
  return cell;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  if (textField == _emailField) {
    [_passwordField becomeFirstResponder];
  } else if (textField == _passwordField) {
    [self next];
  }
  return NO;
}

@end
