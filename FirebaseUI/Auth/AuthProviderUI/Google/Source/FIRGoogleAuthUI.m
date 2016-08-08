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

#import "FIRGoogleAuthUI.h"

#import <GoogleSignIn/GoogleSignIn.h>
#import <FirebaseAuth/FIRGoogleAuthProvider.h>
#import <FirebaseAuth/FIRUserInfo.h>
#import "FIRAuthUIErrorUtils.h"

/** @var kGoogleGamesScope
    @brief The OAuth scope string for the "Games" scope.
 */
static NSString *const kGoogleGamesScope = @"https://www.googleapis.com/auth/games";

/** @var kGooglePlusMeScope
    @brief The OAuth scope string for the "plus.me" scope.
 */
static NSString *const kGooglePlusMeScope = @"https://www.googleapis.com/auth/plus.me";

/** @var kGooglePlusMeScope
 @brief The OAuth scope string for the user's email scope.
 */
static NSString *const kGoogleUserInfoEmailScope = @"https://www.googleapis.com/auth/userinfo.email";

/** @var kGooglePlusMeScope
 @brief The OAuth scope string for the basic G+ profile information scope.
 */
static NSString *const kGoogleUserInfoProfileScope = @"https://www.googleapis.com/auth/userinfo.profile";

/** @var kTableName
    @brief The name of the strings table to search for localized strings.
*/
static NSString *const kTableName = @"FirebaseGoogleAuthUI";

/** @var kSignInWithGoogle
    @brief The string key for localized button text.
 */
static NSString *const kSignInWithGoogle = @"SignInWithGoogle";

@interface FIRGoogleAuthUI () <GIDSignInDelegate, GIDSignInUIDelegate>
@end
@implementation FIRGoogleAuthUI {
  /** @var _presentingViewController
      @brief The presenting view controller for interactive sign-in.
   */
  UIViewController *_presentingViewController;

  /** @var _pendingSignInCallback
      @brief The callback which should be invoked when the sign in flow completes (or is cancelled.)
   */
  FIRAuthProviderSignInCompletionBlock _pendingSignInCallback;
}

- (instancetype)init {
  @throw [NSException exceptionWithName:@"Attempt to call unavailable initializer."
                                 reason:@"Please call the designated initializer."
                               userInfo:nil];
}

- (instancetype)initWithClientID:(NSString *)clientID {
  return [self initWithClientID:clientID
                         scopes:@[kGoogleUserInfoEmailScope, kGoogleUserInfoProfileScope]];
}

- (instancetype)initWithClientID:(NSString *)clientID scopes:(NSArray *)scopes {
  self = [super init];
  if (self) {
    _clientID = [clientID copy];
    _scopes = scopes;
  }
  return self;
}

/** @fn frameworkBundle
    @brief Returns the auth provider's resource bundle.
    @return Resource bundle for the auth provider.
 */
+ (NSBundle *)frameworkBundle {
  static NSBundle *frameworkBundle = nil;
  static dispatch_once_t predicate;
  dispatch_once(&predicate, ^{
    NSString *mainBundlePath = [[NSBundle mainBundle] resourcePath];
    NSString *frameworkBundlePath =
        [mainBundlePath stringByAppendingPathComponent:@"FirebaseGoogleAuthUIBundle.bundle"];
    frameworkBundle = [NSBundle bundleWithPath:frameworkBundlePath];
    if (!frameworkBundle) {
      frameworkBundle = [NSBundle mainBundle];
    }
  });
  return frameworkBundle;
}

/** @fn imageNamed:
    @brief Returns an image from the resource bundle given a resource name.
    @param name The name of the image file.
    @return The image object for the named file.
 */
+ (UIImage *)imageNamed:(NSString *)name {
  NSString *path = [[[self class] frameworkBundle] pathForResource:name ofType:@"png"];
  return [UIImage imageWithContentsOfFile:path];
}

/** @fn localizedStringForKey:
    @brief Returns the localized text associated with a given string key. Will default to english
        text if the string is not available for the current localization.
    @param key A string key which identifies localized text in the .strings files.
    @return Localized value of the string identified by the key.
 */
