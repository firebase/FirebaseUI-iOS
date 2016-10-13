//
//  AuthViewController.m
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


#import "FIRCustomPasswordSignUpViewController.h"

@interface FIRCustomPasswordSignUpViewController ()
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@end

@implementation FIRCustomPasswordSignUpViewController

- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil
                         bundle:(nullable NSBundle *)nibBundleOrNil
                         authUI:(FIRAuthUI *)authUI
                          email:(NSString *_Nullable)email {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil authUI:authUI email:email];

  if (self) {
    _emailTextField.text = _email;
  }
  return self;
}

- (IBAction)onNextPressed:(id)sender {
  [self signUpWithEmail:_emailTextField.text
            andPassword:_passwordTextField.text
            andUsername:_usernameTextField.text];
}

- (IBAction)onCancelPressed:(id)sender {
  [self cancelAuthorization];
}

- (IBAction)onBackPressed:(id)sender {
  [self onBack];
}

- (IBAction)onViewSelected:(id)sender {
  [_emailTextField resignFirstResponder];
  [_passwordTextField resignFirstResponder];
  [_usernameTextField resignFirstResponder];
}

#pragma mark - UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  if (textField == _emailTextField) {
    [_usernameTextField becomeFirstResponder];
  } else if (textField == _usernameTextField) {
    [_passwordTextField becomeFirstResponder];
  } else if (textField == _passwordTextField) {
    [self onNextPressed:nil];
  }

  return NO;
}

@end
