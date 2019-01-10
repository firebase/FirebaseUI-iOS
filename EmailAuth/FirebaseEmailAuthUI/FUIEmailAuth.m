//
//  Copyright (c) 2018 Google Inc.
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

#import "FUIEmailAuth.h"

#import <FirebaseCore/FIRApp.h>
#import <FirebaseCore/FIROptions.h>
#import <FirebaseAuth/FIRAuth.h>
#import <FirebaseAuth/FirebaseAuth.h>
#import "FUIAuth.h"
#import "FUIAuth_Internal.h"
#import "FUIAuthStrings.h"
#import "FUIAuthUtils.h"
#import "FUIAuthErrorUtils.h"
#import "FUIEmailAuthStrings.h"
#import "FUIEmailEntryViewController.h"
#import "FUIPasswordSignInViewController_Internal.h"
#import "FUIPasswordVerificationViewController.h"
#import "FUIPasswordSignInViewController.h"
#import "FUIAuthBaseViewController.h"
#import "FUIAuthBaseViewController_Internal.h"

/** @var kErrorUserInfoEmailKey
    @brief The key for the email address in the userinfo dictionary of a sign in error.
 */
static NSString *const kErrorUserInfoEmailKey = @"FIRAuthErrorUserInfoEmailKey";

/** @var kEmailButtonAccessibilityID
    @brief The Accessibility Identifier for the @c email sign in button.
 */
static NSString *const kEmailButtonAccessibilityID = @"EmailButtonAccessibilityID";

@interface FUIEmailAuth () <FUIEmailAuthProvider>
/** @property authUI.
    @brief The @c FUIAuth instance of the application.
 */
@property(nonatomic, strong, readonly) FUIAuth *authUI;

/** @property pendingSignInCallback.
    @brief The callback which should be invoked when the sign in flow completes (or is cancelled.)
 */
@property(nonatomic, copy, readwrite) FUIAuthProviderSignInCompletionBlock pendingSignInCallback;

/** @property presentingViewController
    @brief The presenting view controller for interactive sign-in.
 */
@property(nonatomic, strong) UIViewController *presentingViewController;

@end

@implementation FUIEmailAuth

- (instancetype)init {
  return [self initAuthAuthUI:[FUIAuth defaultAuthUI]
                 signInMethod:FIREmailPasswordAuthSignInMethod
              forceSameDevice:NO
        allowNewEmailAccounts:YES
            actionCodeSetting:[[FIRActionCodeSettings alloc] init]];
}


- (instancetype)initAuthAuthUI:(FUIAuth *)authUI
                  signInMethod:(NSString *)signInMethod
               forceSameDevice:(BOOL)forceSameDevice
         allowNewEmailAccounts:(BOOL)allowNewEmailAccounts
             actionCodeSetting:(FIRActionCodeSettings *)actionCodeSettings {
  self = [super init];
  if (self) {
    _authUI = authUI;
    _authUI.emailAuthProvider = self;
    _signInMethod = signInMethod;
    _forceSameDevice = forceSameDevice;
    _actionCodeSettings = actionCodeSettings;
    _allowNewEmailAccounts = allowNewEmailAccounts;
  }
  return self;
}


#pragma mark - FUIAuthProvider

- (nullable NSString *)providerID {
  return FIREmailAuthProviderID;
}

/** @fn accessToken:
    @brief Email Auth token is matched by FirebaseUI User Access Token
 */
- (nullable NSString *)accessToken {
  return nil;
}

/** @fn idToken:
    @brief Email Auth Token Secret is matched by FirebaseUI User Id Token
 */
- (nullable NSString *)idToken {
  return nil;
}

- (NSString *)shortName {
  return @"Email";
}

- (NSString *)signInLabel {
  return FUILocalizedString(kStr_SignInWithEmail);
}

- (UIImage *)icon {
  return [FUIAuthUtils imageNamed:@"ic_email" fromBundleNameOrNil:FUIEmailAuthBundleName];
}

