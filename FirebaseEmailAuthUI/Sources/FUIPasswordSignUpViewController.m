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

#import "FirebaseEmailAuthUI/Sources/Public/FirebaseEmailAuthUI/FUIPasswordSignUpViewController.h"

#import <FirebaseAuth/FirebaseAuth.h>
#import <FirebaseAuthUI/FirebaseAuthUI.h>

#import "FirebaseEmailAuthUI/Sources/Public/FirebaseEmailAuthUI/FUIEmailAuth.h"
#import "FirebaseEmailAuthUI/Sources/FUIEmailAuthStrings.h"

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

/** @var kSaveButtonAccessibilityID
    @brief The Accessibility Identifier for the @c next button.
 */
static NSString *const kSaveButtonAccessibilityID = @"SaveButtonAccessibilityID";

/** @var kTextFieldRightViewSize
    @brief The height and width of the @c rightView of the password text field.
 */
static const CGFloat kTextFieldRightViewSize = 36.0f;

@interface FUIPasswordSignUpViewController () <UITableViewDataSource, UITextFieldDelegate>
@end

@implementation FUIPasswordSignUpViewController {
  /** @var _email
      @brief The @c email address of the user from the previous screen.
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

  /** @var requireDisplayName
    @brief Indicate weather display name field is required.
   */
  BOOL _requireDisplayName;

  /** @var _passwordField
      @brief The @c UITextField that user enters password into.
   */
  UITextField *_passwordField;
  
  /** @var _tableView
      @brief The @c UITableView used to store all UI elements.
   */
  __weak IBOutlet UITableView *_tableView;
}

- (instancetype)initWithAuthUI:(FUIAuth *)authUI
                         email:(NSString *_Nullable)email
            requireDisplayName:(BOOL)requireDisplayName {
  return [self initWithNibName:NSStringFromClass([self class])
                        bundle:[FUIEmailAuth bundle]
                        authUI:authUI
                         email:email
            requireDisplayName:requireDisplayName];
}

- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil
                         bundle:(nullable NSBundle *)nibBundleOrNil
                         authUI:(FUIAuth *)authUI
                          email:(NSString *_Nullable)email
             requireDisplayName:(BOOL)requireDisplayName {
  self = [super initWithNibName:nibNameOrNil
                         bundle:nibBundleOrNil
                         authUI:authUI];
  if (self) {
    _email = [email copy];
    _requireDisplayName = requireDisplayName;
    self.title = FUILocalizedString(kStr_SignUpTitle);
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  UIBarButtonItem *saveButtonItem =
      [FUIAuthBaseViewController barItemWithTitle:FUILocalizedString(kStr_Save)
                                           target:self
                                           action:@selector(save)];
  saveButtonItem.accessibilityIdentifier = kSaveButtonAccessibilityID;
  self.navigationItem.rightBarButtonItem = saveButtonItem;

  [self enableDynamicCellHeightForTableView:_tableView];
  
  if (@available(iOS 13.0, *)) {
    _tableView.backgroundColor = [UIColor systemBackgroundColor];
  }
}

- (void)viewDidLayoutSubviews {
  [super viewDidLayoutSubviews];

  self.footerView.authUI = self.authUI;
  [self.footerView useFooterMessage];
}

#pragma mark - Actions

- (void)save {
  [self signUpWithEmail:_emailField.text
            andPassword:_passwordField.text
            andUsername:_nameField.text];
}

- (void)signUpWithEmail:(NSString *)email
            andPassword:(NSString *)password
            andUsername:(NSString *)username {
  if (![[self class] isValidEmail:email]) {
    [self showAlertWithMessage:FUILocalizedString(kStr_InvalidEmailError)];
    return;
  }
  if (password.length <= 0) {
    [self showAlertWithMessage:FUILocalizedString(kStr_InvalidPasswordError)];
    return;
  }

  [self incrementActivity];

  // Check for the presence of an anonymous user and whether automatic upgrade is enabled.
  if (self.auth.currentUser.isAnonymous && self.authUI.shouldAutoUpgradeAnonymousUsers) {
    FIRAuthCredential *credential =
        [FIREmailAuthProvider credentialWithEmail:email password:password];
    [self.auth.currentUser
      linkWithCredential:credential
              completion:^(FIRAuthDataResult *_Nullable authResult,
                           NSError * _Nullable error) {
      if (error) {
        [self decrementActivity];
        [self finishSignUpWithAuthDataResult:nil error:error];
        return;
      }
      FIRUserProfileChangeRequest *request = [authResult.user profileChangeRequest];
      request.displayName = username;
      [request commitChangesWithCompletion:^(NSError *_Nullable error) {
        [self decrementActivity];

        if (error) {
          [self finishSignUpWithAuthDataResult:nil error:error];
          return;
        }
        [self finishSignUpWithAuthDataResult:authResult error:nil];
      }];
    }];
  } else {
    [self.auth createUserWithEmail:email
                          password:password
                        completion:^(FIRAuthDataResult *_Nullable authDataResult,
                                     NSError *_Nullable error) {
      if (error) {
        [self decrementActivity];

        [self finishSignUpWithAuthDataResult:nil error:error];
        return;
      }

      FIRUserProfileChangeRequest *request = [authDataResult.user profileChangeRequest];
      request.displayName = username;
      [request commitChangesWithCompletion:^(NSError *_Nullable error) {
        [self decrementActivity];

        if (error) {
          [self finishSignUpWithAuthDataResult:nil error:error];
          return;
        }
        [self finishSignUpWithAuthDataResult:authDataResult error:nil];
      }];
    }];
  }
}

- (void)finishSignUpWithAuthDataResult:(nullable FIRAuthDataResult *)authDataResult
                                 error:(nullable NSError *)error {
  if (error) {
    switch (error.code) {
      case FIRAuthErrorCodeEmailAlreadyInUse:
        [self showAlertWithMessage:FUILocalizedString(kStr_EmailAlreadyInUseError)];
        return;
      case FIRAuthErrorCodeInvalidEmail:
        [self showAlertWithMessage:FUILocalizedString(kStr_InvalidEmailError)];
        return;
      case FIRAuthErrorCodeWeakPassword:
        [self showAlertWithMessage:FUILocalizedString(kStr_WeakPasswordError)];
        return;
      case FIRAuthErrorCodeTooManyRequests:
        [self showAlertWithMessage:FUILocalizedString(kStr_SignUpTooManyTimesError)];
        return;
    }
  }

  [self dismissNavigationControllerAnimated:YES completion:^() {
    [self.authUI invokeResultCallbackWithAuthDataResult:authDataResult URL:nil error:error];
  }];
}

- (void)textFieldDidChange {
  [self didChangeEmail:_emailField.text orPassword:_passwordField.text orUserName:_nameField.text];
}

- (void)didChangeEmail:(NSString *)email
            orPassword:(NSString *)password
            orUserName:(NSString *)username {
  BOOL enableActionButton = email.length > 0 && password.length > 0;
  if (_requireDisplayName) {
    enableActionButton = enableActionButton && username.length > 0;
  }
  self.navigationItem.rightBarButtonItem.enabled = enableActionButton;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if (_requireDisplayName) {
    return 3;
  } else {
    return 2;
  }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  FUIAuthTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellReuseIdentifier];
  if (!cell) {
    UINib *cellNib = [UINib nibWithNibName:NSStringFromClass([FUIAuthTableViewCell class])
                                    bundle:[FUIAuthUtils authUIBundle]];
    [tableView registerNib:cellNib forCellReuseIdentifier:kCellReuseIdentifier];
    cell = [tableView dequeueReusableCellWithIdentifier:kCellReuseIdentifier];
  }
  cell.textField.delegate = self;
  if (indexPath.row == 0) {
    cell.label.text = FUILocalizedString(kStr_Email);
    cell.accessibilityIdentifier = kEmailSignUpCellAccessibilityID;
    cell.textField.enabled = NO;
    _emailField = cell.textField;
    _emailField.text = _email;
    _emailField.placeholder = FUILocalizedString(kStr_EnterYourEmail);
    _emailField.secureTextEntry = NO;
    _emailField.returnKeyType = UIReturnKeyNext;
    _emailField.keyboardType = UIKeyboardTypeEmailAddress;
    _emailField.autocorrectionType = UITextAutocorrectionTypeNo;
    _emailField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    if (@available(iOS 11.0, *)) {
      _emailField.textContentType = UITextContentTypeUsername;
    }
  } else if (indexPath.row == 1) {
      if (_requireDisplayName) {
          cell.label.text = FUILocalizedString(kStr_Name);
          cell.accessibilityIdentifier = kNameSignUpCellAccessibilityID;
          _nameField = cell.textField;
          _nameField.placeholder = FUILocalizedString(kStr_FirstAndLastName);
          _nameField.secureTextEntry = NO;
          _nameField.returnKeyType = UIReturnKeyNext;
          _nameField.keyboardType = UIKeyboardTypeDefault;
          _nameField.autocapitalizationType = UITextAutocapitalizationTypeWords;
          if (@available(iOS 10.0, *)) {
              _nameField.textContentType = UITextContentTypeName;
          }
      } else {
          cell.label.text = FUILocalizedString(kStr_Password);
          cell.accessibilityIdentifier = kPasswordSignUpCellAccessibilityID;
          _passwordField = cell.textField;
          _passwordField.placeholder = FUILocalizedString(kStr_ChoosePassword);
          _passwordField.secureTextEntry = YES;
          _passwordField.rightView = [self visibilityToggleButtonForPasswordField];
          _passwordField.rightViewMode = UITextFieldViewModeAlways;
          _passwordField.returnKeyType = UIReturnKeyNext;
          _passwordField.keyboardType = UIKeyboardTypeDefault;
          if (@available(iOS 11.0, *)) {
              _passwordField.textContentType = UITextContentTypePassword;
          }
      }
  } else if (indexPath.row == 2) {
    cell.label.text = FUILocalizedString(kStr_Password);
    cell.accessibilityIdentifier = kPasswordSignUpCellAccessibilityID;
    _passwordField = cell.textField;
    _passwordField.placeholder = FUILocalizedString(kStr_ChoosePassword);
    _passwordField.secureTextEntry = YES;
    _passwordField.rightView = [self visibilityToggleButtonForPasswordField];
    _passwordField.rightViewMode = UITextFieldViewModeAlways;
    _passwordField.returnKeyType = UIReturnKeyNext;
    _passwordField.keyboardType = UIKeyboardTypeDefault;
    if (@available(iOS 11.0, *)) {
      _passwordField.textContentType = UITextContentTypePassword;
    }
  }
  [cell.textField addTarget:self
                     action:@selector(textFieldDidChange)
           forControlEvents:UIControlEventEditingChanged];
  [self didChangeEmail:_emailField.text orPassword:_passwordField.text orUserName:_nameField.text];
  return cell;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  if (textField == _emailField) {
    [_nameField becomeFirstResponder];
  } else if (textField == _nameField) {
    [_passwordField becomeFirstResponder];
  } else if (textField == _passwordField) {
    [self signUpWithEmail:_emailField.text
              andPassword:_passwordField.text
              andUsername:_nameField.text];
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
  UIImage *image = [FUIAuthUtils imageNamed:imageName fromBundle:[FUIAuthUtils authUIBundle]];
  [button setImage:image forState:UIControlStateNormal];
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
