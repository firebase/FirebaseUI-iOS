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

#import <FirebaseAuthUI/FirebaseAuthUI.h>

#import "FirebaseAnonymousAuthUI/Sources/Public/FirebaseAnonymousAuthUI/FUIAnonymousAuth.h"

/** @var kTableName
    @brief The name of the strings table to search for localized strings.
 */
static NSString *const kTableName = @"FirebaseAnonymousAuthUI";

/** @var kBundleName
    @brief The name of the bundle to search for resources.
 */
#if SWIFT_PACKAGE
static NSString *const kBundleName = @"FirebaseUI_FirebaseAnonymousAuthUI";
#else
static NSString *const kBundleName = @"FirebaseAnonymousAuthUI";
#endif // SWIFT_PACKAGE

/** @var kSignInAsGuest
    @brief The string key for localized button text.
 */
static NSString *const kSignInAsGuest = @"SignInAsGuest";

NS_ASSUME_NONNULL_BEGIN

@implementation FUIAnonymousAuth {
  /** The @c FUIAuth instance of the application. */
  FUIAuth *_authUI;

  /** @var _presentingViewController
      @brief The presenting view controller for interactive sign-in.
   */
  UIViewController *_presentingViewController;
}

+ (NSBundle *)bundle {
  return [FUIAuthUtils bundleNamed:kBundleName
                 inFrameworkBundle:[NSBundle bundleForClass:[self class]]];
}

- (instancetype)init {
  return [self initWithAuthUI:[FUIAuth defaultAuthUI]];
}

- (instancetype)initWithAuthUI:(FUIAuth *)authUI {
  if (self = [super init]) {
    _authUI = authUI;
  }
  return self;
}

#pragma mark - FUIAuthProvider

- (nullable NSString *)providerID {
  return nil;
}

/** @fn accessToken:
    @brief Anonymous Auth token is matched by FirebaseUI User Access Token
 */
- (nullable NSString *)accessToken {
  return nil;
}

/** @fn idToken:
    @brief Anonymous Auth Token Secret is matched by FirebaseUI User Id Token
 */
- (nullable NSString *)idToken {
  return nil;
}

- (NSString *)shortName {
  return @"Anonymous";
}

- (NSString *)signInLabel {
  return FUILocalizedStringFromTableInBundle(kSignInAsGuest,
                                             kTableName,
                                             [FUIAnonymousAuth bundle]);
}

- (UIImage *)icon {
  return [FUIAuthUtils imageNamed:@"ic_anonymous" fromBundle:[FUIAnonymousAuth bundle]];
}

- (UIColor *)buttonBackgroundColor {
  return [UIColor colorWithRed:244.0f/255.0f green:180.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
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
  [_authUI.auth signInAnonymouslyWithCompletion:^(FIRAuthDataResult * _Nullable authResult,
                                                  NSError * _Nullable error) {
    NSDictionary *userInfo;
    if (authResult != nil) {
      userInfo = @{
        FUIAuthProviderSignInUserInfoKeyAuthDataResult: authResult,
      };
    }
    if (error) {
      [FUIAuthBaseViewController showAlertWithMessage:error.localizedDescription
                             presentingViewController:presentingViewController];
      if (completion) {
        completion(nil, error, nil, userInfo);
      }
      return;
    }
    if (completion) {
      completion(nil, error, nil, userInfo);
    }
  }];
}

- (void)signOut {
  FIRUser *user = _authUI.auth.currentUser;
  __weak UIViewController *weakController = _presentingViewController;
  if (user.isAnonymous) {
    [user deleteWithCompletion:^(NSError * _Nullable error) {
      if (error) {
        __strong UIViewController *presentingViewController = weakController;
        [FUIAuthBaseViewController showAlertWithMessage:error.localizedDescription
                               presentingViewController:presentingViewController];
        return;
      }
    }];
  }
}

- (BOOL)handleOpenURL:(NSURL *)URL sourceApplication:(nullable NSString *)sourceApplication {
  return NO;
}

@end

NS_ASSUME_NONNULL_END
