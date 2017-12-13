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

#import "FUIPasswordRecoveryViewController.h"

#import <FirebaseAuth/FirebaseAuth.h>
#import "FUIAuthBaseViewController_Internal.h"
#import "FUIAuthStrings.h"
#import "FUIAuthTableViewCell.h"
#import "FUIAuthUtils.h"
#import "FUIAuth_Internal.h"

/** @var kCellReuseIdentifier
    @brief The reuse identifier for table view cell.
 */
static NSString *const kCellReuseIdentifier = @"cellReuseIdentifier";

/** @var kFooterTextViewHorizontalInset
    @brief The horizontal inset for @c footerTextView, which should match the iOS standard margin.
 */
static const CGFloat kFooterTextViewHorizontalInset = 8.0f;

@interface FUIPasswordRecoveryViewController () <UITableViewDataSource, UITextFieldDelegate>
/** @property footerTextView
    @brief The text view in the footer of the table.
 */
@property(nonatomic, strong) IBOutlet UITextView *footerTextView;

@end

@implementation FUIPasswordRecoveryViewController {
  /** @var _email
      @brief The @c email address of the user from the previous screen.
   */
  NSString *_email;

  /** @var _emailField
      @brief The @c UITextField that user enters email address into.
   */
  UITextField *_emailField;
  
  /** @var _tableView
      @brief The @c UITableView used to store all UI elements.
   */
  __weak IBOutlet UITableView *_tableView;
}

- (instancetype)initWithAuthUI:(FUIAuth *)authUI
                         email:(NSString *_Nullable)email {
  return [self initWithNibName:NSStringFromClass([self class])
                        bundle:[FUIAuthUtils bundleNamed:FUIAuthBundleName]
                        authUI:authUI
                         email:email];
}

- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil
                         bundle:(nullable NSBundle *)nibBundleOrNil
                         authUI:(FUIAuth *)authUI
                          email:(NSString *_Nullable)email {
  self = [super initWithNibName:nibNameOrNil
                         bundle:nibBundleOrNil
                         authUI:authUI];
  if (self) {
    _email = [email copy];

    self.title = FUILocalizedString(kStr_PasswordRecoveryTitle);
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  UIBarButtonItem *sendButtonItem =
      [FUIAuthBaseViewController barItemWithTitle:FUILocalizedString(kStr_Send)
                                           target:self
                                           action:@selector(send)];
  self.navigationItem.rightBarButtonItem = sendButtonItem;

  [self enableDynamicCellHeightForTableView:_tableView];
}

- (void)viewDidLayoutSubviews {
  [super viewDidLayoutSubviews];

  self.footerTextView.text = FUILocalizedString(kStr_PasswordRecoveryMessage);

  // Adjust the footerTextView to have standard margins.
  self.footerTextView.textContainer.lineFragmentPadding = 0;
  _footerTextView.textContainerInset =
      UIEdgeInsetsMake(0, kFooterTextViewHorizontalInset, 0, kFooterTextViewHorizontalInset);
  [self.footerTextView sizeToFit];
}

#pragma mark - Actions

- (void)send {
  [self recoverEmail:_emailField.text];
}

- (void)recoverEmail:(NSString *)email {
  if (![[self class] isValidEmail:email]) {
    [self showAlertWithMessage:FUILocalizedString(kStr_InvalidEmailError)];
    return;
  }

  [self incrementActivity];

  [self.auth sendPasswordResetWithEmail:email
                             completion:^(NSError *_Nullable error) {
    [self decrementActivity];

    if (error) {
      if (error.code == FIRAuthErrorCodeUserNotFound) {
        [self showAlertWithMessage:FUILocalizedString(kStr_UserNotFoundError)];
        return;
      }

      [self.navigationController dismissViewControllerAnimated:YES completion:^{
        [self.authUI invokeResultCallbackWithAuthDataResult:nil error:error];
      }];
      return;
    }

    NSString *message = [NSString stringWithFormat:
                            FUILocalizedString(kStr_PasswordRecoveryEmailSentMessage), email];
    [self showAlertWithMessage:message];
  }];
}

- (void)textFieldDidChange {
  [self didChangeEmail:_emailField.text];
}

- (void)didChangeEmail:(NSString *)email {
  self.navigationItem.rightBarButtonItem.enabled = (email.length > 0);

}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  FUIAuthTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellReuseIdentifier];
  if (!cell) {
    UINib *cellNib = [UINib nibWithNibName:NSStringFromClass([FUIAuthTableViewCell class])
                                    bundle:[FUIAuthUtils bundleNamed:FUIAuthBundleName]];
    [tableView registerNib:cellNib forCellReuseIdentifier:kCellReuseIdentifier];
    cell = [tableView dequeueReusableCellWithIdentifier:kCellReuseIdentifier];
  }
  cell.label.text = FUILocalizedString(kStr_Email);
  _emailField = cell.textField;
  _emailField.delegate = self;
  _emailField.text = _email;
  _emailField.placeholder = FUILocalizedString(kStr_EnterYourEmail);
  _emailField.secureTextEntry = NO;
  _emailField.returnKeyType = UIReturnKeyNext;
  _emailField.keyboardType = UIKeyboardTypeEmailAddress;
  _emailField.autocorrectionType = UITextAutocorrectionTypeNo;
  _emailField.autocapitalizationType = UITextAutocapitalizationTypeNone;
  [cell.textField addTarget:self
                     action:@selector(textFieldDidChange)
           forControlEvents:UIControlEventEditingChanged];
  [self didChangeEmail:_emailField.text];
  return cell;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  if (textField == _emailField) {
    [self send];
  }
  return NO;
}

@end
