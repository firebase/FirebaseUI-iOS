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

#import <FirebaseAuth/FIRAuthUIDelegate.h>
#import <FirebaseAuth/FIRPhoneAuthProvider.h>
#import "FirebaseAuth/FIRPhoneAuthCredential.h"
#import "FUIAuth_Internal.h"
#import "FUICodeField.h"
#import "FUIPhoneAuthStrings.h"
#import "FUIPhoneAuth_Internal.h"
#import "FUIPrivacyAndTermsOfServiceView+PhoneAuth.h"

NS_ASSUME_NONNULL_BEGIN

/** @var kNextButtonAccessibilityID
    @brief The Accessibility Identifier for the @c next button.
 */
static NSString *const kNextButtonAccessibilityID = @"NextButtonAccessibilityID";

static NSTimeInterval FUIDelayInSecondsBeforeShowingResendConfirmationCode = 15;

/** Regex pattern that matches for a TOS style link. For example: [Terms]. */
static NSString *const kLinkPlaceholderPattern = @"\\[([^\\]]+)\\]";

@interface FUIPhoneVerificationViewController () <FUICodeFieldDelegate, FIRAuthUIDelegate>
@end

@implementation FUIPhoneVerificationViewController {
  __weak IBOutlet FUICodeField *_codeField;
  __weak IBOutlet UILabel *_resendConfirmationCodeTimerLabel;
  __weak IBOutlet UIButton *_resendCodeButton;
  __weak IBOutlet UILabel *_actionDescriptionLabel;
  __weak IBOutlet UIButton *_phoneNumberButton;
  __weak IBOutlet FUIPrivacyAndTermsOfServiceView *_tosView;
  __weak IBOutlet UIScrollView *_scrollView;
  NSString *_verificationID;
  NSTimer *_resendConfirmationCodeTimer;
  NSTimeInterval _resendConfirmationCodeSeconds;
  NSString *_phoneNumber;
}

