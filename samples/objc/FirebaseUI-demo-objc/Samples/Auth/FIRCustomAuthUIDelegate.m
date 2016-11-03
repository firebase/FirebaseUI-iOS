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

#import "FIRCustomAuthUIDelegate.h"
#import "FIRCustomAuthPickerViewController.h"
#import "FIRCustomEmailEntryViewController.h"
#import "FIRCustomPasswordSignInViewController.h"
#import "FIRCustomPasswordSignUpViewController.h"
#import "FIRCustomPasswordRecoveryViewController.h"
#import "FIRCustomPasswordVerificationViewController.h"

@implementation FIRCustomAuthUIDelegate

- (void)authUI:(FUIAuth *)authUI didSignInWithUser:(nullable FIRUser *)user error:(nullable NSError *)error {
  if (error) {
    if (error.code == FUIAuthErrorCodeUserCancelledSignIn) {
      NSLog(@"User cancelled sign-in");
    } else {
      NSError *detailedError = error.userInfo[NSUnderlyingErrorKey];
      if (!detailedError) {
        detailedError = error;
      }
      NSLog(@"Login error: %@", detailedError.localizedDescription);
    }
  }
}

- (FUIAuthPickerViewController *)authPickerViewControllerForAuthUI:(FUIAuth *)authUI {
  return [[FIRCustomAuthPickerViewController alloc] initWithAuthUI:authUI];
}

- (FUIEmailEntryViewController *)emailEntryViewControllerForAuthUI:(FUIAuth *)authUI {
  return [[FIRCustomEmailEntryViewController alloc] initWithAuthUI:authUI];

}

- (FUIPasswordSignInViewController *)passwordSignInViewControllerForAuthUI:(FUIAuth *)authUI
                                                                     email:(NSString *)email {
  return [[FIRCustomPasswordSignInViewController alloc] initWithAuthUI:authUI
                                                                  email:email];

}

- (FUIPasswordSignUpViewController *)passwordSignUpViewControllerForAuthUI:(FUIAuth *)authUI
                                                                     email:(NSString *)email {
  return [[FIRCustomPasswordSignUpViewController alloc] initWithAuthUI:authUI
                                                                  email:email];

}

- (FUIPasswordRecoveryViewController *)passwordRecoveryViewControllerForAuthUI:(FUIAuth *)authUI
                                                                         email:(NSString *)email {
  return [[FIRCustomPasswordRecoveryViewController alloc] initWithAuthUI:authUI
                                                                    email:email];
  
}

- (FUIPasswordVerificationViewController *)passwordVerificationViewControllerForAuthUI:(FUIAuth *)authUI
                                                                                 email:(NSString *)email
                                                                         newCredential:(FIRAuthCredential *)newCredential {
  return [[FIRCustomPasswordVerificationViewController alloc] initWithAuthUI:authUI
                                                                        email:email
                                                                newCredential:newCredential];
}

@end