- (UIColor *)buttonBackgroundColor {
  return [UIColor colorWithRed:208.f/255.f green:2.f/255.f blue:27.f/255.f alpha:1.0];
}

- (UIColor *)buttonTextColor {
  return [UIColor whiteColor];
}

- (void)signInWithPresentingViewController:(UIViewController *)presentingViewController {
  [self signInWithPresentingViewController:presentingViewController
                                     email:nil];
}
   
- (void)signInWithPresentingViewController:(UIViewController *)presentingViewController
                                     email:(nullable NSString *)email {
  [self.authUI signInWithProviderUI:self
           presentingViewController:presentingViewController
                       defaultValue:email];
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
  self.presentingViewController = presentingViewController;

  self.pendingSignInCallback = completion;
  id<FUIAuthDelegate> delegate = self.authUI.delegate;
  UIViewController *controller;
  if (self.allowNewEmailAccounts) {
    if ([delegate respondsToSelector:@selector(emailEntryViewControllerForAuthUI:)]) {
      controller = [delegate emailEntryViewControllerForAuthUI:self.authUI];
    } else {
      controller = [[FUIEmailEntryViewController alloc] initWithAuthUI:self.authUI];
    }
  } else {
    if ([delegate respondsToSelector:@selector(emailEntryViewControllerForAuthUI:)]) {
      controller = [delegate passwordSignInViewControllerForAuthUI:self.authUI email:@""];
    } else {
      controller = [[FUIPasswordSignInViewController alloc] initWithAuthUI:self.authUI email:nil];
    }
  }

  if ([presentingViewController isKindOfClass:[FUIAuthBaseViewController class]]) {
    FUIAuthBaseViewController *authController =
        (FUIAuthBaseViewController *)presentingViewController;
    [authController pushViewController:controller];
  } else {
    UINavigationController *navigationController =
        [[UINavigationController alloc] initWithRootViewController:controller];
    [presentingViewController presentViewController:navigationController
                                           animated:YES
                                         completion:nil];
  }
}

- (void)signOut {
}

- (BOOL)handleOpenURL:(NSURL *)URL sourceApplication:(nullable NSString *)sourceApplication {
  return NO;
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
  FUIAuthProviderSignInCompletionBlock callback = self.pendingSignInCallback;
  self.pendingSignInCallback = nil;
  if (callback) {
    callback(credential, error, result, nil);
  }
}

#pragma mark - FUIEmailAuthProvider