- (instancetype)initWithAuthUI:(FUIAuth *)authUI
                verificationID:(NSString *)verificationID
                   phoneNumber:(NSString *)phoneNumber{
  return [self initWithNibName:NSStringFromClass([self class])
                        bundle:[FUIAuthUtils bundleNamed:FUIPhoneAuthBundleName]
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
      [FUIAuthBaseViewController barItemWithTitle:FUIPhoneAuthLocalizedString(kPAStr_Next)
                                           target:self
                                           action:@selector(next)];
  nextButtonItem.accessibilityIdentifier = kNextButtonAccessibilityID;
  self.navigationItem.rightBarButtonItem = nextButtonItem;
  self.navigationItem.rightBarButtonItem.enabled = NO;
  _tosView.authUI = self.authUI;
  [_tosView useFooterMessage];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self registerForKeyboardNotifications];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  [self unregisterFromNotifications];
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
  [_codeField resignFirstResponder];
  FIRPhoneAuthProvider *provider = [FIRPhoneAuthProvider providerWithAuth:self.auth];
  [provider verifyPhoneNumber:_phoneNumber
                   UIDelegate:self
                   completion:^(NSString *_Nullable verificationID, NSError *_Nullable error) {
    // Temporary fix to guarantee execution of the completion block on the main thread.
    // TODO: Remove temporary workaround when the issue is fixed in FirebaseAuth.
    dispatch_block_t completionBlock = ^() {
      [self decrementActivity];
      self->_verificationID = verificationID;
      [self->_codeField becomeFirstResponder];

      if (error) {
        UIAlertController *alertController = [FUIPhoneAuth alertControllerForError:error
                                                                     actionHandler:^{
                                               [self->_codeField clearCodeInput];
                                               [self->_codeField becomeFirstResponder];
                                             }];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
      }

      NSString *resultMessage =
          [NSString stringWithFormat:FUIPhoneAuthLocalizedString(kPAStr_ResendCodeResult),
              self->_phoneNumber];
      [self showAlertWithMessage:resultMessage];
    };
    if ([NSThread isMainThread]) {
      completionBlock();
    } else {
      dispatch_async(dispatch_get_main_queue(), completionBlock);
    }
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

  FIRAuthCredential *credential =
    [provider credentialWithVerificationID:_verificationID verificationCode:verificationCode];

  [self incrementActivity];
  [_codeField resignFirstResponder];
  self.navigationItem.rightBarButtonItem.enabled = NO;
  FUIPhoneAuth *delegate = [self.authUI providerWithID:FIRPhoneAuthProviderID];
  [delegate callbackWithCredential:credential
                             error:nil
                            result:^(FIRUser *_Nullable user, NSError *_Nullable error) {
    [self decrementActivity];
    self.navigationItem.rightBarButtonItem.enabled = YES;
    if (!error ||
        error.code == FUIAuthErrorCodeUserCancelledSignIn ||
        error.code == FUIAuthErrorCodeMergeConflict) {
      [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    } else {
      UIAlertController *alertController = [FUIPhoneAuth alertControllerForError:error
                                                                   actionHandler:^{
                                             [self->_codeField clearCodeInput];
                                             [self->_codeField becomeFirstResponder];
                                           }];
      [self presentViewController:alertController animated:YES completion:nil];
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
  FUIPhoneAuth *delegate = [self.authUI providerWithID:FIRPhoneAuthProviderID];
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

- (void)startResendTimer {
  _resendConfirmationCodeSeconds = FUIDelayInSecondsBeforeShowingResendConfirmationCode;
  [self updateResendLabel];

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

  [self updateResendLabel];
}

- (void)resendConfirmationCodeTimerFinished {
  [self cleanUpTimer];

  _resendCodeButton.hidden = NO;
}

- (void)updateResendLabel {
  NSInteger minutes = (NSInteger)_resendConfirmationCodeSeconds / 60; // Integer type for truncation
  NSInteger seconds = (NSInteger)round(_resendConfirmationCodeSeconds) % 60;
  NSString *formattedTime = [NSString stringWithFormat:@"%ld:%02ld", (long)minutes, (long)seconds];

  _resendConfirmationCodeTimerLabel.text =
      [NSString stringWithFormat:FUIPhoneAuthLocalizedString(kPAStr_ResendCodeTimer),
           formattedTime];
}

#pragma mark - UIKeyboard observer methods

- (void)registerForKeyboardNotifications {
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(keyboardWasShown:)
                                               name:UIKeyboardDidShowNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(keyboardWillBeHidden:)
                                               name:UIKeyboardWillHideNotification object:nil];
}

- (void)unregisterFromNotifications {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)keyboardWasShown:(NSNotification*)aNotification {
  NSDictionary* info = [aNotification userInfo];
  CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
  CGFloat topOffset = self.navigationController.navigationBar.frame.size.height +
      [UIApplication sharedApplication].statusBarFrame.size.height;
  
  UIEdgeInsets contentInsets = UIEdgeInsetsMake(topOffset, 0.0, kbSize.height, 0.0);
  
  [UIView beginAnimations:nil context:NULL];
  
  NSDictionary *userInfo = [aNotification userInfo];
  [UIView setAnimationDuration:[userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
  [UIView setAnimationCurve:[userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];

  _scrollView.contentInset = contentInsets;
  _scrollView.scrollIndicatorInsets = contentInsets;
  
  [_scrollView scrollRectToVisible:_codeField.frame animated:NO];

  [UIView commitAnimations];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
  UIEdgeInsets contentInsets = UIEdgeInsetsZero;
  CGFloat topOffset = self.navigationController.navigationBar.frame.size.height +
      [UIApplication sharedApplication].statusBarFrame.size.height;
  contentInsets.top = topOffset;

  [UIView beginAnimations:nil context:NULL];
  
  NSDictionary *userInfo = [aNotification userInfo];
  [UIView setAnimationDuration:[userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
  [UIView setAnimationCurve:[userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];

  _scrollView.contentInset = contentInsets;
  _scrollView.scrollIndicatorInsets = contentInsets;

  [UIView commitAnimations];
}

@end

NS_ASSUME_NONNULL_END
