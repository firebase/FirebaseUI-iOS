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

#import "FirebaseGoogleAuthUI/Sources/Public/FirebaseGoogleAuthUI/FUIGoogleAuth.h"

#import <FirebaseAuth/FirebaseAuth.h>
#import <FirebaseCore/FirebaseCore.h>
#import <GoogleSignIn/GoogleSignIn.h>
#import <FirebaseAuthUI/FirebaseAuthUI.h>

/** @var kTableName
    @brief The name of the strings table to search for localized strings.
 */
static NSString *const kTableName = @"FirebaseGoogleAuthUI";

/** @var kBundleName
    @brief The name of the bundle to search for resources.
 */
#if SWIFT_PACKAGE
static NSString *const kBundleName = @"FirebaseUI_FirebaseGoogleAuthUI";
#else
static NSString *const kBundleName = @"FirebaseGoogleAuthUI";
#endif // SWIFT_PACKAGE

/** @var kSignInWithGoogle
    @brief The string key for localized button text.
 */
static NSString *const kSignInWithGoogle = @"SignInWithGoogle";

@interface FUIGoogleAuth ()

/** @property authUI
    @brief FUIAuth instance of the application.
 */
@property(nonatomic, strong) FUIAuth *authUI;

/** @property providerForEmulator
    @brief The OAuth provider to be used when the emulator is enabled.
 */
@property(nonatomic, strong) FIROAuthProvider *providerForEmulator;

@end
@implementation FUIGoogleAuth {
  /** @var _email
      @brief The email address associated with this account.
   */
  NSString *_email;
}

+ (NSBundle *)bundle {
  return [FUIAuthUtils bundleNamed:kBundleName
                 inFrameworkBundle:[NSBundle bundleForClass:[self class]]];
}

+ (NSArray<NSString *> *)defaultScopes {
  return @[kGoogleUserInfoEmailScope, kGoogleUserInfoProfileScope];
}

- (instancetype)initWithAuthUI:(FUIAuth *)authUI {
  return [self initWithAuthUI:authUI scopes:@[kGoogleUserInfoEmailScope, kGoogleUserInfoProfileScope]];
}

