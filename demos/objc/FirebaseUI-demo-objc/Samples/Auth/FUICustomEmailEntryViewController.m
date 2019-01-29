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

#import "FUICustomEmailEntryViewController.h"

@interface FUICustomEmailEntryViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *nextButton;
@end

@implementation FUICustomEmailEntryViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  //override action of default 'Next' button to use custom layout elements
  self.navigationItem.rightBarButtonItem.target = self;
  self.navigationItem.rightBarButtonItem.action = @selector(onNextButton:);
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  //update state of all UI elements (e g disable 'Next' buttons)
  [self updateEmailValue:_emailTextField];
}

- (IBAction)onBack:(id)sender {
  [self onBack];
}
- (IBAction)onNextButton:(id)sender {
  [self onNext:_emailTextField.text];
}
- (IBAction)onCancel:(id)sender {
  [self cancelAuthorization];
}
- (IBAction)updateEmailValue:(UITextField *)sender {
  BOOL enableActionButton = sender.text.length > 0;
  self.nextButton.enabled = enableActionButton;

  [self didChangeEmail:sender.text];
}

- (IBAction)onViewSelected:(id)sender {
  [_emailTextField resignFirstResponder];
}

#pragma mark - UITextFieldDelegate methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  [self onNext:textField.text];

  return NO;
}

@end
