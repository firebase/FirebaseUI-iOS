// clang-format off

/*
 * Firebase UI Bindings iOS Library
 *
 * Copyright © 2015 Firebase - All Rights Reserved
 * https://www.firebase.com
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice, this
 * list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binaryform must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY FIREBASE AS IS AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
 * EVENT SHALL FIREBASE BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 * OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

// clang-format on

#import "FirebaseLoginViewController.h"

@implementation FirebaseLoginViewController {
  FirebaseAuthProvider *_selectedAuthProvider;
  NSMutableArray *_socialProviders;
}

- (instancetype)initWithRef:(Firebase *)ref;
{
  self = [super init];
  if (self) {
    self.ref = ref;
    _socialProviders = [[NSMutableArray alloc] initWithCapacity:3];
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  // Add cancel button
  UIImage *image = [[UIImage imageNamed:@"ic_clear_18pt"]
      imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
  [self.cancelButton setImage:image forState:UIControlStateNormal];
  self.cancelButton.imageView.tintColor =
      [UIColor colorWithRed:158.0f / 255.0f green:158.0f / 255.0f blue:158.0f / 255.0f alpha:1.0f];
  [self.cancelButton addTarget:self
                        action:@selector(dismissViewController)
              forControlEvents:UIControlEventTouchUpInside];

  // If we're already logged in, cancel this
  if (_selectedAuthProvider) {
    [self dismissViewController];
  }

  if (self.passwordAuthProvider == nil && [_socialProviders count] == 0) {
    [self dismissViewController];  // Or throw an exception--you need to have at least one provider
  }

  // Populate email/password view
  if (self.passwordAuthProvider != nil) {
    FirebaseLoginButton *emailLoginButton =
        [[FirebaseLoginButton alloc] initWithProvider:kPasswordAuthProvider];
    CGRect buttonFrame =
        CGRectMake(0, 2 * kTextFieldHeight + 2 * kTextFieldSpace, kButtonWidth, kButtonHeight);
    emailLoginButton.frame = buttonFrame;
    [emailLoginButton addTarget:self
                         action:@selector(loginButtonPressed:)
               forControlEvents:UIControlEventTouchUpInside];
    [self.emailPasswordView addSubview:emailLoginButton];
  } else {
    [self.socialView
        setFrame:CGRectMake(self.emailPasswordView.frame.origin.x,
                            self.emailPasswordView.frame.origin.y, self.socialView.frame.size.width,
                            self.socialView.frame.size.height)];
    [self.emailPasswordView removeFromSuperview];
    self.totalHeightConstraint.constant -=
        (2 * kTextFieldHeight + 2 * kTextFieldSpace + 1 * kButtonHeight);
  }

  // Populate social view
  NSUInteger numProviders = [_socialProviders count];
  if (numProviders == 0) {
    [self.socialView removeFromSuperview];
    self.totalHeightConstraint.constant -= (3 * kButtonHeight + 2 * kButtonSpace);
  } else {
    // Add buttons to social view
    CGRect buttonFrame = CGRectMake(0, 0, kButtonWidth, kButtonHeight);
    for (FirebaseAuthProvider *provider in _socialProviders) {
      FirebaseLoginButton *loginButton =
          [[FirebaseLoginButton alloc] initWithProvider:provider.provider];
      loginButton.frame = buttonFrame;
      [loginButton addTarget:self
                      action:@selector(loginButtonPressed:)
            forControlEvents:UIControlEventTouchUpInside];
      [self.socialView addSubview:loginButton];
      buttonFrame.origin.y += kButtonHeight + kButtonSpace;
    }

    // Size social view and login view appropriately
    CGFloat socialViewHeight = numProviders * kButtonHeight + (numProviders - 1) * kButtonSpace;
    self.socialHeightConstraint.constant = socialViewHeight;
    self.totalHeightConstraint.constant -=
        (3 * kButtonHeight + 2 * kButtonSpace - socialViewHeight);
  }

  // Handle separator
  if (self.passwordAuthProvider == nil || numProviders == 0) {
    [self.separatorView removeFromSuperview];
    self.totalHeightConstraint.constant -= (kSeparatorHeight + kSeparatorSpace);
  }

  [self.view layoutIfNeeded];
}

- (instancetype)enableProvider:(NSString *)provider {
  if ([provider isEqualToString:kGoogleAuthProvider]) {
    if (!self.googleAuthProvider) {
      self.googleAuthProvider =
          [[FirebaseGoogleAuthProvider alloc] initWithRef:self.ref authDelegate:self uiDelegate:self];
      [_socialProviders addObject:self.googleAuthProvider];
    }
  } else if ([provider isEqualToString:kFacebookAuthProvider]) {
    if (!self.facebookAuthProvider) {
      self.facebookAuthProvider =
          [[FirebaseFacebookAuthProvider alloc] initWithRef:self.ref authDelegate:self];
      [_socialProviders addObject:self.facebookAuthProvider];
    }
  } else if ([provider isEqualToString:kTwitterAuthProvider]) {
    if (!self.twitterAuthProvider) {
      self.twitterAuthProvider = [[FirebaseTwitterAuthProvider alloc] initWithRef:self.ref
                                                                 authDelegate:self
                                                              twitterDelegate:self];
      [_socialProviders addObject:self.twitterAuthProvider];
    }
  } else if ([provider isEqualToString:kPasswordAuthProvider]) {
    if (!self.passwordAuthProvider) {
      self.passwordAuthProvider =
          [[FirebasePasswordAuthProvider alloc] initWithRef:self.ref authDelegate:self];
    }
  }
  return self;
}

- (void)loginButtonPressed:(id)button {
  if ([button isKindOfClass:[FirebaseLoginButton class]]) {
    FirebaseLoginButton *loginButton = (FirebaseLoginButton *)button;
    if ([loginButton.provider isEqualToString:kGoogleAuthProvider]) {
      [self.googleAuthProvider login];
    } else if ([loginButton.provider isEqualToString:kFacebookAuthProvider]) {
      [self.facebookAuthProvider login];
    } else if ([loginButton.provider isEqualToString:kTwitterAuthProvider]) {
      [self.twitterAuthProvider login];
    } else if ([loginButton.provider isEqualToString:kPasswordAuthProvider]) {
      // We assume that if it wasn't a social provider, it was for email/password
      NSString *email = self.emailTextField.text;
      NSString *password = self.passwordTextField.text;
      [self.passwordAuthProvider loginWithEmail:email andPassword:password];
    }
  }
}

- (void)logout {
  if (_selectedAuthProvider) {
    [_selectedAuthProvider logout];
  }
}

- (FAuthData *)currentUser {
  return [self.ref authData];
}

- (void)dismissViewController {
  [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark Firebase Auth Delegate methods

- (void)authProvider:(id)provider onLogin:(FAuthData *)authData {
  _selectedAuthProvider = provider;
  self.emailTextField.text = @"";
  self.passwordTextField.text = @"";
  [self dismissViewController];
}

- (void)authProvider:(id)provider onProviderError:(NSError *)error {
  UIAlertController *providerErrorController =
      [UIAlertController alertControllerWithTitle:@"Provider error!"
                                          message:error.localizedDescription
                                   preferredStyle:UIAlertControllerStyleAlert];
  [providerErrorController
      addAction:[UIAlertAction actionWithTitle:@"Ok"
                                         style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction *_Nonnull action) {
                                         self.passwordTextField.text = @"";
                                       }]];

  [self presentViewController:providerErrorController animated:YES completion:nil];
}

- (void)authProvider:(id)provider onUserError:(NSError *)error {
  UIAlertController *userErrorController =
      [UIAlertController alertControllerWithTitle:@"User error!"
                                          message:error.localizedDescription
                                   preferredStyle:UIAlertControllerStyleAlert];
  [userErrorController addAction:[UIAlertAction actionWithTitle:@"Ok"
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction *_Nonnull action) {
                                                          self.passwordTextField.text = @"";
                                                        }]];

  [self presentViewController:userErrorController animated:YES completion:nil];
}

- (void)onLogout {
  _selectedAuthProvider = nil;
}

#pragma mark -
#pragma mark Twitter Auth Delegate methods

- (void)createTwitterAccount {
  [[UIApplication sharedApplication]
      openURL:[NSURL URLWithString:@"https://www.twitter.com/signup"]];
}

- (void)selectTwitterAccount:(NSArray *)accounts {
  UIAlertController *accountSelectController = [UIAlertController
      alertControllerWithTitle:@"Select Twitter Account"
                       message:
                           @"Please select which Twitter account you would like to sign in with."
                preferredStyle:UIAlertControllerStyleActionSheet];

  [accounts
      enumerateObjectsUsingBlock:^(ACAccount *account, NSUInteger index, BOOL *_Nonnull stop) {
        UIAlertAction *addAccountAction =
            [UIAlertAction actionWithTitle:account.username
                                     style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *_Nonnull action) {
                                     [self.twitterAuthProvider loginWithAccount:account];
                                   }];
        [accountSelectController addAction:addAccountAction];
      }];

  UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                         style:UIAlertActionStyleCancel
                                                       handler:^(UIAlertAction *_Nonnull action){
                                                       }];
  [accountSelectController addAction:cancelAction];

  [self presentViewController:accountSelectController animated:YES completion:nil];
}

@end