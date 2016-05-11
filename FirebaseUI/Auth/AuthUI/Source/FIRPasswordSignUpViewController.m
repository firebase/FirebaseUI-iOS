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

#import "FIRPasswordSignUpViewController.h"

#import <FirebaseAuth/FirebaseAuth.h>
#import "FIRAuthUIStrings.h"
#import "FIRAuthUITableViewCell.h"
#import "FIRAuthUIUtils.h"
#import "FIRAuthUI_Internal.h"

/** @var kCellReuseIdentifier
    @brief The reuse identifier for table view cell.
 */
static NSString *const kCellReuseIdentifier = @"cellReuseIdentifier";

/** @var kEmailSignUpCellAccessibilityID
    @brief The Accessibility Identifier for the @c email cell.
 */
static NSString *const kEmailSignUpCellAccessibilityID = @"EmailSignUpCellAccessibilityID";

/** @var kPasswordSignUpCellAccessibilityID
    @brief The Accessibility Identifier for the @c password cell.
 */
static NSString *const kPasswordSignUpCellAccessibilityID = @"PasswordSignUpCellAccessibilityID";

/** @var kNameSignUpCellAccessibilityID
    @brief The Accessibility Identifier for the @c name cell.
 */
static NSString *const kNameSignUpCellAccessibilityID = @"NameSignUpCellAccessibilityID";

/** @var kNextButtonAccessibilityID
    @brief The Accessibility Identifier for the @c next button.
 */
static NSString *const kNextButtonAccessibilityID = @"NextButtonAccessibilityID";

/** @var kTextFieldRightViewSize
    @brief The height and width of the @c rightView of the password text field.
 */
static const CGFloat kTextFieldRightViewSize = 36.0f;

/** @var kFooterTextViewHorizontalInset
    @brief The horizontal inset for @c footerTextView, which should match the iOS standard margin.
 */
static const CGFloat kFooterTextViewHorizontalInset = 8.0f;

@interface FIRPasswordSignUpViewController () <UITableViewDataSource, UITextFieldDelegate>
@end

@implementation FIRPasswordSignUpViewController {
  /** @var _email
      @brief The @c The email address of the user from the previous screen.
   */
  NSString *_email;

  /** @var _emailField
      @brief The @c UITextField that user enters email address into.
   */
  UITextField *_emailField;

  /** @var _nameField
      @brief The @c UITextField that user enters name into.
   */
  UITextField *_nameField;

  /** @var _passwordField
      @brief The @c UITextField that user enters password into.
   */
  UITextField *_passwordField;
}

