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

#import "FUICustomPasswordRecoveryViewController.h"

@interface FUICustomPasswordRecoveryViewController ()
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *recoverButton;

@end

@implementation FUICustomPasswordRecoveryViewController

- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil
                         bundle:(nullable NSBundle *)nibBundleOrNil
                         authUI:(FUIAuth *)authUI
                          email:(NSString *_Nullable)email {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil authUI:authUI email:email];

  if (self) {
    _emailTextField.text = email;
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  //override action of default 'Next' button to use custom layout elements
  self.navigationItem.rightBarButtonItem.target = self;
  self.navigationItem.rightBarButtonItem.action = @selector(onRecoverButton:);
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  //update state of all UI elements (e g disable 'Next' buttons)
  [self updateEmailValue:_emailTextField];
}

- (IBAction)onBackButton:(id)sender {
  [self onBack];
}
- (IBAction)onRecoverButton:(id)sender {
  [self recoverEmail:_emailTextField.text];
}
- (IBAction)onCancel:(id)sender {
  [self cancelAuthorization];
}
- (IBAction)updateEmailValue:(UITextField *)sender {
  BOOL enableActionButton = sender.text.length > 0;
  self.recoverButton.enabled = enableActionButton;

  [self didChangeEmail:sender.text];
}

- (IBAction)onViewSelected:(id)sender {
  [_emailTextField resignFirstResponder];
}

#pragma mark - UITextFieldDelegate methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  [self recoverEmail:textField.text];

  return NO;
}
@end