+ (NSString *)localizedStringForKey:(NSString *)key {
  NSBundle *frameworkBundle = [[self class] frameworkBundle];
  return [frameworkBundle localizedStringForKey:key value:nil table:kTableName];
}

#pragma mark - FIRAuthProviderUI

- (NSString *)providerID {
  return FIRGoogleAuthProviderID;
}

- (NSString *)shortName {
  return @"Google";
}

- (NSString *)signInLabel {
  return [[self class] localizedStringForKey:kSignInWithGoogle];
}

- (UIImage *)icon {
  return [[self class] imageNamed:@"ic_google"];
}

- (UIColor *)buttonBackgroundColor {
  return [UIColor whiteColor];
}

- (UIColor *)buttonTextColor {
  return [UIColor colorWithWhite:0 alpha:0.54f];
}

- (void)signInWithAuth:(FIRAuth *)auth
                       email:(nullable NSString *)email
    presentingViewController:(nullable UIViewController *)presentingViewController
                  completion:(nullable FIRAuthProviderSignInCompletionBlock)completion {
  _presentingViewController = presentingViewController;

  GIDSignIn *signIn = [self configuredGoogleSignIn];
  _pendingSignInCallback = ^(FIRAuthCredential *_Nullable credential, NSError *_Nullable error) {
    signIn.loginHint = nil;
    if (completion) {
      completion(credential, error);
    }
  };

  signIn.loginHint = email;
  [signIn signIn];
}

- (void)signOutWithAuth:(FIRAuth *)auth {
  GIDSignIn *signIn = [self configuredGoogleSignIn];
  [signIn signOut];
}

- (BOOL)handleOpenURL:(NSURL *)URL sourceApplication:(NSString *)sourceApplication {
  GIDSignIn *signIn = [self configuredGoogleSignIn];
  return [signIn handleURL:URL sourceApplication:sourceApplication annotation:nil];
}

#pragma mark - GIDSignInDelegate methods

- (void)signIn:(GIDSignIn *)signIn
    didSignInForUser:(GIDGoogleUser *)user
           withError:(NSError *)error {
  if (error) {
    if (error.code == kGIDSignInErrorCodeCanceled) {
      [self callbackWithCredential:nil error:[FIRAuthUIErrorUtils userCancelledSignInError]];
    } else {
      NSError *newError =
          [FIRAuthUIErrorUtils providerErrorWithUnderlyingError:error
                                                     providerID:FIRGoogleAuthProviderID];
      [self callbackWithCredential:nil error:newError];
    }
    return;
  }
  FIRAuthCredential *credential =
      [FIRGoogleAuthProvider credentialWithIDToken:user.authentication.idToken
                                       accessToken:user.authentication.accessToken];
  [self callbackWithCredential:credential error:nil];
}

#pragma mark - GIDSignInUIDelegate methods

- (void)signIn:(GIDSignIn *)signIn presentViewController:(UIViewController *)viewController {
  [_presentingViewController presentViewController:viewController animated:YES completion:nil];
}

- (void)signIn:(GIDSignIn *)signIn dismissViewController:(UIViewController *)viewController {
  [_presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Helpers

/** @fn configuredGoogleSignIn
    @brief Returns an instance of @c GIDSignIn which is configured to match the configuration
        of this instance.
 */
- (GIDSignIn *)configuredGoogleSignIn {
  GIDSignIn *signIn = [GIDSignIn sharedInstance];
  signIn.delegate = self;
  signIn.uiDelegate = self;
  signIn.shouldFetchBasicProfile = YES;
  signIn.clientID = _clientID;
  signIn.scopes = _scopes;
  return signIn;
}

/** @fn callbackWithCredential:error:
    @brief Ends the sign-in flow by cleaning up and calling back with given credential or error.
    @param credential The credential to pass back, if any.
    @param error The error to pass back, if any.
 */
- (void)callbackWithCredential:(nullable FIRAuthCredential *)credential
                         error:(nullable NSError *)error {
  FIRAuthProviderSignInCompletionBlock callback = _pendingSignInCallback;
  _presentingViewController = nil;
  _pendingSignInCallback = nil;
  if (callback) {
    callback(credential, error);
  }
}

@end