- (instancetype)initWithAuthUI:(FIRAuthUI *)authUI
                         email:(NSString *_Nullable)email {
  self = [super initWithNibName:NSStringFromClass([self class])
                         bundle:[FIRAuthUIUtils frameworkBundle]
                         authUI:authUI];
  if (self) {
    _email = [email copy];

    self.title = [FIRAuthUIStrings signUpTitle];
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  UIBarButtonItem *saveButtonItem =
      [[UIBarButtonItem alloc] initWithTitle:[FIRAuthUIStrings save]
                                       style:UIBarButtonItemStylePlain
                                      target:self
                                      action:@selector(save)];
  saveButtonItem.accessibilityIdentifier = kNextButtonAccessibilityID;
  self.navigationItem.rightBarButtonItem = saveButtonItem;
}

- (void)viewDidLayoutSubviews {
  [super viewDidLayoutSubviews];

  NSURL *termsOfServiceURL = self.authUI.termsOfServiceURL;
  if (!termsOfServiceURL) {
    self.footerTextView.text = nil;
    return;
  }

  NSString *termsOfService = [FIRAuthUIStrings termsOfService];
  NSString *termsOfServiceNotice =
      [NSString stringWithFormat:[FIRAuthUIStrings termsOfServiceNotice],
          [FIRAuthUIStrings next], termsOfService];
  NSMutableAttributedString *attributedString =
      [[NSMutableAttributedString alloc] initWithString:termsOfServiceNotice];
  NSRange termsOfServiceRange = [termsOfServiceNotice rangeOfString:termsOfService];
  [attributedString addAttribute:NSLinkAttributeName
                           value:self.authUI.termsOfServiceURL.absoluteString
                           range:termsOfServiceRange];
  self.footerTextView.attributedText = attributedString;

  // Adjust the footerTextView to have standard margins.
  self.footerTextView.textContainer.lineFragmentPadding = 0;
  _footerTextView.textContainerInset =
      UIEdgeInsetsMake(0, kFooterTextViewHorizontalInset, 0, kFooterTextViewHorizontalInset);
  [self.footerTextView sizeToFit];
}

#pragma mark - Actions

- (void)save {
  [self incrementActivity];

  [self.auth createUserWithEmail:_emailField.text
                        password:_passwordField.text
                      completion:^(FIRUser *_Nullable user, NSError *_Nullable error) {
    if (error) {
      [self decrementActivity];

      [self finishSignUpWithUser:nil error:error];
      return;
    }

    FIRUserProfileChangeRequest *request = [user profileChangeRequest];
    request.displayName = _nameField.text;
    [request commitChangesWithCompletion:^(NSError *_Nullable error) {
      [self decrementActivity];

      if (error) {
        [self finishSignUpWithUser:nil error:error];
        return;
      }
      [self finishSignUpWithUser:user error:nil];
    }];
  }];
}

- (void)finishSignUpWithUser:(FIRUser *)user error:(NSError *)error {
  if (error) {
    switch (error.code) {
      case FIRAuthErrorCodeEmailAlreadyInUse:
        [self showAlertWithTitle:[FIRAuthUIStrings error]
                         message:[FIRAuthUIStrings emailAlreadyInUseError]];
        return;
      case FIRAuthErrorCodeInvalidEmail:
        [self showAlertWithTitle:[FIRAuthUIStrings error]
                         message:[FIRAuthUIStrings invalidEmailError]];
        return;
      case FIRAuthErrorCodeWeakPassword:
        [self showAlertWithTitle:[FIRAuthUIStrings error]
                         message:[FIRAuthUIStrings weakPasswordError]];
        return;
    }
  }

  [self.navigationController dismissViewControllerAnimated:YES completion:^() {
    [self.authUI invokeResultCallbackWithUser:user error:error];
  }];
}

- (void)textFieldDidChange {
  [self updateActionButton];
}

- (void)updateActionButton {
  BOOL enableActionButton = _emailField.text.length > 0
                            && _nameField.text.length > 0
                            && _passwordField.text.length > 0;
  self.navigationItem.rightBarButtonItem.enabled = enableActionButton;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return 3;
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
    cell.accessibilityIdentifier = kEmailSignUpCellAccessibilityID;
    _emailField = cell.textField;
    _emailField.text = _email;
    _emailField.placeholder = [FIRAuthUIStrings enterYourEmail];
    _emailField.secureTextEntry = NO;
    _emailField.returnKeyType = UIReturnKeyNext;
    _emailField.keyboardType = UIKeyboardTypeEmailAddress;
  } else if (indexPath.row == 1) {
    cell.label.text = [FIRAuthUIStrings name];
    cell.accessibilityIdentifier = kNameSignUpCellAccessibilityID;
    _nameField = cell.textField;
    _nameField.placeholder = [FIRAuthUIStrings firstAndLastName];
    _nameField.secureTextEntry = NO;
    _nameField.returnKeyType = UIReturnKeyNext;
    _nameField.keyboardType = UIKeyboardTypeDefault;
  } else if (indexPath.row == 2) {
    cell.label.text = [FIRAuthUIStrings password];
    cell.accessibilityIdentifier = kPasswordSignUpCellAccessibilityID;
    _passwordField = cell.textField;
    _passwordField.placeholder = [FIRAuthUIStrings choosePassword];
    _passwordField.secureTextEntry = YES;
    _passwordField.rightView = [self visibilityToggleButtonForPasswordField];
    _passwordField.rightViewMode = UITextFieldViewModeAlways;
    _passwordField.returnKeyType = UIReturnKeyNext;
    _passwordField.keyboardType = UIKeyboardTypeDefault;
  }
  [cell.textField addTarget:self
                     action:@selector(textFieldDidChange)
           forControlEvents:UIControlEventEditingChanged];
  [self updateActionButton];
  return cell;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  if (textField == _emailField) {
    [_nameField becomeFirstResponder];
  } else if (textField == _nameField) {
    [_passwordField becomeFirstResponder];
  } else if (textField == _passwordField) {
    [self save];
  }
  return NO;
}

#pragma mark - Password field visibility toggle button

- (UIButton *)visibilityToggleButtonForPasswordField {
  UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
  button.frame = CGRectMake(0, 0, kTextFieldRightViewSize, kTextFieldRightViewSize);
  button.tintColor = [UIColor lightGrayColor];
  [self updateIconForRightViewButton:button];
  [button addTarget:self
                action:@selector(togglePasswordFieldVisibility:)
      forControlEvents:UIControlEventTouchUpInside];
  return button;
}

- (void)updateIconForRightViewButton:(UIButton *)button {
  NSString *imageName = _passwordField.secureTextEntry ? @"ic_visibility" : @"ic_visibility_off";
  [button setImage:[FIRAuthUIUtils imageNamed:imageName] forState:UIControlStateNormal];
}

- (void)togglePasswordFieldVisibility:(UIButton *)button {
  // Make sure cursor is placed correctly by disabling and enabling the text field.
  _passwordField.enabled = NO;
  _passwordField.secureTextEntry = !_passwordField.secureTextEntry;
  [self updateIconForRightViewButton:button];
  _passwordField.enabled = YES;
  [_passwordField becomeFirstResponder];
}

@end
