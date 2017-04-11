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

#import "FUIPhoneVerificationViewController.h"

#import "FUICodeField.h"
#import "FUIPhoneAuthStrings.h"
#import "FUIPhoneAuth_Internal.h"
#import <FirebaseAuth/FIRPhoneAuthProvider.h>

NS_ASSUME_NONNULL_BEGIN

/** @var kNextButtonAccessibilityID
    @brief The Accessibility Identifier for the @c next button.
 */
static NSString *const kNextButtonAccessibilityID = @"NextButtonAccessibilityID";

static NSTimeInterval FUIDelayInSecondsBeforeShowingResendConfirmationCode = 15;

@interface FUIPhoneVerificationViewController () <FUICodeFieldDelegate>
@end

@implementation FUIPhoneVerificationViewController {
  __unsafe_unretained IBOutlet FUICodeField *_codeField;
  __unsafe_unretained IBOutlet UITextView *_resendConfirmationCodeTimerLabel;
  __unsafe_unretained IBOutlet UIButton *_resendCodeButton;
  __unsafe_unretained IBOutlet UILabel *_actionDescriptionLabel;
  __unsafe_unretained IBOutlet UIButton *_phoneNumberButton;
  NSString *_verificationID;
  NSTimer *_resendConfirmationCodeTimer;
  NSTimeInterval _resendConfirmationCodeSeconds;
  NSString *_phoneNumber;
}

- (instancetype)initWithAuthUI:(FUIAuth *)authUI
                verificationID:(NSString *)verificationID
                   phoneNumber:(NSString *)phoneNumber{
  return [self initWithNibName:NSStringFromClass([self class])
                        bundle:[FUIAuthUtils frameworkBundle]
                        authUI:authUI
                verificationID:verificationID
                   phoneNumber:phoneNumber];
}

- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil
                         bundle:(nullable NSBundle *)nibBundleOrNil
                         authUI:(FUIAuth *)authUI
                 verificationID:(NSString *)verificationID
                    phoneNumber:(NSString *)phoneNumber {

  self = [super initWithNibName:nibNameOrNil
                         bundle:nibBundleOrNil
                         authUI:authUI];
  if (self) {
    self.title = FUIPhoneAuthLocalizedString(kPAStr_VerifyPhoneTitle);
    _verificationID = [verificationID copy];
    _phoneNumber = [phoneNumber copy];

    [_resendCodeButton setTitle:FUIPhoneAuthLocalizedString(kPAStr_ResendCode)
                       forState:UIControlStateNormal];
    _actionDescriptionLabel.text =
        [NSString stringWithFormat:FUIPhoneAuthLocalizedString(kPAStr_EnterCodeDescription),
             @(_codeField.codeLength)];
    [_phoneNumberButton setTitle:_phoneNumber forState:UIControlStateNormal];

    [_codeField becomeFirstResponder];
    [self startResendTimer];
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  UIBarButtonItem *nextButtonItem =
  [[UIBarButtonItem alloc] initWithTitle:FUIPhoneAuthLocalizedString(kPAStr_Next)
                                   style:UIBarButtonItemStylePlain
                                  target:self
                                  action:@selector(next)];
  nextButtonItem.accessibilityIdentifier = kNextButtonAccessibilityID;
  self.navigationItem.rightBarButtonItem = nextButtonItem;
  self.navigationItem.rightBarButtonItem.enabled = NO;
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

- (void)entryIsIncomplete {
  self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (void) entryIsCompletedWithCode:(NSString *)code {
  self.navigationItem.rightBarButtonItem.enabled = YES;
}

#pragma mark - Actions
- (IBAction)onResendCode:(id)sender {
  [_codeField clearCodeInput];
  [self startResendTimer];
  [self incrementActivity];
  FIRPhoneAuthProvider *provider = [FIRPhoneAuthProvider providerWithAuth:self.auth];
  [provider verifyPhoneNumber:_phoneNumber
                   completion:^(NSString *_Nullable verificationID, NSError *_Nullable error) {

    [self decrementActivity];
    _verificationID = verificationID;

    if (error) {
      [self showAlertWithMessage:error.localizedDescription];
      return;
    }

    NSString *resultMessage =
        [NSString stringWithFormat:FUIPhoneAuthLocalizedString(kPAStr_ResendCodeResult),
            _phoneNumber];
    [self showAlertWithMessage:resultMessage];
  }];
}
- (IBAction)onPhoneNumberSelected:(id)sender {
  [self onBack];
}

- (void)next {
  [self onNext:_codeField.codeEntry];
}

- (void)onNext:(NSString *)verificationCode {
  if (!verificationCode.length) {
    [self showAlertWithMessage:FUIPhoneAuthLocalizedString(kPAStr_EmptyVerificationCode)];
    return;
  }

  FIRPhoneAuthProvider *provider = [FIRPhoneAuthProvider providerWithAuth:self.auth];

  FIRPhoneAuthCredential *credential =
    [provider credentialWithVerificationID:_verificationID verificationCode:verificationCode];

  FUIPhoneAuth *delegate = [self phoneAuthProvider];
  [delegate callbackWithCredential:credential
                             error:nil
                            result:^(FIRUser *_Nullable user, NSError *_Nullable error) {
    if (!error || error.code == FUIAuthErrorCodeUserCancelledSignIn) {
      [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    } else if (error.code >= FIRAuthErrorCodeMissingPhoneNumber
                   && error.code <= FIRAuthErrorCodeInvalidVerificationID) {
      NSString *title = FUIPhoneAuthLocalizedString(kPAStr_IncorrectCodeTitle);
      NSString *message = FUIPhoneAuthLocalizedString(kPAStr_IncorrectCodeMessage);
      UIAlertController *alertController =
          [UIAlertController alertControllerWithTitle:title
                                              message:message
                                       preferredStyle:UIAlertControllerStyleAlert];
      UIAlertAction *okAction =
          [UIAlertAction actionWithTitle:FUIPhoneAuthLocalizedString(kPAStr_Done)
                                   style:UIAlertActionStyleDefault
                                 handler:nil];
      [alertController addAction:okAction];
      [self presentViewController:alertController animated:YES completion:nil];
    } else {
      [self showAlertWithMessage:error.localizedDescription];
    }
  }];

}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath
                      ofObject:(nullable id)object
                        change:(nullable NSDictionary<NSKeyValueChangeKey, id> *)change
                       context:(nullable void *)context {
  if (object == _codeField) {
    self.navigationItem.rightBarButtonItem.enabled =
        _codeField.codeEntry.length == _codeField.codeLength;
  }
}

#pragma mark - Private

- (void)cancelAuthorization {
  NSError *error = [FUIAuthErrorUtils userCancelledSignInError];
  FUIPhoneAuth *delegate = [self phoneAuthProvider];
  [delegate callbackWithCredential:nil
                             error:error
                            result:^(FIRUser *_Nullable user, NSError *_Nullable error) {
    if (!error || error.code == FUIAuthErrorCodeUserCancelledSignIn) {
      [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    } else {
      [self showAlertWithMessage:error.localizedDescription];
    }
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

- (void)startResendTimer {
  _resendConfirmationCodeSeconds = FUIDelayInSecondsBeforeShowingResendConfirmationCode;
  _resendConfirmationCodeTimerLabel.text =
      [NSString stringWithFormat:FUIPhoneAuthLocalizedString(kPAStr_ResendCodeTimer), @0,
          @(_resendConfirmationCodeSeconds)];

  _resendCodeButton.hidden = YES;
  _resendConfirmationCodeTimerLabel.hidden = NO;

  _resendConfirmationCodeTimer =
      [NSTimer scheduledTimerWithTimeInterval:1.0
                                       target:self
                                     selector:@selector(resendConfirmationCodeTick:)
                                     userInfo:nil
                                      repeats:YES];
}

- (void)cleanUpTimer {
  [_resendConfirmationCodeTimer invalidate];
  _resendConfirmationCodeTimer = nil;
  _resendConfirmationCodeSeconds = 0;
  _resendConfirmationCodeTimerLabel.hidden = YES;
}

- (void)resendConfirmationCodeTick:(id)sender {
  _resendConfirmationCodeSeconds -= 1.0;
  if (_resendConfirmationCodeSeconds <= 0){
    _resendConfirmationCodeSeconds = 0;
    [self resendConfirmationCodeTimerFinished];
  }

  _resendConfirmationCodeTimerLabel.text =
      [NSString stringWithFormat:FUIPhoneAuthLocalizedString(kPAStr_ResendCodeTimer), @0,
          @(_resendConfirmationCodeSeconds)];
}

- (void)resendConfirmationCodeTimerFinished {
  [self cleanUpTimer];

  _resendCodeButton.hidden = NO;
}

@end

NS_ASSUME_NONNULL_END
