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

#import "FUIPhoneAuth_Internal.h"

#import "FUIAuth_Internal.h"
#import "FUINavigationViewController.h"
#import "FUIPhoneAuthStrings.h"
#import "FUIPhoneEntryViewController.h"
#import <FirebaseAuth/FIRPhoneAuthProvider.h>

NS_ASSUME_NONNULL_BEGIN

@implementation FUIPhoneAuth {
  /** The @c FUIAuth instance of the application. */
  FUIAuth *_authUI;

  /** The callback which should be invoked when the sign in flow completes (or is cancelled.) */
  FIRAuthProviderSignInCompletionBlock _pendingSignInCallback;

}

- (instancetype)initWithAuthUI:(FUIAuth *)authUI {
  if (self = [super init]) {
    _authUI = authUI;
  }

  return self;
}

#pragma mark - FUIAuthProvider

- (NSString *)providerID {
  return FIRPhoneAuthProviderID;
}

/** @fn accessToken:
    @brief Phone Auth token is matched by FirebaseUI User Access Token
 */
- (NSString *)accessToken {
  return nil;
}

/** @fn idToken:
    @brief Phone Auth Token Secret is matched by FirebaseUI User Id Token
 */
- (NSString *)idToken {
  return nil;
}

- (NSString *)shortName {
  return @"Phone";
}

- (NSString *)signInLabel {
  return FUIPhoneAuthLocalizedString(kPAStr_SignInWithTwitter);
}

- (UIImage *)icon {
  return [FUIAuthUtils imageNamed:@"ic_phone"];
}

- (UIColor *)buttonBackgroundColor {
  return [UIColor colorWithRed:31.0f/255.0f green:189.0f/255.0f blue:77.0f/255.0f alpha:1.0f];
}

- (UIColor *)buttonTextColor {
  return [UIColor whiteColor];
}

- (void)signInWithPresentingViewController:(UIViewController *)presentingViewController {
  [_authUI signInWithProviderUI:self presentingViewController:presentingViewController];
}

- (void)signInWithEmail:(nullable NSString *)email
    presentingViewController:(nullable UIViewController *)presentingViewController
                  completion:(nullable FIRAuthProviderSignInCompletionBlock)completion {

  _pendingSignInCallback = completion;

  UIViewController *controller = [[FUIPhoneEntryViewController alloc] initWithAuthUI:_authUI];
  UINavigationController *navigationController =
      [[FUINavigationViewController alloc] initWithRootViewController:controller];
  [presentingViewController presentViewController:navigationController animated:YES completion:nil];
}

- (void)signOut {
}

- (BOOL)handleOpenURL:(NSURL *)URL sourceApplication:(nullable NSString *)sourceApplication {
  return NO;
}

- (void)callbackWithCredential:(nullable FIRAuthCredential *)credential
                         error:(nullable NSError *)error
                        result:(nullable FIRAuthResultCallback)result {
  FIRAuthProviderSignInCompletionBlock callback = _pendingSignInCallback;

  FIRAuthResultCallback resultAuthCallback = ^(FIRUser *_Nullable user, NSError *_Nullable error) {
    if (!error) {
      _pendingSignInCallback = nil;
    }
    if (result) {
      result(user, error);
    }
  };
  if (callback) {
    callback(credential, error, resultAuthCallback);
  }
}

@end

NS_ASSUME_NONNULL_END
