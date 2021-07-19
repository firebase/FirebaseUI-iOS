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

#import "FirebaseFacebookAuthUI/Sources/Public/FirebaseFacebookAuthUI/FUIFacebookAuth.h"

#import <FirebaseAuthUI/FirebaseAuthUI.h>
#import <FirebaseAuth/FirebaseAuth.h>

#if SWIFT_PACKAGE
@import FBSDKCoreKit;
@import FBSDKLoginKit;
#else
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#endif // SWIFT_PACKAGE

/** @var kTableName
    @brief The name of the strings table to search for localized strings.
 */
static NSString *const kTableName = @"FirebaseFacebookAuthUI";

/** @var kBundleName
    @brief The name of the bundle to search for resources.
 */
#if SWIFT_PACKAGE
static NSString *const kBundleName = @"FirebaseUI_FirebaseFacebookAuthUI";
#else
static NSString *const kBundleName = @"FirebaseFacebookAuthUI";
#endif // SWIFT_PACKAGE

/** @var kSignInWithFacebook
    @brief The string key for localized button text.
 */
static NSString *const kSignInWithFacebook = @"SignInWithFacebook";

/** @var kFacebookAppId
    @brief The string key used to read Facebook App Id from Info.plist.
 */
static NSString *const kFacebookAppId = @"FacebookAppID";

/** @var kFacebookDisplayName
    @brief The string key used to read Facebook App Name from Info.plist.
 */
static NSString *const kFacebookDisplayName = @"FacebookDisplayName";

@interface FUIFacebookAuth () <FUIAuthProvider>

/** @property authUI
    @brief FUIAuth instance of the application.
 */
@property(nonatomic, strong) FUIAuth *authUI;

/** @property providerForEmulator
    @brief The OAuth provider to be used when the emulator is enabled.
 */
@property(nonatomic, strong) FIROAuthProvider *providerForEmulator;

@end

@implementation FUIFacebookAuth {

  /** @var _pendingSignInCallback
      @brief The callback which should be invoked when the sign in flow completes (or is cancelled.)
   */
  FUIAuthProviderSignInCompletionBlock _pendingSignInCallback;

  /** @var _presentingViewController
      @brief The presenting view controller for interactive sign-in.
   */
  UIViewController *_presentingViewController;

  /** @var _email
      @brief The email address associated with this account.
   */
  NSString *_email;
}

+ (NSBundle *)bundle {
  return [FUIAuthUtils bundleNamed:kBundleName
                 inFrameworkBundle:[NSBundle bundleForClass:[self class]]];
}

- (instancetype)initWithAuthUI:(FUIAuth *)authUI
                   permissions:(NSArray *)permissions {
  self = [super init];
  if (self != nil) {
    _authUI = authUI;
    _scopes = permissions;
    [self configureProvider];
  }
  return self;
}

- (instancetype)initWithAuthUI:(FUIAuth *)authUI {
  return [self initWithAuthUI:authUI permissions:@[ @"email" ]];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-implementations"
- (instancetype)initWithPermissions:(NSArray *)permissions {
  self = [super init];
  if (self != nil) {
    _scopes = permissions;
    [self configureProvider];
  }
  return self;
}

- (instancetype)init {
  return [self initWithPermissions:@[ @"email" ]];
}
#pragma clang diagnostic pop


#pragma mark - FUIAuthProvider

- (nullable NSString *)providerID {
  return FIRFacebookAuthProviderID;
}

- (nullable NSString *)accessToken {
  if (self.authUI.isEmulatorEnabled) {
    return nil;
  }
  return [FBSDKAccessToken currentAccessToken].tokenString;
}

/** @fn idToken:
    @brief Facebook doesn't provide User Id Token during sign in flow
 */
- (nullable NSString *)idToken {
  return nil;
}

- (NSString *)shortName {
  return @"Facebook";
}

- (NSString *)signInLabel {
  return FUILocalizedStringFromTableInBundle(kSignInWithFacebook,
                                             kTableName,
                                             [FUIFacebookAuth bundle]);
}

- (UIImage *)icon {
  return [FUIAuthUtils imageNamed:@"ic_facebook" fromBundle:[FUIFacebookAuth bundle]];
}

- (UIColor *)buttonBackgroundColor {
  return [UIColor colorWithRed:59.0f/255.0f green:89.0f/255.0f blue:152.0f/255.0f alpha:1.0f];
}

- (UIColor *)buttonTextColor {
  return [UIColor whiteColor];
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
  _pendingSignInCallback = completion;
  _presentingViewController = presentingViewController;

  if (self.authUI.isEmulatorEnabled) {
    [self signInWithOAuthProvider:self.providerForEmulator
         presentingViewController:presentingViewController
                       completion:completion];
    return;
  }

  [_loginManager logInWithPermissions:_scopes
                   fromViewController:presentingViewController
                              handler:^(FBSDKLoginManagerLoginResult *result,
                                        NSError *error) {
    if (error) {
      NSError *newError =
          [FUIAuthErrorUtils providerErrorWithUnderlyingError:error
                                                     providerID:FIRFacebookAuthProviderID];
      [self completeSignInFlowWithAccessToken:nil error:newError];
    } else if (result.isCancelled) {
      NSError *newError = [FUIAuthErrorUtils userCancelledSignInError];
      [self completeSignInFlowWithAccessToken:nil error:newError];
    } else {
      // Retrieve email.
      [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{ @"fields" : @"email" }] startWithCompletion:^(id<FBSDKGraphRequestConnecting> connection,
                                id result,
                                NSError *error) {
        self->_email = result[@"email"];
      }];
      [self completeSignInFlowWithAccessToken:result.token.tokenString
                                        error:nil];
    }
  }];
}

