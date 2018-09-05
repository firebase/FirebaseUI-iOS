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

#import "FUIAuth_Internal.h"

#import <objc/runtime.h>

#import <FirebaseCore/FIRApp.h>
#import <FirebaseCore/FIROptions.h>
#import <FirebaseAuth/FIRAuth.h>
#import <FirebaseAuth/FirebaseAuth.h>
#import "FUIAuthBaseViewController_Internal.h"
#import "FUIAuthErrors.h"
#import "FUIAuthErrorUtils.h"
#import "FUIAuthPickerViewController.h"
#import "FUIAuthStrings.h"
#import "FUIEmailEntryViewController.h"
#import "FUIPasswordSignInViewController_Internal.h"
#import "FUIPasswordVerificationViewController.h"
#import "FUIPasswordSignInViewController.h"

/** @typedef EmailHintSignInCallback
    @brief The type of block invoked when an emailHint sign-in event completes.

    @param authResult Optionally; Result of sign-in request containing both the user and
       the additional user info associated with the user.
    @param error Optionally; the error which occurred - or nil if the request was successful.
    @param credential Optionally; The credential used to sign-in.
 */
typedef void (^EmailHintSignInCallback)(FIRAuthDataResult *_Nullable authResult,
                                        NSError *_Nullable error,
                                        FIRAuthCredential *_Nullable credential);

/** @var kAppNameCodingKey
    @brief The key used to encode the app Name for NSCoding.
 */
static NSString *const kAppNameCodingKey = @"appName";

/** @var kAuthAssociationKey
    @brief The address of this variable is used as the key for associating FUIAuth instances with
        root FIRAuth objects.
 */
static const char kAuthAssociationKey;

/** @var kErrorUserInfoEmailKey
    @brief The key for the email address in the userInfo dictionary of a sign in error.
 */
static NSString *const kErrorUserInfoEmailKey = @"FIRAuthErrorUserInfoEmailKey";

/** @var kFirebaseAuthUIFrameworkMarker
    @brief The marker in the HTTP header that indicates the presence of Firebase Auth UI.
 */
static NSString *const kFirebaseAuthUIFrameworkMarker = @"FirebaseUI-iOS";

/** @category FIRAuth(InternalInterface)
    @brief Redeclares the internal interface not publicly exposed in FIRAuth.
 */
@interface FIRAuth (InternalInterface)

/** @property additionalFrameworkMarker
    @brief Additional framework marker that will be added as part of the header of every request.
 */
@property(nonatomic, copy, nullable) NSString *additionalFrameworkMarker;

@end

@interface FUIAuth ()

/** @fn initWithAuth:
    @brief auth The @c FIRAuth to associate the @c FUIAuth instance with.
 */
- (instancetype)initWithAuth:(FIRAuth *)auth NS_DESIGNATED_INITIALIZER;

@end

@implementation FUIAuth

+ (nullable FUIAuth *)defaultAuthUI {
  FIRAuth *defaultAuth = [FIRAuth auth];
  if (!defaultAuth) {
    return nil;
  }
  return [self authUIWithAuth:defaultAuth];
}

+ (nullable FUIAuth *)authUIWithAuth:(FIRAuth *)auth {
  NSParameterAssert(auth != nil);
  @synchronized (self) {
    // Let the FIRAuth instance retain the FUIAuth instance.
    FUIAuth *authUI = objc_getAssociatedObject(auth, &kAuthAssociationKey);
    if (!authUI) {
      authUI = [[FUIAuth alloc] initWithAuth:auth];
      objc_setAssociatedObject(auth, &kAuthAssociationKey, authUI,
          OBJC_ASSOCIATION_RETAIN_NONATOMIC);
      if ([auth respondsToSelector:@selector(setAdditionalFrameworkMarker:)]) {
        auth.additionalFrameworkMarker = kFirebaseAuthUIFrameworkMarker;
      }
      // Update auth with the actual language used in the app.
      // If localization is not provided by developer, the first localization available,
      // ordered by the user's preferred order, is used.
      auth.languageCode = [NSBundle mainBundle].preferredLocalizations.firstObject;
    }
    return authUI;
  }
}

- (instancetype)initWithAuth:(FIRAuth *)auth {
  self = [super init];
  if (self) {
    _allowNewEmailAccounts = YES;
    _auth = auth;
  }
  return self;
}

