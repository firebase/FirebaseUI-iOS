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

#import "FUIFacebookAuth.h"

#import <FirebaseAuth/FirebaseAuth.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "FUIAuthBaseViewController.h"
#import "FUIAuthErrorUtils.h"
#import "FUIAuthBaseViewController_Internal.h"
#import "FUIAuthStrings.h"
#import "FUIAuthUtils.h"

/** @var kTableName
    @brief The name of the strings table to search for localized strings.
 */
static NSString *const kTableName = @"FirebaseFacebookAuthUI";

/** @var kBundleName
    @brief The name of the bundle to search for resources.
 */
static NSString *const kBundleName = @"FirebaseFacebookAuthUI";

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


#pragma mark - FUIAuthProvider

- (nullable NSString *)providerID {
  return FIRFacebookAuthProviderID;
}

- (nullable NSString *)accessToken {
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
  return FUILocalizedStringFromTableInBundle(kSignInWithFacebook, kTableName, kBundleName);
}

- (UIImage *)icon {
  return [FUIAuthUtils imageNamed:@"ic_facebook" fromBundleNameOrNil:kBundleName];
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
      [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{ @"fields" : @"email" }]
          startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result,
                                       NSError *error) {
        self->_email = result[@"email"];
      }];
      [self completeSignInFlowWithAccessToken:result.token.tokenString
                                        error:nil];
    }
  }];
}

- (NSString *)email {
  return _email;
}

- (void)signOut {
  [_loginManager logOut];
}

- (BOOL)handleOpenURL:(NSURL *)URL sourceApplication:(NSString *)sourceApplication {
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
  FIRAuthCredential *credential = [FIRFacebookAuthProvider credentialWithAccessToken:accessToken];
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
    bundle = [FUIAuthUtils bundleNamed:nil];
    facebookAppId = [bundle objectForInfoDictionaryKey:kFacebookAppId];
    facebookDisplayName = [bundle objectForInfoDictionaryKey:kFacebookDisplayName];
  }

  if (!(facebookAppId && facebookDisplayName)) {
    [NSException raise:NSInternalInconsistencyException
                format:@"Please set FacebookAppID, FacebookDisplayName, and\nURL types > Url "
     @"Schemes in `Supporting Files/Info.plist` according to "
     @"https://developers.facebook.com/docs/ios/getting-started"];
  }

  _loginManager = [self createLoginManager];
}

#pragma mark - Private methods

- (FBSDKLoginManager *)createLoginManager {
  return [[FBSDKLoginManager alloc] init];
}

@end