- (void)signInWithOAuthProvider:(FIROAuthProvider *)oauthProvider
       presentingViewController:(nullable UIViewController *)presentingViewController
                     completion:(nullable FUIAuthProviderSignInCompletionBlock)completion {
  oauthProvider.scopes = self.scopes;

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

- (NSString *)email {
  return _email;
}

- (void)signOut {
  if (self.authUI.isEmulatorEnabled) {
    return;
  }
  [_loginManager logOut];
}

- (BOOL)handleOpenURL:(NSURL *)URL sourceApplication:(NSString *)sourceApplication {
  if (self.authUI.isEmulatorEnabled) {
    return NO;
  }
  return [[FBSDKApplicationDelegate sharedInstance] application:[UIApplication sharedApplication]
                                                        openURL:URL
                                              sourceApplication:sourceApplication
                                                     annotation:nil];
}

#pragma mark -

/** @fn completeSignInFlowWithAccessToken:error:
    @brief Called with the result of a Facebook sign-in attempt. Invokes and clears any pending
        sign in callback block.
    @param accessToken The Facebook access token, if successful.
    @param error An error which occurred during the sign-in attempt.
 */
- (void)completeSignInFlowWithAccessToken:(nullable NSString *)accessToken
                                    error:(nullable NSError *)error {
  if (error) {
    [self callbackWithCredential:nil error:error result:nil];
    return;
  }
  // Assume accessToken cannot be nil if there's no error.
  NSString *_Nonnull token = (id _Nonnull)accessToken;
  FIRAuthCredential *credential = [FIRFacebookAuthProvider credentialWithAccessToken:token];
  UIActivityIndicatorView *activityView =
      [FUIAuthBaseViewController addActivityIndicator:_presentingViewController.view];
  [activityView startAnimating];
  [self callbackWithCredential:credential error:nil result:^(FIRUser *_Nullable user,
                                                             NSError *_Nullable error) {
    [activityView stopAnimating];
    [activityView removeFromSuperview];
  }];
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
  _pendingSignInCallback = nil;
  if (callback) {
    callback(credential, error, result, nil);
  }
}

/** @fn callbackWithCredential:error:
    @brief Validates that Facebook SDK data was filled in Info.plist and creates Facebook login manager 
 */
- (void)configureProvider {
  NSBundle *bundle = [NSBundle mainBundle];
  NSString *facebookAppId = [bundle objectForInfoDictionaryKey:kFacebookAppId];
  NSString *facebookDisplayName = [bundle objectForInfoDictionaryKey:kFacebookDisplayName];

  if (facebookAppId == nil || facebookDisplayName == nil) {
    // Executes in test targets only.
    bundle = [FUIFacebookAuth bundle];
    facebookAppId = facebookAppId ?: [bundle objectForInfoDictionaryKey:kFacebookAppId];
    facebookDisplayName = facebookDisplayName ?:
        [bundle objectForInfoDictionaryKey:kFacebookDisplayName];
  }

  if (!(facebookAppId && facebookDisplayName)) {
    [NSException raise:NSInternalInconsistencyException
                format:@"Please set FacebookAppID, FacebookDisplayName, and\nURL types > Url "
     @"Schemes in `Supporting Files/Info.plist` according to "
     @"https://developers.facebook.com/docs/ios/getting-started"];
  }

  if (self.authUI.isEmulatorEnabled) {
    _providerForEmulator = [FIROAuthProvider providerWithProviderID:self.providerID];
  } else {
    _loginManager = [self createLoginManager];
  }
}

#pragma mark - Private methods

- (FBSDKLoginManager *)createLoginManager {
  return [[FBSDKLoginManager alloc] init];
}

@end