- (void)signInWithEmailHint:(NSString *)emailHint
   presentingViewController:(FUIAuthBaseViewController *)presentingViewController
              originalError:(NSError *)originalError
                 completion:(FUIEmailHintSignInCallback)completion {
  NSString *kTempApp = @"tempApp";
  FIROptions *options = [FIROptions defaultOptions];
  // Create an new app instance in order to create a new auth instance.
  if (![FIRApp appNamed:kTempApp]) {
    [FIRApp configureWithName:kTempApp options:options];
  }
  FIRApp *tempApp = [FIRApp appNamed:kTempApp];
  // Create a new auth instance in order to perform a successful sign-in without losing the
  // currently signed in user on the default auth instance.
  FIRAuth *tempAuth = [FIRAuth authWithApp:tempApp];

  [self.authUI.auth fetchProvidersForEmail:emailHint
                                completion:^(NSArray<NSString *> *_Nullable providers,
                                             NSError *_Nullable error) {
    if (error) {
      if (completion) {
        completion(nil, error, nil);
      }
      return;
    }
    NSString *existingFederatedProviderID = [self authProviderFromProviders:providers];
    // Set of providers which can be auto-linked.
    NSSet *supportedProviders =
        [NSSet setWithObjects:FIRGoogleAuthProviderID,
                              FIRFacebookAuthProviderID,
                              FIREmailAuthProviderID,
                              nil];
    if ([supportedProviders containsObject:existingFederatedProviderID]) {
      if ([existingFederatedProviderID isEqualToString:FIREmailAuthProviderID]) {

        [FUIAuthBaseViewController showSignInAlertWithEmail:emailHint
                                          providerShortName:@"Email/Password"
                                        providerSignInLabel:@"Sign in with Email/Password"
                                   presentingViewController:presentingViewController
                                              signinHandler:^{
          FUIAuth *authUI = [FUIAuth authUIWithAuth:tempAuth];
          // Email password sign-in
          FUIPasswordSignInViewController *controller =
              [[FUIPasswordSignInViewController alloc] initWithAuthUI:authUI email:emailHint];
          controller.onDismissCallback = ^(FIRAuthDataResult *result, NSError *error) {
            if (completion) {
              completion(result, error, nil);
            }
          };
          [presentingViewController pushViewController:controller];
        }
                                              cancelHandler:^{
          if (completion) {
            completion(nil, originalError, nil);
          }
        }];
      } else { // Federated sign-in case.
        id<FUIAuthProvider> authProviderUI;
        // Retrieve the FUIAuthProvider instance from FUIAuth for the existing provider ID.
        for (id<FUIAuthProvider> provider in self.authUI.providers) {
          if ([provider.providerID isEqualToString:existingFederatedProviderID]) {
            authProviderUI = provider;
            break;
          }
        }

        [FUIAuthBaseViewController showSignInAlertWithEmail:emailHint
                                                   provider:authProviderUI
                                   presentingViewController:presentingViewController
                                              signinHandler:^{
          [authProviderUI signOut];
          [authProviderUI signInWithDefaultValue:emailHint
                        presentingViewController:presentingViewController
                                      completion:^(FIRAuthCredential *_Nullable credential,
                                                   NSError *_Nullable error,
                                                   FIRAuthResultCallback  _Nullable result,
                                                   NSDictionary *_Nullable userInfo) {
            if (error) {
              if (completion) {
                completion(nil, error, nil);
              }
              return;
            }

            [tempAuth signInAndRetrieveDataWithCredential:credential
                                               completion:^(FIRAuthDataResult *_Nullable authResult,
                                                            NSError *_Nullable error) {
              if (error) {
                if (completion) {
                  completion(nil, error, nil);
                }
              }

              // Handle potential email mismatch.
              if (![emailHint isEqualToString:authResult.user.email]) {
                NSString *signedInEmail = authResult.user.email;
                NSString *title =
                    [NSString stringWithFormat:@"Continue sign in with %@?", signedInEmail];
                NSString *message =
                    [NSString stringWithFormat:@"You originally wanted to sign in with %@",
                    emailHint];
                [FUIAuthBaseViewController showAlertWithTitle:title
                                                      message:message
                                                  actionTitle:@"Continue"
                                     presentingViewController:presentingViewController
                                                actionHandler:^{
                  if (completion) {
                    completion(authResult, nil, credential);
                  }
                }
                                                cancelHandler:^{
                  if (completion) {
                    completion(nil, error, credential);
                  }
                }];
              }
              if (completion) {
                completion(authResult, error, credential);
              }
            }];
          }];
        }
                                              cancelHandler:^{
          if (completion) {
            completion(nil, originalError, nil);
          }
        }];
      }
    }
  }];
}