- (BOOL)handleOpenURL:(NSURL *)URL
    sourceApplication:(NSString *)sourceApplication {
  // Complete IDP-based sign-in flow.
  for (id<FUIAuthProvider> provider in _providers) {
    if ([provider handleOpenURL:URL sourceApplication:sourceApplication]) {
      return YES;
    }
  }
  // The URL was not meant for us.
  return NO;
}

- (UINavigationController *)authViewController {
  UIViewController *controller;

  if (self.providers.count == 0 && !self.isSignInWithEmailHidden) {
      if (self.allowNewEmailAccounts) {
        if ([self.delegate respondsToSelector:@selector(emailEntryViewControllerForAuthUI:)]) {
          controller = [self.delegate emailEntryViewControllerForAuthUI:self];
        } else {
          controller = [[FUIEmailEntryViewController alloc] initWithAuthUI:self];
        }
      }
      else {
        if ([self.delegate respondsToSelector:@selector(emailEntryViewControllerForAuthUI:)]) {
            controller = [self.delegate passwordSignInViewControllerForAuthUI:self email:@""];
        } else {
            controller = [[FUIPasswordSignInViewController alloc] initWithAuthUI:self email:nil];
        }
      }
  } else if ([self.delegate respondsToSelector:@selector(authPickerViewControllerForAuthUI:)]) {
    controller = [self.delegate authPickerViewControllerForAuthUI:self];
  } else {
    controller = [[FUIAuthPickerViewController alloc] initWithAuthUI:self];
  }
  return [[UINavigationController alloc] initWithRootViewController:controller];
}

- (BOOL)signOutWithError:(NSError *_Nullable *_Nullable)error {
  // sign out from Firebase
  BOOL success = [self.auth signOut:error];
  if (success) {
    // sign out from all providers (wipes provider tokens too)
    for (id<FUIAuthProvider> provider in _providers) {
      [provider signOut];
    }
  }

  return success;
}

- (void)signInWithProviderUI:(id<FUIAuthProvider>)providerUI
    presentingViewController:(FUIAuthBaseViewController *)presentingViewController
                defaultValue:(nullable NSString *)defaultValue {

  // Sign out first to make sure sign in starts with a clean state.
  [providerUI signOut];
  [providerUI signInWithDefaultValue:defaultValue
     presentingViewController:presentingViewController
                   completion:^(FIRAuthCredential *_Nullable credential,
                                NSError *_Nullable error,
                                _Nullable FIRAuthResultCallback result) {
    BOOL isAuthPickerShown =
        [presentingViewController isKindOfClass:[FUIAuthPickerViewController class]];
    if (error) {
      if (!isAuthPickerShown || error.code != FUIAuthErrorCodeUserCancelledSignIn) {
        [self invokeResultCallbackWithAuthDataResult:nil error:error];
      }
      if (result) {
        result(nil, error);
      }
      return;
    }

    // Test if it's an anonymous login.
    if (self.auth.currentUser.isAnonymous && !credential) {
      if (result) {
        result(self.auth.currentUser, nil);
      };
      // Hide Auth Picker Controller which was presented modally.
      if (isAuthPickerShown && presentingViewController.presentingViewController) {
        [presentingViewController dismissViewControllerAnimated:YES completion:nil];
      }
      return;
    }

    // Check for the presence of an anonymous user and whether automatic upgrade is enabled.
    if (self.auth.currentUser.isAnonymous && self.shouldAutoUpgradeAnonymousUsers) {
      [self autoUpgradeAccountWithProviderUI:providerUI
                    presentingViewController:presentingViewController
                                  credential:credential
                              resultCallback:result];
    } else {
      [self.auth signInAndRetrieveDataWithCredential:credential
                                          completion:^(FIRAuthDataResult *_Nullable authResult,
                                                       NSError *_Nullable error) {
        if (error && error.code == FIRAuthErrorCodeAccountExistsWithDifferentCredential) {
          NSString *email = error.userInfo[kErrorUserInfoEmailKey];
          [self handleAccountLinkingForEmail:email
                               newCredential:credential
                    presentingViewController:presentingViewController
                                signInResult:result];
          return;
        }
        if (error) {
          if (result) {
            result(nil, error);
          }
          [self invokeResultCallbackWithAuthDataResult:nil error:error];
          return;
        }
        [self completeSignInWithResult:authResult
                                 error:nil
              presentingViewController:presentingViewController
                              callback:result];
      }];
    }
  }];
}

