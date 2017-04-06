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

#import "FUIPhoneEntryViewController.h"

#import "FUIAuthTableViewCell.h"
#import "FUIAuthUtils.h"
#import "FUIPhoneAuthStrings.h"
#import "FUIPhoneAuth_Internal.h"
#import "FUIPhoneVerificationViewController.h"
#import <FirebaseAuth/FIRPhoneAuthProvider.h>
#import <FirebaseAuth/FirebaseAuth.h>

/** @var kCellReuseIdentifier
    @brief The reuse identifier for table view cell.
 */
static NSString *const kCellReuseIdentifier = @"cellReuseIdentifier";

/** @var kPhoneNumberCellAccessibilityID
    @brief The Accessibility Identifier for the phone number cell.
 */
static NSString *const kPhoneNumberCellAccessibilityID = @"PhoneNumberCellAccessibilityID";

/** @var kNextButtonAccessibilityID
    @brief The Accessibility Identifier for the @c next button.
 */
static NSString *const kNextButtonAccessibilityID = @"NextButtonAccessibilityID";

@interface FUIPhoneEntryViewController () <UITextFieldDelegate>
@end

@implementation FUIPhoneEntryViewController  {
  /** @var _phoneNumberField
      @brief The @c UITextField that user enters phone number.
   */
  UITextField *_phoneNumberField;
}

- (instancetype)initWithAuthUI:(FUIAuth *)authUI {
  return [self initWithNibName:NSStringFromClass([self class])
                        bundle:[FUIAuthUtils frameworkBundle]
                        authUI:authUI];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil
                         bundle:(NSBundle *)nibBundleOrNil
                         authUI:(FUIAuth *)authUI {

  self = [super initWithNibName:nibNameOrNil
                         bundle:nibBundleOrNil
                         authUI:authUI];
  if (self) {
    self.title = FUILocalizedString(kStr_EnterPhoneTitle);
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  UIBarButtonItem *nextButtonItem =
  [[UIBarButtonItem alloc] initWithTitle:FUILocalizedString(kStr_Next)
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
  [self onNext:_phoneNumberField.text];
}

- (void)onNext:(NSString *)phoneNumber {
  if (!phoneNumber.length) {
    [self showAlertWithMessage:FUILocalizedString(kStr_InvalidEmailError)];
    return;
  }

  [self incrementActivity];

  UIViewController *controller =
      [[FUIPhoneVerificationViewController alloc] initWithAuthUI:self.authUI];

  [self pushViewController:controller];
  NSLog(@"%s", __func__);

  [self decrementActivity];

}

- (void)onBack {
  [super onBack];
}

- (void)textFieldDidChange {
  [self didChangePhoneNumber:_phoneNumberField.text];
}

- (void)didChangePhoneNumber:(NSString *)phoneNumber {
  self.navigationItem.rightBarButtonItem.enabled = (phoneNumber.length > 0);
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
                                    bundle:[FUIAuthUtils frameworkBundle]];
    [tableView registerNib:cellNib forCellReuseIdentifier:kCellReuseIdentifier];
    cell = [tableView dequeueReusableCellWithIdentifier:kCellReuseIdentifier];
  }
  cell.label.text = FUILocalizedString(kStr_Email);
  cell.textField.placeholder = FUILocalizedString(kStr_EnterYourEmail);
  cell.textField.delegate = self;
  cell.accessibilityIdentifier = kPhoneNumberCellAccessibilityID;
  _phoneNumberField = cell.textField;
  _phoneNumberField.secureTextEntry = NO;
  _phoneNumberField.autocorrectionType = UITextAutocorrectionTypeNo;
  _phoneNumberField.autocapitalizationType = UITextAutocapitalizationTypeNone;
  _phoneNumberField.returnKeyType = UIReturnKeyNext;
  _phoneNumberField.keyboardType = UIKeyboardTypeEmailAddress;
  [cell.textField addTarget:self
                     action:@selector(textFieldDidChange)
           forControlEvents:UIControlEventEditingChanged];
  [self didChangePhoneNumber:_phoneNumberField.text];
  return cell;
}

- (nullable id<FUIAuthProvider>)bestProviderFromProviderIDs:(NSArray<NSString *> *)providerIDs {
  NSArray<id<FUIAuthProvider>> *providers = self.authUI.providers;
  for (NSString *providerID in providerIDs) {
    for (id<FUIAuthProvider> provider in providers) {
      if ([providerID isEqual:provider.providerID]) {
        return provider;
      }
    }
  }
  return nil;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  if (textField == _phoneNumberField) {
    [self onNext:_phoneNumberField.text];
  }
  return NO;
}

#pragma mark - Private

- (void)cancelAuthorization {
  [self.navigationController dismissViewControllerAnimated:YES completion:^{
    NSError *error = [FUIAuthErrorUtils userCancelledSignInError];
    FUIPhoneAuth *delegate = [self phoneAuthProvider];
    [delegate callbackWithCredential:nil error:error];
  }];
}

- (FUIPhoneAuth *)phoneAuthProvider {
  for (id<FUIAuthProvider> provider in self.authUI.providers) {
    if ([provider.providerID isEqualToString:FIRPhoneAuthProviderID]
        && [provider isKindOfClass:[FUIPhoneAuth class]]) {
      return provider;
    }
  }

  return nil;
}

@end
