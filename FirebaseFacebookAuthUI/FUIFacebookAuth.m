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
#import <FirebaseAuthUI/FUIAuthErrorUtils.h>

/** @var kTableName
    @brief The name of the strings table to search for localized strings.
 */
static NSString *const kTableName = @"FirebaseFacebookAuthUI";

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
  FIRAuthProviderSignInCompletionBlock _pendingSignInCallback;
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

/** @fn frameworkBundle
    @brief Returns the auth provider's resource bundle.
    @return Resource bundle for the auth provider.
 */
+ (NSBundle *)frameworkBundle {
  static NSBundle *frameworkBundle = nil;
  static dispatch_once_t predicate;
  dispatch_once(&predicate, ^{
    frameworkBundle = [NSBundle bundleForClass:[self class]];
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

#pragma mark - FUIAuthProvider

- (NSString *)providerID {
  return FIRFacebookAuthProviderID;
}

- (NSString *)accessToken {
  return [FBSDKAccessToken currentAccessToken].tokenString;
}

/** @fn idToken:
    @brief Facebook doesn't provide User Id Token during sign in flow
 */
- (NSString *)idToken {
  return nil;
}

- (NSString *)shortName {
  return @"Facebook";
}

- (NSString *)signInLabel {
  return [[self class] localizedStringForKey:kSignInWithFacebook];
}

- (UIImage *)icon {
  return [[self class] imageNamed:@"ic_facebook"];
}

- (UIColor *)buttonBackgroundColor {
  return [UIColor colorWithRed:59.0f/255.0f green:89.0f/255.0f blue:152.0f/255.0f alpha:1.0f];
}

- (UIColor *)buttonTextColor {
  return [UIColor whiteColor];
}

- (void)signInWithEmail:(nullable NSString *)email
    presentingViewController:(nullable UIViewController *)presentingViewController
                  completion:(nullable FIRAuthProviderSignInCompletionBlock)completion {
  _pendingSignInCallback = completion;
  [_loginManager logInWithReadPermissions:_scopes
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
      [self completeSignInFlowWithAccessToken:result.token.tokenString
                                        error:nil];
    }
  }];
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
  [self callbackWithCredential:credential error:nil result:nil];
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
  FIRAuthProviderSignInCompletionBlock callback = _pendingSignInCallback;
  _pendingSignInCallback = nil;
  if (callback) {
    callback(credential, error, result);
  }
}

/** @fn callbackWithCredential:error:
    @brief Validates that Facebook SDK data was filled in Info.plist and creates Facebook login manager 
 */
- (void)configureProvider {
  NSBundle *bundle = [[self class] frameworkBundle];
  NSString *facebookAppId = [bundle objectForInfoDictionaryKey:kFacebookAppId];
  NSString *facebookDisplayName = [bundle objectForInfoDictionaryKey:kFacebookDisplayName];

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
