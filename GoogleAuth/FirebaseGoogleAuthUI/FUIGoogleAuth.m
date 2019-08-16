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

#import "FUIGoogleAuth.h"

#import <FirebaseAuth/FIRAuth.h>
#import <FirebaseAuth/FIRGoogleAuthProvider.h>
#import <FirebaseAuth/FIRUserInfo.h>
#import "FUIAuthBaseViewController.h"
#import "FUIAuthErrorUtils.h"
#import "FirebaseAuthUI.h"
#import <FirebaseCore/FirebaseCore.h>
#import <GoogleSignIn/GoogleSignIn.h>
#import "FUIAuthBaseViewController_Internal.h"
#import "FUIAuthStrings.h"
#import "FUIAuthUtils.h"

/** @var kTableName
    @brief The name of the strings table to search for localized strings.
 */
static NSString *const kTableName = @"FirebaseGoogleAuthUI";

/** @var kBundleName
    @brief The name of the bundle to search for resources.
 */
static NSString *const kBundleName = @"FirebaseGoogleAuthUI";

/** @var kSignInWithGoogle
    @brief The string key for localized button text.
 */
static NSString *const kSignInWithGoogle = @"SignInWithGoogle";

@interface FUIGoogleAuth () <GIDSignInDelegate>
@end
@implementation FUIGoogleAuth {
  /** @var _presentingViewController
      @brief The presenting view controller for interactive sign-in.
   */
  UIViewController *_presentingViewController;

  /** @var _pendingSignInCallback
      @brief The callback which should be invoked when the sign in flow completes (or is cancelled.)
   */
  FUIAuthProviderSignInCompletionBlock _pendingSignInCallback;

  /** @var _email
      @brief The email address associated with this account.
   */
  NSString *_email;
}

- (instancetype)init {
  return [self initWithScopes:@[kGoogleUserInfoEmailScope, kGoogleUserInfoProfileScope]];
}

- (instancetype)initWithScopes:(NSArray *)scopes {
  self = [super init];
  if (self) {
    _scopes = [scopes copy];
  }
  return self;
}

#pragma mark - FUIAuthProvider

- (nullable NSString *)providerID {
  return FIRGoogleAuthProviderID;
}

- (nullable NSString *)accessToken {
  return [GIDSignIn sharedInstance].currentUser.authentication.accessToken;
}

- (nullable NSString *)idToken {
  return [GIDSignIn sharedInstance].currentUser.authentication.idToken;
}

- (NSString *)shortName {
  return @"Google";
}

- (NSString *)signInLabel {
  return FUILocalizedStringFromTableInBundle(kSignInWithGoogle, kTableName, kBundleName);
}

- (UIImage *)icon {
  return [FUIAuthUtils imageNamed:@"ic_google" fromBundleNameOrNil:kBundleName];
}

- (UIColor *)buttonBackgroundColor {
  return [UIColor whiteColor];
}

- (UIColor *)buttonTextColor {
  return [UIColor colorWithWhite:0 alpha:0.54f];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-implementations"
- (void)signInWithEmail:(nullable NSString *)email
    presentingViewController:(nullable UIViewController *)presentingViewController
                  completion:(nullable FUIAuthProviderSignInCompletionBlock)completion {
  [self signInWithDefaultValue:email
      presentingViewController:presentingViewController
                    completion:completion];
}
#pragma clang diagnostic pop

- (void)signInWithDefaultValue:(nullable NSString *)defaultValue
      presentingViewController:(nullable UIViewController *)presentingViewController
                    completion:(nullable FUIAuthProviderSignInCompletionBlock)completion {
  _presentingViewController = presentingViewController;

  GIDSignIn *signIn = [self configuredGoogleSignIn];
  signIn.presentingViewController = presentingViewController;
  _pendingSignInCallback = ^(FIRAuthCredential *_Nullable credential,
                             NSError *_Nullable error,
                             _Nullable FIRAuthResultCallback result,
                             NSDictionary *_Nullable userInfo) {
    signIn.loginHint = nil;
    if (completion) {
      completion(credential, error, result, nil);
    }
  };

  signIn.loginHint = defaultValue;
  [signIn signIn];
}

- (void)signOut {
  GIDSignIn *signIn = [self configuredGoogleSignIn];
  [signIn signOut];
}

- (BOOL)handleOpenURL:(NSURL *)URL sourceApplication:(NSString *)sourceApplication {
  GIDSignIn *signIn = [self configuredGoogleSignIn];
  return [signIn handleURL:URL];
}

- (NSString *)email {
  return _email;
}

#pragma mark - GIDSignInDelegate methods

- (void)signIn:(GIDSignIn *)signIn
    didSignInForUser:(GIDGoogleUser *)user
           withError:(NSError *)error {
  if (error) {
    if (error.code == kGIDSignInErrorCodeCanceled) {
      [self callbackWithCredential:nil
                             error:[FUIAuthErrorUtils
                                    userCancelledSignInError] result:nil];
    } else {
      NSError *newError =
          [FUIAuthErrorUtils providerErrorWithUnderlyingError:error
                                                     providerID:FIRGoogleAuthProviderID];
      [self callbackWithCredential:nil error:newError result:nil];
    }
    return;
  }
  _email = user.profile.email;
  UIActivityIndicatorView *activityView =
      [FUIAuthBaseViewController addActivityIndicator:_presentingViewController.view];
  [activityView startAnimating];
  FIRAuthCredential *credential =
      [FIRGoogleAuthProvider credentialWithIDToken:user.authentication.idToken
                                       accessToken:user.authentication.accessToken];
  [self callbackWithCredential:credential error:nil result:^(FIRUser *_Nullable user,
                                                             NSError *_Nullable error) {
    [activityView stopAnimating];
    [activityView removeFromSuperview];
  }];
}

#pragma mark - Helpers

/** @fn configuredGoogleSignIn
    @brief Returns an instance of @c GIDSignIn which is configured to match the configuration
        of this instance.
 */
- (GIDSignIn *)configuredGoogleSignIn {
  GIDSignIn *signIn = [GIDSignIn sharedInstance];
  signIn.delegate = self;
  signIn.shouldFetchBasicProfile = YES;
  signIn.clientID = [[FIRApp defaultApp] options].clientID;
  signIn.scopes = _scopes;
  return signIn;
}

/** @fn callbackWithCredential:error:
    @brief Ends the sign-in flow by cleaning up and calling back with given credential or error.
    @param credential The credential to pass back, if any.
    @param error The error to pass back, if any.
    @param result The result of sign-in operation using provided @c FIRAuthCredential object.
        @see @c FIRAuth.signInWithCredential:completion:
 */
- (void)callbackWithCredential:(nullable FIRAuthCredential *)credential
                         error:(nullable NSError *)error
                        result:(nullable FIRAuthResultCallback)result {
  FUIAuthProviderSignInCompletionBlock callback = _pendingSignInCallback;
  _presentingViewController = nil;
  _pendingSignInCallback = nil;
  if (callback) {
    callback(credential, error, result, nil);
  }
}

@end
