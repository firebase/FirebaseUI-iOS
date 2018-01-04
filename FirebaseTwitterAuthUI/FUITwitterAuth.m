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

#import "FUITwitterAuth.h"
#import <FirebaseAuth/FIRTwitterAuthProvider.h>
#import <FirebaseAuthUI/FUIAuthBaseViewController.h>
#import <FirebaseAuthUI/FUIAuthErrorUtils.h>
#import <TwitterCore/TwitterCore.h>
#import <TwitterKit/TWTRTwitter.h>
#import "FUIAuthBaseViewController_Internal.h"
#import "FUIAuthStrings.h"
#import "FUIAuthUtils.h"

/** @var kTableName
    @brief The name of the strings table to search for localized strings.
 */
static NSString *const kTableName = @"FirebaseTwitterAuthUI";

/** @var kBundleName
    @brief The name of the bundle to search for resources.
 */
static NSString *const kBundleName = @"FirebaseTwitterAuthUI";

/** @var kSignInWithTwitter
    @brief The string key for localized button text.
 */
static NSString *const kSignInWithTwitter = @"SignInWithTwitter";

@interface FUITwitterAuth()
- (Twitter *)getTwitterManager;
@end

@implementation FUITwitterAuth

#pragma mark - FUIAuthProvider

- (NSString *)providerID {
  return FIRTwitterAuthProviderID;
}

/** @fn accessToken:
    @brief Twitter Auth token is matched by FirebaseUI User Access Token
 */
- (NSString *)accessToken {
  return [self getTwitterManager].sessionStore.session.authToken;
}

/** @fn idToken:
    @brief Twitter Auth Token Secret is matched by FirebaseUI User Id Token
 */
- (NSString *)idToken {
  return [self getTwitterManager].sessionStore.session.authTokenSecret;
}

- (NSString *)shortName {
  return @"Twitter";
}

- (NSString *)signInLabel {
  return FUILocalizedStringFromTableInBundle(kSignInWithTwitter, kTableName, kBundleName);
}

- (UIImage *)icon {
  return [FUIAuthUtils imageNamed:@"ic_twitter" fromBundle:kBundleName];
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
  [self signInWithDefaultValue:email
      presentingViewController:presentingViewController
                    completion:completion];
}

- (void)signInWithDefaultValue:(nullable NSString *)defaultValue
      presentingViewController:(nullable UIViewController *)presentingViewController
                    completion:(nullable FIRAuthProviderSignInCompletionBlock)completion {

  [[self getTwitterManager] logInWithViewController:presentingViewController
                                         completion:^(TWTRSession *_Nullable session,
                                                      NSError *_Nullable error) {
    if (session) {
      FIRAuthCredential *credential =
          [FIRTwitterAuthProvider credentialWithToken:session.authToken
                                              secret:session.authTokenSecret];
      if (completion) {
        UIActivityIndicatorView *activityView =
            [FUIAuthBaseViewController addActivityIndicator:presentingViewController.view];
        [activityView startAnimating];
        FIRAuthResultCallback result = ^(FIRUser *_Nullable user,
                                        NSError *_Nullable error) {
          [activityView stopAnimating];
          [activityView removeFromSuperview];
        };
        completion(credential, nil, result);
      }
    } else {
      if (completion) {
        NSError *newError;
        if (error.code == TWTRLogInErrorCodeCancelled) {
          newError = [FUIAuthErrorUtils userCancelledSignInError];
        } else {
          newError = [FUIAuthErrorUtils providerErrorWithUnderlyingError:error
                                                              providerID:FIRTwitterAuthProviderID];
        }
        completion(nil, newError, nil);
      }
    }
  }];
}

- (void)signOut {
  NSString *twitterUserID = [TWTRAPIClient clientWithCurrentUser].userID;
  if (twitterUserID) {
    [[self getTwitterManager].sessionStore logOutUserID:twitterUserID];
  }
}

- (BOOL)handleOpenURL:(NSURL *)URL sourceApplication:(NSString *)sourceApplication {
  return [[self getTwitterManager] application:[UIApplication sharedApplication]
                                       openURL:URL options:@{}];
}

#pragma mark - Private methods

- (Twitter *)getTwitterManager {
  return [Twitter sharedInstance];
}

@end
