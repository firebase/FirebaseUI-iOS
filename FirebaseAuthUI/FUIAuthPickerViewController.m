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

#import "FUIAuthPickerViewController.h"

#import <FirebaseAuth/FirebaseAuth.h>
#import "FUIAuthProvider.h"
#import "FUIAuthErrorUtils.h"
#import "FUIAuthSignInButton.h"
#import "FUIAuthStrings.h"
#import "FUIAuthUtils.h"
#import "FUIAuth_Internal.h"
#import "FUIEmailEntryViewController.h"
#import "FUIPasswordVerificationViewController.h"

/** @var kErrorUserInfoEmailKey
    @brief The key for the email address in the userinfo dictionary of a sign in error.
 */
static NSString *const kErrorUserInfoEmailKey = @"FIRAuthErrorUserInfoEmailKey";

/** @var kEmailButtonAccessibilityID
    @brief The Accessibility Identifier for the @c email sign in button.
 */
static NSString *const kEmailButtonAccessibilityID = @"EmailButtonAccessibilityID";

/** @var kSignInButtonWidth
    @brief The width of the sign in buttons.
 */
static const CGFloat kSignInButtonWidth = 220.0f;

/** @var kSignInButtonHeight
    @brief The height of the sign in buttons.
 */
static const CGFloat kSignInButtonHeight = 40.0f;

/** @var kSignInButtonVerticalMargin
    @brief The vertical margin between sign in buttons.
 */
static const CGFloat kSignInButtonVerticalMargin = 24.0f;

/** @var kButtonContainerBottomMargin
    @brief The magin between sign in buttons and the bottom of the screen.
 */
static const CGFloat kButtonContainerBottomMargin = 56.0f;

@implementation FUIAuthPickerViewController {
  UIView *_buttonContainerView;
}

