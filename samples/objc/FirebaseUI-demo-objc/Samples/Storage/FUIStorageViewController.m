//
//  AuthViewController.h
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

#import "FUIStorageViewController.h"

#import <FirebaseStorage/FirebaseStorage.h>
#import <FirebaseStorageUI/FirebaseStorageUI.h>

@interface FUIStorageViewController ()
@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) IBOutlet UITextField *textField;

/// Used to move the view's contents when the keyboard appears.
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *bottomConstraint;
@end

@implementation FUIStorageViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.imageView.contentMode = UIViewContentModeScaleAspectFit;
  self.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
  self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(keyboardWillShow:)
                                               name:UIKeyboardWillShowNotification
                                             object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(keyboardWillHide:)
                                               name:UIKeyboardWillHideNotification
                                             object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)loadButtonPressed:(id)sender {
  self.imageView.image = nil;
  if (self.textField.text == nil) return;
  NSURL *url = [NSURL URLWithString:self.textField.text];
  if (url == nil) return;

  FIRStorageReference *storageRef = [[FIRStorage storage]
    referenceWithPath:url.path ?: @""];

  [self.imageView sd_setImageWithStorageReference:storageRef
                                 placeholderImage:nil
                                       completion:^(UIImage *image,
                                                    NSError *error,
                                                    SDImageCacheType
                                                    cacheType,
                                                    FIRStorageReference *ref) {
    if (error != nil) {
      NSLog(@"Error loading image: %@", error.localizedDescription);
    }
  }];
}

#pragma mark - Keyboard boilerplate

- (void)keyboardWillShow:(NSNotification *)notification {
  NSDictionary *userInfo = notification.userInfo;
  NSValue *endFrameValue = userInfo[UIKeyboardFrameEndUserInfoKey];
  CGFloat endHeight = endFrameValue.CGRectValue.size.height;

  self.bottomConstraint.constant = endHeight;

  UIViewAnimationCurve curve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
  NSTimeInterval duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];

  [UIView setAnimationCurve:curve];
  [UIView animateWithDuration:duration animations:^{
    [self.view layoutIfNeeded];
  }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
  NSDictionary *userInfo = notification.userInfo;

  self.bottomConstraint.constant = 0;

  UIViewAnimationCurve curve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
  NSTimeInterval duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];

  [UIView setAnimationCurve:curve];
  [UIView animateWithDuration:duration animations:^{
    [self.view layoutIfNeeded];
  }];
}

@end