- (instancetype)initWithAuthUI:(FUIAuth *)authUI scopes:(NSArray<NSString *> *)scopes {
  self = [super init];
  if (self) {
    _authUI = authUI;
    _scopes = [scopes copy];
    if (_authUI.isEmulatorEnabled) {
      _providerForEmulator = [FIROAuthProvider providerWithProviderID:self.providerID];
    }
  }
  return self;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-implementations"
- (instancetype)init {
  return [self initWithScopes:[[self class] defaultScopes]];
}

- (instancetype)initWithScopes:(NSArray *)scopes {
  self = [super init];
  if (self) {
    _scopes = [scopes copy];
  }
  return self;
}
#pragma clang diagnostic pop

- (GIDSignIn *)googleSignIn {
  return GIDSignIn.sharedInstance;
}

- (NSString *)clientID {
  return self.authUI.auth.app.options.clientID;
}

#pragma mark - FUIAuthProvider

- (nullable NSString *)providerID {
  return FIRGoogleAuthProviderID;
}

- (nullable NSString *)accessToken {
  if (self.authUI.isEmulatorEnabled) {
    return nil;
  }
  return [self googleSignIn].currentUser.authentication.accessToken;
}

- (nullable NSString *)idToken {
  if (self.authUI.isEmulatorEnabled) {
    return nil;
  }
  return [self googleSignIn].currentUser.authentication.idToken;
}

- (NSString *)shortName {
  return @"Google";
}

- (NSString *)signInLabel {
  return FUILocalizedStringFromTableInBundle(kSignInWithGoogle,
                                             kTableName,
                                             [FUIGoogleAuth bundle]);
}

- (UIImage *)icon {
  return [FUIAuthUtils imageNamed:@"ic_google" fromBundle:[FUIGoogleAuth bundle]];
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

  if (self.authUI.isEmulatorEnabled) {
    [self signInWithOAuthProvider:self.providerForEmulator
         presentingViewController:presentingViewController
                       completion:completion];
    return;
  }

  GIDSignIn *signIn = [self googleSignIn];
  NSString *clientID = [self clientID];

  if (!clientID) {
    [NSException raise:NSInternalInconsistencyException
                format:@"OAuth client ID not found. Please make sure Google Sign-In is enabled in "
     @"the Firebase console. You may have to download a new GoogleService-Info.plist file after "
     @"enabling Google Sign-In."];
  }

  GIDConfiguration *config = [[GIDConfiguration alloc] initWithClientID:clientID];

  FUIAuthProviderSignInCompletionBlock callback = ^(FIRAuthCredential *_Nullable credential,
                             NSError *_Nullable error,
                             _Nullable FIRAuthResultCallback result,
                             NSDictionary *_Nullable userInfo) {
    if (completion) {
      completion(credential, error, result, userInfo);
    }
  };

  [signIn signInWithConfiguration:config
         presentingViewController:presentingViewController
                             hint:defaultValue
                         callback:^(GIDGoogleUser *user, NSError *error) {
    [self handleSignInWithUser:user
                         error:error
      presentingViewController:presentingViewController
                      callback:callback];
  }];
}

- (void)signInWithOAuthProvider:(FIROAuthProvider *)oauthProvider
       presentingViewController:(nullable UIViewController *)presentingViewController
                     completion:(nullable FUIAuthProviderSignInCompletionBlock)completion {
  oauthProvider.scopes = [[self class] defaultScopes];

  [oauthProvider getCredentialWithUIDelegate:nil
                                  completion:^(FIRAuthCredential *_Nullable credential,
                                               NSError *_Nullable error) {
    if (error) {
      [FUIAuthBaseViewController showAlertWithMessage:error.localizedDescription
                             presentingViewController:presentingViewController];
      if (completion) {
        completion(nil, error, nil, nil);
      }
      return;
    }
    if (completion) {
      UIActivityIndicatorView *activityView =
          [FUIAuthBaseViewController addActivityIndicator:presentingViewController.view];
      [activityView startAnimating];
      FIRAuthResultCallback result = ^(FIRUser *_Nullable user,
                                       NSError *_Nullable error) {
        [activityView stopAnimating];
        [activityView removeFromSuperview];
      };
      completion(credential, nil, result, nil);
    }
  }];
}

- (void)requestScopesWithPresentingViewController:(UIViewController *)presentingViewController
                                       completion:(FUIAuthProviderSignInCompletionBlock)completion {
  GIDSignIn *signIn = [self googleSignIn];
  [signIn addScopes:self.scopes presentingViewController:presentingViewController
           callback:^(GIDGoogleUser *user, NSError *error) {
    [self handleSignInWithUser:user
                         error:error
      presentingViewController:presentingViewController
                      callback:^(FIRAuthCredential *credential,
                                 NSError *error,
                                 FIRAuthResultCallback result,
                                 NSDictionary<NSString *,id> *userInfo) {
      if (completion != nil) {
        completion(credential, error, result, userInfo);
      }
    }];
  }];
}

- (void)signOut {
  if (self.authUI.isEmulatorEnabled) {
    return;
  }
  GIDSignIn *signIn = [self googleSignIn];
  [signIn signOut];
}

- (BOOL)handleOpenURL:(NSURL *)URL sourceApplication:(NSString *)sourceApplication {
  if (self.authUI.isEmulatorEnabled) {
    return NO;
  }
  GIDSignIn *signIn = [self googleSignIn];
  return [signIn handleURL:URL];
}

- (NSString *)email {
  return _email;
}

- (void)handleSignInWithUser:(GIDGoogleUser *)user
                       error:(NSError *)error
    presentingViewController:(UIViewController *)presentingViewController
                    callback:(FUIAuthProviderSignInCompletionBlock)callback {
  if (error) {
    if (error.code == kGIDSignInErrorCodeCanceled) {
      NSError *newError = [FUIAuthErrorUtils userCancelledSignInError];
      if (callback) {
        callback(nil, newError, nil, nil);
      }
    } else {
      NSError *newError =
          [FUIAuthErrorUtils providerErrorWithUnderlyingError:error
                                                     providerID:FIRGoogleAuthProviderID];
      if (callback) {
        callback(nil, newError, nil, nil);
      }
    }
    return;
  }
  _email = user.profile.email;
  UIActivityIndicatorView *activityView =
      [FUIAuthBaseViewController addActivityIndicator:presentingViewController.view];
  [activityView startAnimating];
  FIRAuthCredential *credential =
      [FIRGoogleAuthProvider credentialWithIDToken:user.authentication.idToken
                                       accessToken:user.authentication.accessToken];
  FIRAuthResultCallback result = ^(FIRUser *_Nullable user,
                                   NSError *_Nullable error) {
    [activityView stopAnimating];
    [activityView removeFromSuperview];
  };
  if (callback) {
    callback(credential, error, result, nil);
  }
}

@end