- (instancetype)initWithAuthUI:(FUIAuth *)authUI {
  return [self initWithNibName:@"FUIAuthPickerViewController"
                        bundle:[FUIAuthUtils frameworkBundle]
                        authUI:authUI];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil
                         bundle:(NSBundle *)nibBundleOrNil
                         authUI:(FUIAuth *)authUI {

  self = [super initWithNibName:nibNameOrNil
                         bundle:nibBundleOrNil
                         authUI:authUI];
  if (self) {
    self.title = [FUIAuthStrings authPickerTitle];
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  UIBarButtonItem *cancelBarButton =
      [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                    target:self
                                                    action:@selector(cancelAuthorization)];
  self.navigationItem.leftBarButtonItem = cancelBarButton;

  NSInteger numberOfButtons = self.authUI.providers.count;
  BOOL showEmailButton = !self.authUI.signInWithEmailHidden;
  if (showEmailButton) {
    ++numberOfButtons;
  }
  CGFloat buttonContainerViewHeight =
      kSignInButtonHeight * numberOfButtons + kSignInButtonVerticalMargin * (numberOfButtons - 1);
  CGRect buttonContainerViewFrame = CGRectMake(0, 0, kSignInButtonWidth, buttonContainerViewHeight);
  _buttonContainerView = [[UIView alloc] initWithFrame:buttonContainerViewFrame];
  [self.view addSubview:_buttonContainerView];

  CGRect buttonFrame = CGRectMake(0, 0, kSignInButtonWidth, kSignInButtonHeight);
  for (id<FUIAuthProvider> providerUI in self.authUI.providers) {
    UIButton *providerButton =
        [[FUIAuthSignInButton alloc] initWithFrame:buttonFrame providerUI:providerUI];
    [providerButton addTarget:self
                       action:@selector(didTapSignInButton:)
             forControlEvents:UIControlEventTouchUpInside];
    [_buttonContainerView addSubview:providerButton];

    // Make the frame for the new button.
    buttonFrame.origin.y += (kSignInButtonHeight + kSignInButtonVerticalMargin);
  }

  if (showEmailButton) {
    UIColor *emailButtonBackgroundColor =
        [UIColor colorWithRed:208.f/255.f green:2.f/255.f blue:27.f/255.f alpha:1.0];
    UIButton *emailButton =
        [[FUIAuthSignInButton alloc] initWithFrame:buttonFrame
                                               image:[FUIAuthUtils imageNamed:@"ic_email"]
                                                text:[FUIAuthStrings signInWithEmail]
                                     backgroundColor:emailButtonBackgroundColor
                                           textColor:[UIColor whiteColor]];
    [emailButton addTarget:self
                    action:@selector(signInWithEmail)
          forControlEvents:UIControlEventTouchUpInside];
    emailButton.accessibilityIdentifier = kEmailButtonAccessibilityID;
    [_buttonContainerView addSubview:emailButton];
  }
}

- (void)viewDidLayoutSubviews {
  [super viewDidLayoutSubviews];

  CGFloat distanceFromCenterToBottom =
      CGRectGetHeight(_buttonContainerView.frame) / 2.0f + kButtonContainerBottomMargin;
  CGFloat centerY = CGRectGetHeight(self.view.bounds) - distanceFromCenterToBottom;
  // Compensate for bounds adjustment if any.
  centerY += self.view.bounds.origin.y;
  _buttonContainerView.center = CGPointMake(self.view.center.x, centerY);
}

#pragma mark - Actions

- (void)signInWithEmail {
  UIViewController *controller;
  if ([self.authUI.delegate respondsToSelector:@selector(emailEntryViewControllerForAuthUI:)]) {
    controller = [self.authUI.delegate emailEntryViewControllerForAuthUI:self.authUI];
  } else {
    controller = [[FUIEmailEntryViewController alloc] initWithAuthUI:self.authUI];
  }
  [self pushViewController:controller];
}

- (void)didTapSignInButton:(FUIAuthSignInButton *)button {
  [self signInWithProviderUI:button.providerUI];
}

- (void)signInWithProviderUI:(id<FUIAuthProvider>)providerUI {
  [self incrementActivity];

  // Sign out first to make sure sign in starts with a clean state.
  [providerUI signOut];
  [providerUI signInWithEmail:nil
     presentingViewController:self
                   completion:^(FIRAuthCredential *_Nullable credential,
                                NSError *_Nullable error) {
                     if (error) {
                       [self decrementActivity];

                       if (error.code == FUIAuthErrorCodeUserCancelledSignIn) {
                         // User cancelled sign in, Do nothing.
                         return;
                       }

                       [self.navigationController dismissViewControllerAnimated:YES completion:^{
                         [self.authUI invokeResultCallbackWithUser:nil error:error];
                       }];
                       return;
                     }

    [self.auth signInWithCredential:credential
                         completion:^(FIRUser *_Nullable user, NSError *_Nullable error) {
      if (error && error.code == FIRAuthErrorCodeEmailAlreadyInUse) {
        NSString *email = error.userInfo[kErrorUserInfoEmailKey];
        [self handleAccountLinkingForEmail:email newCredential:credential];
        return;
      }

      [self decrementActivity];

      [self.navigationController dismissViewControllerAnimated:YES completion:^{
        [self.authUI invokeResultCallbackWithUser:user error:error];
      }];
    }];
  }];
}

- (void)handleAccountLinkingForEmail:(NSString *)email
                       newCredential:(FIRAuthCredential *)newCredential {
  [self.auth fetchProvidersForEmail:email
                         completion:^(NSArray<NSString *> *_Nullable providers,
                                      NSError *_Nullable error) {
    [self decrementActivity];

    if (error) {
      if (error.code == FIRAuthErrorCodeInvalidEmail) {
        // This should never happen because the email address comes from the backend.
        [self showAlertWithMessage:[FUIAuthStrings invalidEmailError]];
      } else {
        [self.navigationController dismissViewControllerAnimated:YES completion:^{
          [self.authUI invokeResultCallbackWithUser:nil error:error];
        }];
      }
      return;
    }
    if (!providers.count) {
      // This should never happen because the user must be registered.
      [self showAlertWithMessage:[FUIAuthStrings cannotAuthenticateError]];
      return;
    }
    NSString *bestProviderID = providers[0];
    if ([bestProviderID isEqual:FIREmailPasswordAuthProviderID]) {
      // Password verification.
      UIViewController *controller;
      if ([self.authUI.delegate respondsToSelector:@selector(passwordVerificationViewControllerForAuthUI:email:newCredential:)]) {

        controller = [self.authUI.delegate passwordVerificationViewControllerForAuthUI:self.authUI
                                                                                 email:email
                                                                         newCredential:newCredential];
      } else {
        controller = [[FUIPasswordVerificationViewController alloc] initWithAuthUI:self.authUI
                                                                             email:email
                                                                     newCredential:newCredential];

      }
      [self pushViewController:controller];
      return;
    }
    id<FUIAuthProvider> bestProvider = [self providerWithID:bestProviderID];
    if (!bestProvider) {
      // Unsupported provider.
      [self showAlertWithMessage:[FUIAuthStrings cannotAuthenticateError]];
      return;
    }

    [self showSignInAlertWithEmail:email provider:bestProvider handler:^{
      [self incrementActivity];

      // Sign out first to make sure sign in starts with a clean state.
      [bestProvider signOut];
      [bestProvider signInWithEmail:email
           presentingViewController:self
                         completion:^(FIRAuthCredential *_Nullable credential,
                                      NSError *_Nullable error) {
                           if (error) {
                             [self decrementActivity];

                             if (error.code == FUIAuthErrorCodeUserCancelledSignIn) {
                               // User cancelled sign in, Do nothing.
                               return;
                             }

                             [self.navigationController dismissViewControllerAnimated:YES completion:^{
                               [self.authUI invokeResultCallbackWithUser:nil error:error];
                             }];
                             return;
                           }

        [self.auth signInWithCredential:credential completion:^(FIRUser *_Nullable user,
                                                                NSError *_Nullable error) {
          if (error) {
            [self decrementActivity];

            [self.navigationController dismissViewControllerAnimated:YES completion:^{
              [self.authUI invokeResultCallbackWithUser:nil error:error];
            }];
            return;
          }

          [user linkWithCredential:newCredential completion:^(FIRUser *_Nullable user,
                                                              NSError *_Nullable error) {
            [self decrementActivity];

            // Ignore any error (most likely caused by email mismatch) and treat the user as
            // successfully signed in.
            [self.navigationController dismissViewControllerAnimated:YES completion:^{
              [self.authUI invokeResultCallbackWithUser:user error:nil];
            }];
          }];
        }];
      }];
    }];
  }];
}

#pragma mark - Utilities

- (nullable id<FUIAuthProvider>)providerWithID:(NSString *)providerID {
  NSArray<id<FUIAuthProvider>> *providers = self.authUI.providers;
  for (id<FUIAuthProvider> provider in providers) {
    if ([provider.providerID isEqual:providerID]) {
      return provider;
    }
  }
  return nil;
}

@end