- (void)autoUpgradeAccountWithProviderUI:(id<FUIAuthProvider>)providerUI
                presentingViewController:(FUIAuthBaseViewController *)presentingViewController
                              credential:(nullable FIRAuthCredential *)credential
                          resultCallback:(nullable FIRAuthResultCallback)callback {
  [self.auth.currentUser
      linkAndRetrieveDataWithCredential:credential
                             completion:^(FIRAuthDataResult *_Nullable authResult,
                                          NSError * _Nullable error) {
    if (error) {
      // Check for "credential in use" conflict error and handle appropriately.
      if (error.code == FIRAuthErrorCodeCredentialAlreadyInUse) {
        FIRAuthCredential *newCredential = credential;
        // Check for and handle special case for Phone Auth Provider.
        if (providerUI.providerID == FIRPhoneAuthProviderID) {
          // Obtain temporary Phone Auth credential.
          newCredential = error.userInfo[FIRAuthUpdatedCredentialKey];
        }
        NSDictionary *userInfo = @{
          FUIAuthCredentialKey : newCredential,
        };
        NSError *mergeError = [FUIAuthErrorUtils mergeConflictErrorWithUserInfo:userInfo
                                                                underlyingError:error];
        [self completeSignInWithResult:authResult
                                 error:mergeError
              presentingViewController:presentingViewController
                              callback:callback];
      } else if (error.code == FIRAuthErrorCodeEmailAlreadyInUse) {
        if ([providerUI respondsToSelector:@selector(email)]) {
          // Link federated providers
          [self signInWithEmailHint:[providerUI email]
           presentingViewController:presentingViewController
                      originalError:error
                         completion:^(FIRAuthDataResult *_Nullable authResult,
                                      NSError *_Nullable emailError,
                                      FIRAuthCredential *_Nullable existingCredential) {
            if (emailError) {
              [self completeSignInWithResult:nil
                                       error:emailError
                    presentingViewController:presentingViewController
                                    callback:callback];
              return;
            }

            if (![authResult.user.email isEqualToString:[providerUI email]]
                && credential) {
              NSDictionary *userInfo = @{
                FUIAuthCredentialKey : credential,
              };
              NSError *mergeError = [FUIAuthErrorUtils mergeConflictErrorWithUserInfo:userInfo
                                                                      underlyingError:error];
              [self completeSignInWithResult:authResult
                                       error:mergeError
                    presentingViewController:presentingViewController
                                    callback:callback];
              return;
            }

            [authResult.user linkAndRetrieveDataWithCredential:credential
                                                    completion:^(FIRAuthDataResult *authResult,
                                                                 NSError *linkError) {
              if (linkError) {
                [self completeSignInWithResult:nil
                                         error:linkError
                      presentingViewController:presentingViewController
                                      callback:callback];
                return;
              }
              FIRAuthCredential *newCredential = credential;
              NSDictionary *userInfo = @{
                FUIAuthCredentialKey : newCredential,
              };
              NSError *mergeError = [FUIAuthErrorUtils mergeConflictErrorWithUserInfo:userInfo
                                                                      underlyingError:error];
              [self completeSignInWithResult:authResult
                                       error:mergeError
                    presentingViewController:presentingViewController
                                    callback:callback];
            }];
          }];
        }
      } else {
        BOOL isAuthPickerShown =
            [presentingViewController isKindOfClass:[FUIAuthPickerViewController class]];
        if (!isAuthPickerShown || error.code != FUIAuthErrorCodeUserCancelledSignIn) {
          [self invokeResultCallbackWithAuthDataResult:nil error:error];
        }
        if (callback) {
          callback(nil, error);
        }
      }
    } else {
      [self completeSignInWithResult:authResult
                               error:nil
            presentingViewController:presentingViewController
                            callback:callback];
    }
  }];
}

- (void)completeSignInWithResult:(nullable FIRAuthDataResult *)authResult
                           error:(nullable NSError *)error
        presentingViewController:(FUIAuthBaseViewController *)presentingViewController
                        callback:(nullable FIRAuthResultCallback)callback {
  BOOL isAuthPickerShown =
      [presentingViewController isKindOfClass:[FUIAuthPickerViewController class]];
  if (callback) {
    callback(authResult.user, error);
  }
  // Hide Auth Picker Controller which was presented modally.
  if (isAuthPickerShown && presentingViewController.presentingViewController) {
    [presentingViewController dismissViewControllerAnimated:YES completion:^{
      [self invokeResultCallbackWithAuthDataResult:authResult error:error];
    }];
  } else {
    [self invokeResultCallbackWithAuthDataResult:authResult error:error];
  }
}

