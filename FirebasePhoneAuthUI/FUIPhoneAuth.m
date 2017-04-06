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
  return nil; // TODO: implement
}

/** @fn idToken:
    @brief Phone Auth Token Secret is matched by FirebaseUI User Id Token
 */
- (NSString *)idToken {
  return nil; // TODO: implement
}

- (NSString *)shortName {
  return @"Phone";
}

- (NSString *)signInLabel {
  return FUILocalizedString(kStr_SignInWithTwitter);
}

- (UIImage *)icon {
  return [FUIAuthUtils imageNamed:@"ic_phone"];
}

- (UIColor *)buttonBackgroundColor {
  return [UIColor colorWithRed:71.0f/255.0f green:154.0f/255.0f blue:234.0f/255.0f alpha:1.0f];
}

- (UIColor *)buttonTextColor {
  return [UIColor whiteColor];
}

- (void)signInWithEmail:(nullable NSString *)email
    presentingViewController:(nullable UIViewController *)presentingViewController
                  completion:(nullable FIRAuthProviderSignInCompletionBlock)completion {

  _pendingSignInCallback = completion;

  UIViewController *controller = [[FUIPhoneEntryViewController alloc] initWithAuthUI:_authUI];
  UINavigationController *navigationController =
      [[UINavigationController alloc] initWithRootViewController:controller];
  [presentingViewController presentViewController:navigationController animated:YES completion:nil];
}

- (void)signOut {
  // TODO: implement
}

- (BOOL)handleOpenURL:(NSURL *)URL sourceApplication:(nullable NSString *)sourceApplication {
  return NO; // TODO: implement
}

- (void)callbackWithCredential:(nullable FIRAuthCredential *)credential
                         error:(nullable NSError *)error {
  FIRAuthProviderSignInCompletionBlock callback = _pendingSignInCallback;
  _pendingSignInCallback = nil;
  if (callback) {
    callback(credential, error);
  }
}

@end

NS_ASSUME_NONNULL_END
