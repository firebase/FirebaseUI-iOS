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

#import <FirebaseAuth/FIRPhoneAuthProvider.h>
#import <FirebaseAuth/FirebaseAuth.h>
#import "FUIAuthTableViewCell.h"
#import "FUIAuthUtils.h"
#import "FUIAuth_Internal.h"
#import "FUICountryTableViewController.h"
#import "FUIFeatureSwitch.h"
#import "FUIPhoneAuthStrings.h"
#import "FUIPhoneAuth_Internal.h"
#import "FUIPhoneVerificationViewController.h"

NS_ASSUME_NONNULL_BEGIN

NS_ENUM(NSInteger, FUIPhoneEntryRow) {
  FUIPhoneEntryRowCountrySelector = 0,
  FUIPhoneEntryRowPhoneNumber
};

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

@interface FUIPhoneEntryViewController ()
    <UITextFieldDelegate, UITabBarDelegate, UITableViewDataSource, FUICountryTableViewDelegate>
@end

@implementation FUIPhoneEntryViewController  {
  /** @var _phoneNumberField
      @brief The @c UITextField that user enters phone number.
   */
  UITextField *_phoneNumberField;
  UITextField *_countryCodeField;
  FUICountryCodeInfo *_selectedCountryCode;
  __weak IBOutlet UITableView *_tableView;
  __weak IBOutlet UITextView *_tosTextView;
  FUICountryCodes *_countryCodes;
}

- (instancetype)initWithAuthUI:(FUIAuth *)authUI {
  return [self initWithNibName:NSStringFromClass([self class])
                        bundle:[FUIAuthUtils bundleNamed:FUIPhoneAuthBundleName]
                        authUI:authUI];
}

- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil
                         bundle:(nullable NSBundle *)nibBundleOrNil
                         authUI:(FUIAuth *)authUI {

  self = [super initWithNibName:nibNameOrNil
                         bundle:nibBundleOrNil
                         authUI:authUI];
  if (self) {
    self.title = FUIPhoneAuthLocalizedString(kPAStr_EnterPhoneTitle);
    _countryCodes = [[FUICountryCodes alloc] init];
    _selectedCountryCode = [_countryCodes countryCodeInfoFromDeviceLocale];

  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  UIBarButtonItem *nextButtonItem =
      [FUIAuthBaseViewController barItemWithTitle:FUIPhoneAuthLocalizedString(kPAStr_Verify)
                                           target:self
                                           action:@selector(next)];  
  nextButtonItem.accessibilityIdentifier = kNextButtonAccessibilityID;
  self.navigationItem.rightBarButtonItem = nextButtonItem;

  NSString *backLabel = FUIPhoneAuthLocalizedString(kPAStr_Back);
  UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:backLabel
                                                               style:UIBarButtonItemStylePlain
                                                              target:nil
                                                              action:nil];
  [self.navigationItem setBackBarButtonItem:backItem];
  _tosTextView.text = [NSString stringWithFormat:FUIPhoneAuthLocalizedString(kPAStr_TermsSMS),
                           FUIPhoneAuthLocalizedString(kPAStr_Verify)];

  [self enableDynamicCellHeightForTableView:_tableView];
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
    [self showAlertWithMessage:FUIPhoneAuthLocalizedString(kPAStr_EmptyPhoneNumber)];
    return;
  }

  [_phoneNumberField resignFirstResponder];
  [self incrementActivity];
  self.navigationItem.rightBarButtonItem.enabled = NO;
  FIRPhoneAuthProvider *provider = [FIRPhoneAuthProvider providerWithAuth:self.auth];
  NSString *phoneNumberWithCountryCode =
      [NSString stringWithFormat:@"+%@%@", _selectedCountryCode.dialCode, phoneNumber];
  [provider verifyPhoneNumber:phoneNumberWithCountryCode
                   completion:^(NSString *_Nullable verificationID, NSError *_Nullable error) {

    [self decrementActivity];
    self.navigationItem.rightBarButtonItem.enabled = YES;

    if (error) {
      [_phoneNumberField becomeFirstResponder];

      UIAlertController *alertController = [FUIPhoneAuth alertControllerForError:error
                                                                   actionHandler:nil];
      [self presentViewController:alertController animated:YES completion:nil];
      
      FUIPhoneAuth *delegate = [self.authUI providerWithID:FIRPhoneAuthProviderID];
      [delegate callbackWithCredential:nil error:error result:nil];
      return;
    }
   
    UIViewController *controller;
    if (self.authUI.delegate && [self.authUI.delegate respondsToSelector:@selector(phoneVerificationViewControllerForAuthUI:phoneNumber:)]) {
      controller = [self.authUI.delegate phoneVerificationViewControllerForAuthUI: self.authUI phoneNumber:phoneNumberWithCountryCode];
    } else {
      controller =
      [[FUIPhoneVerificationViewController alloc] initWithAuthUI:self.authUI
                                                  verificationID:verificationID
                                                     phoneNumber:phoneNumberWithCountryCode];
    }
    [self pushViewController:controller];
  }];
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
  return 2;
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
  if (indexPath.row == FUIPhoneEntryRowCountrySelector) {
    cell.label.text = FUIPhoneAuthLocalizedString(kPAStr_Country);
    cell.textField.enabled = NO;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    _countryCodeField = cell.textField;
    [self setCountryCodeValue];
  } else if (indexPath.row == FUIPhoneEntryRowPhoneNumber) {
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.label.text = FUIPhoneAuthLocalizedString(kPAStr_PhoneNumber);
    cell.textField.enabled = YES;
    cell.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    cell.textField.placeholder = FUIPhoneAuthLocalizedString(kPAStr_EnterYourPhoneNumber);
    cell.textField.delegate = self;
    cell.accessibilityIdentifier = kPhoneNumberCellAccessibilityID;
    _phoneNumberField = cell.textField;
    _phoneNumberField.secureTextEntry = NO;
    _phoneNumberField.autocorrectionType = UITextAutocorrectionTypeNo;
    _phoneNumberField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _phoneNumberField.returnKeyType = UIReturnKeyNext;
    _phoneNumberField.keyboardType = UIKeyboardTypeNumberPad;
    [_phoneNumberField becomeFirstResponder];
    [cell.textField addTarget:self
                       action:@selector(textFieldDidChange)
             forControlEvents:UIControlEventEditingChanged];
    [self didChangePhoneNumber:_phoneNumberField.text];
  }
  cell.selectionStyle = UITableViewCellSelectionStyleNone;
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.row == FUIPhoneEntryRowCountrySelector) {
    FUICountryTableViewController* countryTableViewController =
        [[FUICountryTableViewController alloc] initWithCountryCodes:_countryCodes];
    countryTableViewController.delegate = self;
    [self.navigationController pushViewController:countryTableViewController animated:YES];
  }
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

#pragma mark - CountryCodeDelegate

- (void)didSelectCountry:(FUICountryCodeInfo*)countryCodeInfo {
  _selectedCountryCode = countryCodeInfo;
  [self setCountryCodeValue];
  [_tableView reloadData];
}

- (void)setCountryCodeValue {
  NSString *countruCode;
  if ([FUIFeatureSwitch isCountryFlagEmojiEnabled]) {
    NSString *countryFlag = [_selectedCountryCode countryFlagEmoji];
    countruCode = [NSString stringWithFormat:@"%@ +%@ (%@)", countryFlag,
                      _selectedCountryCode.dialCode, _selectedCountryCode.localizedCountryName];
  } else {
    countruCode = [NSString stringWithFormat:@"+%@ (%@)", _selectedCountryCode.dialCode,
                      _selectedCountryCode.localizedCountryName];
  }
  _countryCodeField.text = countruCode;
}

#pragma mark - Private

- (void)cancelAuthorization {
  NSError *error = [FUIAuthErrorUtils userCancelledSignInError];
  FUIPhoneAuth *delegate = [self.authUI providerWithID:FIRPhoneAuthProviderID];
  [delegate callbackWithCredential:nil error:error result:^(FIRUser *_Nullable user,
                                                            NSError *_Nullable error) {
    if (!error || error.code == FUIAuthErrorCodeUserCancelledSignIn) {
      [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    } else {
      [self showAlertWithMessage:error.localizedDescription];
    }
  }];
}

@end

NS_ASSUME_NONNULL_END