- (void)signInWithEmailHint:(NSString *)emailHint
   presentingViewController:(FUIAuthBaseViewController *)presentingViewController
              originalError:(NSError *)originalError
                 completion:(EmailHintSignInCallback)completion {
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

  [self.auth fetchProvidersForEmail:emailHint completion:^(NSArray<NSString *> *_Nullable providers,
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
          FUIAuth *authUI = [[FUIAuth alloc]initWithAuth:tempAuth];
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
        for (id<FUIAuthProvider> provider in self.providers) {
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
                                                   FIRAuthResultCallback  _Nullable result) {
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

- (void)handleAccountLinkingForEmail:(NSString *)email
                       newCredential:(FIRAuthCredential *)newCredential
            presentingViewController:(UIViewController *)presentingViewController
                        signInResult:(_Nullable FIRAuthResultCallback)result {

  [self.auth fetchProvidersForEmail:email
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
          [self invokeResultCallbackWithAuthDataResult:nil error:error];
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
      if ([self.delegate respondsToSelector:
              @selector(passwordVerificationViewControllerForAuthUI:email:newCredential:)]) {

        passwordController = [self.delegate passwordVerificationViewControllerForAuthUI:self
                                                                          email:email
                                                                  newCredential:newCredential];
      } else {
        passwordController =
            [[FUIPasswordVerificationViewController alloc] initWithAuthUI:self
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
    id<FUIAuthProvider> bestProvider = [self providerWithID:bestProviderID];
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
                                      _Nullable FIRAuthResultCallback result) {
        if (error) {
          if (error.code == FUIAuthErrorCodeUserCancelledSignIn) {
            // User cancelled sign in, Do nothing.
            if (result) {
              result(nil, error);
            }
            return;
          }
          [self invokeResultCallbackWithAuthDataResult:nil error:error];
          return;
        }

        [self.auth signInAndRetrieveDataWithCredential:credential
                                            completion:^(FIRAuthDataResult*_Nullable authResult,
                                                         NSError *_Nullable error) {
          if (error) {
            [self invokeResultCallbackWithAuthDataResult:nil error:error];
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
              [self invokeResultCallbackWithAuthDataResult:authResult error:nil];
            }];
          }];
        }];
      }];
    } cancelHandler:^{
      [self signOutWithError:nil];
    }];
  }];
}

#pragma mark - Internal Methods

- (void)invokeResultCallbackWithAuthDataResult:(nullable FIRAuthDataResult *)authDataResult
                                         error:(nullable NSError *)error {
  dispatch_async(dispatch_get_main_queue(), ^{
    if ([self.delegate respondsToSelector:@selector(authUI:didSignInWithAuthDataResult:error:)]) {
      [self.delegate authUI:self didSignInWithAuthDataResult:authDataResult error:error];
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    if ([self.delegate respondsToSelector:@selector(authUI:didSignInWithUser:error:)]) {
      [self.delegate authUI:self didSignInWithUser:authDataResult.user error:error];
    }
#pragma clang diagnostic pop
  });
}

- (void)invokeOperationCallback:(FUIAccountSettingsOperationType)operation
                          error:(NSError *_Nullable)error {
  dispatch_async(dispatch_get_main_queue(), ^{
    if ([self.delegate respondsToSelector:@selector(authUI:didFinishOperation:error:)]) {
      [self.delegate authUI:self didFinishOperation:operation error:error];
    }
  });
}

- (nullable id<FUIAuthProvider>)providerWithID:(NSString *)providerID {
  NSArray<id<FUIAuthProvider>> *providers = self.providers;
  for (id<FUIAuthProvider> provider in providers) {
    if ([provider.providerID isEqual:providerID]) {
      return provider;
    }
  }
  return nil;
}

#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding {
  return YES;
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
  NSString *appName = [aDecoder decodeObjectOfClass:[NSString class] forKey:kAppNameCodingKey];
  if (!appName) {
    return nil;
  }
  FIRApp *app = [FIRApp appNamed:appName];
  if (!app) {
    return nil;
  }
  FIRAuth *auth = [FIRAuth authWithApp:app];
  if (!auth) {
    return nil;
  }
  return [self initWithAuth:auth];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [aCoder encodeObject:_auth.app.name forKey:kAppNameCodingKey];
}

@end
