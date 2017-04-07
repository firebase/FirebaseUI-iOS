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

/** @var kNextButtonAccessibilityID
    @brief The Accessibility Identifier for the @c next button.
 */
static NSString *const kNextButtonAccessibilityID = @"NextButtonAccessibilityID";

@implementation FUIPhoneVerificationViewController {
  __unsafe_unretained IBOutlet FUICodeField *_codeField;
  NSString *_verificationID;
}

- (instancetype)initWithAuthUI:(FUIAuth *)authUI
                verificationID:(NSString *)verificationID {
  return [self initWithNibName:NSStringFromClass([self class])
                        bundle:[FUIAuthUtils frameworkBundle]
                        authUI:authUI
                verificationID:verificationID];
}

- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil
                         bundle:(nullable NSBundle *)nibBundleOrNil
                         authUI:(FUIAuth *)authUI
                 verificationID:(NSString *)verificationID {

  self = [super initWithNibName:nibNameOrNil
                         bundle:nibBundleOrNil
                         authUI:authUI];
  if (self) {
    self.title = FUIPhoneAuthLocalizedString(kPAStr_EnterPhoneTitle);
    _verificationID = [verificationID copy];
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

  [_codeField becomeFirstResponder];
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

  [self.navigationController dismissViewControllerAnimated:YES completion:^{
    FUIPhoneAuth *delegate = [self phoneAuthProvider];
    [delegate callbackWithCredential:credential error:nil];
  }];

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
