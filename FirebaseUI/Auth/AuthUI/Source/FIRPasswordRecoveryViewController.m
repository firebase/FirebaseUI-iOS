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

#import "FIRPasswordRecoveryViewController.h"

#import <FirebaseAuth/FirebaseAuth.h>
#import "FIRAuthUIStrings.h"
#import "FIRAuthUITableViewCell.h"
#import "FIRAuthUIUtils.h"

/** @var kCellReuseIdentifier
    @brief The reuse identifier for table view cell.
 */
static NSString *const kCellReuseIdentifier = @"cellReuseIdentifier";

@interface FIRPasswordRecoveryViewController () <UITableViewDataSource, UITextFieldDelegate>
@end

@implementation FIRPasswordRecoveryViewController {
  /** @var _email
      @brief The @c The email address of the user from the previous screen.
   */
  NSString *_email;

  /** @var _emailField
      @brief The @c UITextField that user enters email address into.
   */
  UITextField *_emailField;
}

- (instancetype)initWithAuthUI:(FIRAuthUI *)authUI
                         email:(NSString *_Nullable)email {
  self = [super initWithAuthUI:authUI];
  if (self) {
    _email = [email copy];

    self.title = [FIRAuthUIStrings passwordRecoveryTitle];
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

  [self.auth sendPasswordResetWithEmail:_emailField.text
                             completion:^(NSError *_Nullable error) {
    if (error) {
      [self showAlertWithTitle:[FIRAuthUIStrings error]
                       message:[FIRAuthUIStrings passwordRecoveryError]];
      return;
    }

    [self showAlertWithTitle:[FIRAuthUIStrings info]
                     message:[FIRAuthUIStrings passwordRecoveryEmailSentMessage]];
  }];
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
  _emailField = cell.textField;
  _emailField.delegate = self;
  _emailField.text = _email;
  _emailField.placeholder = [FIRAuthUIStrings enterYourEmail];
  _emailField.returnKeyType = UIReturnKeyNext;
  _emailField.keyboardType = UIKeyboardTypeEmailAddress;
  return cell;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  if (textField == _emailField) {
    [self next];
  }
  return NO;
}

@end
