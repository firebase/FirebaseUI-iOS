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

#import "FirebaseAuthUI/Sources/Public/FirebaseAuthUI/FUIAuth_Internal.h"

#import <objc/runtime.h>

#import <FirebaseCore/FIRApp.h>
#import <FirebaseCore/FIROptions.h>
#import <FirebaseAuth/FIRAuth.h>
#import <FirebaseAuth/FirebaseAuth.h>
#import "FirebaseAuthUI/Sources/Public/FirebaseAuthUI/FUIAuthBaseViewController_Internal.h"
#import "FirebaseAuthUI/Sources/Public/FirebaseAuthUI/FUIAuthErrors.h"
#import "FirebaseAuthUI/Sources/Public/FirebaseAuthUI/FUIAuthErrorUtils.h"
#import "FirebaseAuthUI/Sources/Public/FirebaseAuthUI/FUIAuthPickerViewController.h"
#import "FirebaseAuthUI/Sources/Public/FirebaseAuthUI/FUIAuthStrings.h"

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

@implementation FUIAuth {
  id<FUIEmailAuthProvider> __weak _emailAuthProvider;
}

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
    _auth = auth;
    _interactiveDismissEnabled = YES;
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
  static UINavigationController *authViewController;

  UIViewController *controller;
  if ([self.delegate respondsToSelector:@selector(authPickerViewControllerForAuthUI:)]) {
    controller = [self.delegate authPickerViewControllerForAuthUI:self];
  } else {
    controller = [[FUIAuthPickerViewController alloc] initWithAuthUI:self];
  }
  authViewController = [[UINavigationController alloc] initWithRootViewController:controller];

  return authViewController;
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
                                _Nullable FIRAuthResultCallback result,
                                NSDictionary *_Nullable userInfo) {
    BOOL isAuthPickerShown =
        [presentingViewController isKindOfClass:[FUIAuthPickerViewController class]];
    if (error) {
      if (!isAuthPickerShown || error.code != FUIAuthErrorCodeUserCancelledSignIn) {
        [self invokeResultCallbackWithAuthDataResult:nil URL:nil error:error];
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
      }
      // Hide Auth Picker Controller which was presented modally.
      if (isAuthPickerShown && presentingViewController.presentingViewController) {
        [presentingViewController dismissViewControllerAnimated:YES completion:nil];
      }
      FIRAuthDataResult *authResult = userInfo[FUIAuthProviderSignInUserInfoKeyAuthDataResult];
      if (authResult != nil) {
        [self invokeResultCallbackWithAuthDataResult:authResult URL:nil error:error];
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
      [self.auth signInWithCredential:credential
                           completion:^(FIRAuthDataResult *_Nullable authResult,
                                        NSError *_Nullable error) {
        if (self.emailAuthProvider && error 
            && error.code == FIRAuthErrorCodeAccountExistsWithDifferentCredential) {
          NSString *email = error.userInfo[kErrorUserInfoEmailKey];
          [self.emailAuthProvider handleAccountLinkingForEmail:email
                                                 newCredential:credential
                                      presentingViewController:presentingViewController
                                                  signInResult:result];

          return;
        }
        if (error) {
          if (result) {
            result(nil, error);
          }
          [self invokeResultCallbackWithAuthDataResult:nil URL:nil error:error];
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
      linkWithCredential:credential
              completion:^(FIRAuthDataResult *_Nullable authResult,
                           NSError * _Nullable error) {
    if (error) {
      // Check for "credential in use" conflict error and handle appropriately.
      if (error.code == FIRAuthErrorCodeCredentialAlreadyInUse) {
        FIRAuthCredential *newCredential = error.userInfo[FIRAuthErrorUserInfoUpdatedCredentialKey];
        NSDictionary *userInfo = @{ };
        if (newCredential) {
          userInfo = @{ FUIAuthCredentialKey : newCredential };
        }
        NSError *mergeError = [FUIAuthErrorUtils mergeConflictErrorWithUserInfo:userInfo
                                                                underlyingError:error];
        [self completeSignInWithResult:authResult
                                 error:mergeError
              presentingViewController:presentingViewController
                              callback:callback];
      } else if (error.code == FIRAuthErrorCodeEmailAlreadyInUse) {
        if ([providerUI respondsToSelector:@selector(email)]) {
          // Link federated providers
          [self.emailAuthProvider signInWithEmailHint:[providerUI email]
                             presentingViewController:presentingViewController
                                        originalError:error
                                           completion:
           ^(FIRAuthDataResult *_Nullable authResult,
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
                && credential != nil) {
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

            [authResult.user linkWithCredential:credential
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
        [self completeSignInWithResult:nil
                                 error:error
              presentingViewController:presentingViewController
                              callback:callback];
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
      [self invokeResultCallbackWithAuthDataResult:authResult URL:nil error:error];
    }];
  } else {
    [self invokeResultCallbackWithAuthDataResult:authResult URL:nil error:error];
  }
}

- (void)useEmulatorWithHost:(NSString *)host port:(NSInteger)port {
  [self.auth useEmulatorWithHost:host port:port];
  self.emulatorEnabled = YES;
}

#pragma mark - Internal Methods

- (void)invokeResultCallbackWithAuthDataResult:(nullable FIRAuthDataResult *)authDataResult
                                           URL:(nullable NSURL *)url
                                         error:(nullable NSError *)error {
  dispatch_async(dispatch_get_main_queue(), ^{
    if ([self.delegate respondsToSelector:@selector(authUI:didSignInWithAuthDataResult:URL:error:)]) {
      [self.delegate authUI:self
          didSignInWithAuthDataResult:authDataResult
                                  URL:url
                                error:error];
    }
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

- (void)setEmailAuthProvider:(id<FUIEmailAuthProvider>)emailAuthProvider {
  _emailAuthProvider = emailAuthProvider;
}

- (id<FUIEmailAuthProvider>)emailAuthProvider {
  return _emailAuthProvider;
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