- (void)handleAccountLinkingForEmail:(NSString *)email
                       newCredential:(FIRAuthCredential *)newCredential
            presentingViewController:(UIViewController *)presentingViewController
                        signInResult:(_Nullable FIRAuthResultCallback)result {
  id<FUIAuthDelegate> delegate = self.authUI.delegate;
  [self.authUI.auth fetchProvidersForEmail:email
                         completion:^(NSArray<NSString *> *_Nullable providers,
                                      NSError *_Nullable error) {
    if (result) {
      result(nil, error);
    }

    if (error) {
      if (error.code == FIRAuthErrorCodeInvalidEmail) {
        // This should never happen because the email address comes from the backend.
        [FUIAuthBaseViewController showAlertWithMessage:FUILocalizedString(kStr_InvalidEmailError)
                               presentingViewController:presentingViewController];
      } else {
        [presentingViewController dismissViewControllerAnimated:YES completion:^{
          [self.authUI invokeResultCallbackWithAuthDataResult:nil URL:nil error:error];
        }];
      }
      return;
    }
    if (!providers.count) {
      // This should never happen because the user must be registered.
      [FUIAuthBaseViewController showAlertWithMessage:
          FUILocalizedString(kStr_CannotAuthenticateError)
                             presentingViewController:presentingViewController];
      return;
    }
    NSString *bestProviderID = providers[0];
    if ([bestProviderID isEqual:FIREmailAuthProviderID]) {
      // Password verification.
      UIViewController *passwordController;
      if ([delegate respondsToSelector:
              @selector(passwordVerificationViewControllerForAuthUI:email:newCredential:)]) {

        passwordController = [delegate passwordVerificationViewControllerForAuthUI:self.authUI
                                                                          email:email
                                                                  newCredential:newCredential];
      } else {
        passwordController =
            [[FUIPasswordVerificationViewController alloc] initWithAuthUI:self.authUI
                                                                    email:email
                                                            newCredential:newCredential];
      }
      if (presentingViewController.navigationController) {
        [FUIAuthBaseViewController pushViewController:passwordController
                                 navigationController:
            presentingViewController.navigationController];
      }
      return;
    }
    id<FUIAuthProvider> bestProvider = [self.authUI providerWithID:bestProviderID];
    if (!bestProvider) {
      // Unsupported provider.
      [FUIAuthBaseViewController showAlertWithMessage:
          FUILocalizedString(kStr_CannotAuthenticateError)
                             presentingViewController:presentingViewController];
      return;
    }

    [FUIAuthBaseViewController showSignInAlertWithEmail:email
                                               provider:bestProvider
                               presentingViewController:presentingViewController
                                          signinHandler:^{
      // Sign out first to make sure sign in starts with a clean state.
      [bestProvider signOut];
      [bestProvider signInWithDefaultValue:email
           presentingViewController:presentingViewController
                         completion:^(FIRAuthCredential *_Nullable credential,
                                      NSError *_Nullable error,
                                      _Nullable FIRAuthResultCallback result,
                                      NSDictionary *_Nullable userInfo) {
        if (error) {
          if (error.code == FUIAuthErrorCodeUserCancelledSignIn) {
            // User cancelled sign in, Do nothing.
            if (result) {
              result(nil, error);
            }
            return;
          }
          [self.authUI invokeResultCallbackWithAuthDataResult:nil URL:nil error:error];
          return;
        }

        [self.authUI.auth signInAndRetrieveDataWithCredential:credential
                                            completion:^(FIRAuthDataResult*_Nullable authResult,
                                                         NSError *_Nullable error) {
          if (error) {
            [self.authUI invokeResultCallbackWithAuthDataResult:nil URL:nil error:error];
            if (result) {
              result(nil, error);
            }
            return;
          }

          FIRUser *user = authResult.user;
          [user linkAndRetrieveDataWithCredential:newCredential
                                       completion:^(FIRAuthDataResult *_Nullable authResult,
                                                    NSError *_Nullable error) {
            if (result) {
              result(authResult.user, error);
            }
            // Ignore any error (most likely caused by email mismatch) and treat the user as
            // successfully signed in.
            [presentingViewController dismissViewControllerAnimated:YES completion:^{
              [self.authUI invokeResultCallbackWithAuthDataResult:authResult URL:nil error:nil];
            }];
          }];
        }];
      }];
    } cancelHandler:^{
      [self.authUI signOutWithError:nil];
    }];
  }];
}

#pragma mark - Private


- (nullable NSString *)authProviderFromProviders:(NSArray <NSString *> *) providers {
  NSSet *providerSet =
  [NSSet setWithArray:@[ FIRFacebookAuthProviderID,
                         FIRGoogleAuthProviderID,
                         FIREmailAuthProviderID ]];
  for (NSString *provider in providers) {
    if ( [providerSet containsObject:provider]) {
      return provider;
    }
  }
  return nil;
}

@end
