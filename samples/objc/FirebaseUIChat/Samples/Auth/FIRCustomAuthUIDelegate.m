//
//  FIRCustomAuthUIDelegate.m
//  FirebaseUIChat
//
//  Created by Yury Ramanchuk on 9/22/16.
//  Copyright © 2016 Firebase, Inc. All rights reserved.
//

#import "FIRCustomAuthUIDelegate.h"
#import "FIRCustomAuthPickerViewController.h"
@implementation FIRCustomAuthUIDelegate

- (void)authUI:(FIRAuthUI *)authUI didSignInWithUser:(nullable FIRUser *)user error:(nullable NSError *)error {
  if (error) {
    if (error.code == FIRAuthUIErrorCodeUserCancelledSignIn) {
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

- (FIRAuthPickerViewController *)authPickerViewControllerForAuthUI:(FIRAuthUI *)authUI {
  return [[FIRCustomAuthPickerViewController alloc] initWithNibName:NSStringFromClass([FIRCustomAuthPickerViewController class])
                                                             bundle:nil
                                                             authUI:authUI];
}

@end