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

#import "FirebaseEmailAuthUI/Sources/Public/FirebaseEmailAuthUI/FUIEmailAuth.h"

#import <FirebaseCore/FIRApp.h>
#import <FirebaseCore/FIROptions.h>
#import <FirebaseAuth/FirebaseAuth.h>
#import <GoogleUtilities/GULUserDefaults.h>

#import <FirebaseAuthUI/FirebaseAuthUI.h>

#import "FirebaseEmailAuthUI/Sources/Public/FirebaseEmailAuthUI/FUIConfirmEmailViewController.h"
#import "FirebaseEmailAuthUI/Sources/FUIEmailAuthStrings.h"
#import "FirebaseEmailAuthUI/Sources/FUIEmailAuth_Internal.h"
#import "FirebaseEmailAuthUI/Sources/Public/FirebaseEmailAuthUI/FUIEmailEntryViewController.h"
#import "FirebaseEmailAuthUI/Sources/FUIPasswordSignInViewController_Internal.h"
#import "FirebaseEmailAuthUI/Sources/Public/FirebaseEmailAuthUI/FUIPasswordVerificationViewController.h"
#import "FirebaseEmailAuthUI/Sources/Public/FirebaseEmailAuthUI/FUIPasswordSignInViewController.h"

/** @var kErrorUserInfoEmailKey
    @brief The key for the email address in the userinfo dictionary of a sign in error.
 */
static NSString *const kErrorUserInfoEmailKey = @"FIRAuthErrorUserInfoEmailKey";

/** @var kEmailButtonAccessibilityID
    @brief The Accessibility Identifier for the @c email sign in button.
 */
static NSString *const kEmailButtonAccessibilityID = @"EmailButtonAccessibilityID";

/** @var kEmailLinkSignInEmailKey
    @brief The key of the email which request email link sign in.
 */
static NSString *const kEmailLinkSignInEmailKey = @"FIRAuthEmailLinkSignInEmail";

/** @var kEmailLinkSignInLinkingCredentialKey
 @brief The key of the auth credential to be linked.
 */
static NSString *const kEmailLinkSignInLinkingCredentialKey = @"FIRAuthEmailLinkSignInLinkingCredential";

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

+ (NSBundle *)bundle {
  return [FUIAuthUtils bundleNamed:FUIEmailAuthBundleName
                 inFrameworkBundle:[NSBundle bundleForClass:[self class]]];
}

- (instancetype)init {
  return [self initAuthAuthUI:[FUIAuth defaultAuthUI]
                 signInMethod:FIREmailPasswordAuthSignInMethod
              forceSameDevice:NO
        allowNewEmailAccounts:YES
           requireDisplayName:YES
            actionCodeSetting:[[FIRActionCodeSettings alloc] init]];
}


- (instancetype)initAuthAuthUI:(FUIAuth *)authUI
                  signInMethod:(NSString *)signInMethod
               forceSameDevice:(BOOL)forceSameDevice
         allowNewEmailAccounts:(BOOL)allowNewEmailAccounts
             actionCodeSetting:(FIRActionCodeSettings *)actionCodeSettings {
  return [self initAuthAuthUI:authUI
                 signInMethod:signInMethod
              forceSameDevice:forceSameDevice
        allowNewEmailAccounts:allowNewEmailAccounts
           requireDisplayName:YES
            actionCodeSetting:actionCodeSettings];
}

- (instancetype)initAuthAuthUI:(FUIAuth *)authUI
                  signInMethod:(NSString *)signInMethod
               forceSameDevice:(BOOL)forceSameDevice
         allowNewEmailAccounts:(BOOL)allowNewEmailAccounts
            requireDisplayName:(BOOL)requireDisplayName
             actionCodeSetting:(FIRActionCodeSettings *)actionCodeSettings {
  self = [super init];
  if (self) {
    _authUI = authUI;
    _authUI.emailAuthProvider = self;
    _signInMethod = signInMethod;
    _forceSameDevice = forceSameDevice;
    _allowNewEmailAccounts = allowNewEmailAccounts;
    _requireDisplayName = requireDisplayName;
    _actionCodeSettings = actionCodeSettings;
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
  return [FUIAuthUtils imageNamed:@"ic_email" fromBundle:[FUIEmailAuth bundle]];
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
    if ([delegate respondsToSelector:@selector(passwordSignInViewControllerForAuthUI:email:)]) {
      controller = [delegate passwordSignInViewControllerForAuthUI:self.authUI
                                                             email:defaultValue];
    } else {
      controller = [[FUIPasswordSignInViewController alloc] initWithAuthUI:self.authUI
                                                                     email:defaultValue];
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
  return;
}

- (BOOL)handleOpenURL:(NSURL *)URL sourceApplication:(nullable NSString *)sourceApplication {
  self.emailLink = URL.absoluteString;
  
  // Retrieve continueUrl from URL
  NSURLComponents *urlComponents = [NSURLComponents componentsWithString:URL.absoluteString];
  NSString *continueURLString;
  for (NSURLQueryItem *queryItem in urlComponents.queryItems) {
    if ([queryItem.name isEqualToString:@"continueUrl"]) {
      continueURLString = queryItem.value;
    }
  }
  if (!continueURLString) {
    NSLog(@"FUIEmailAuth unable to handle url without continue URL: %@", URL);
    return NO;
  }

  // Retrieve url parameters from continueUrl
  NSMutableDictionary *urlParameterDict= [NSMutableDictionary dictionary];
  NSURLComponents *continueURLComponents = [NSURLComponents componentsWithString:continueURLString];
  for (NSURLQueryItem *queryItem in continueURLComponents.queryItems) {
    urlParameterDict[queryItem.name] = queryItem.value;
  }
  // Retrieve parameters from local storage
  NSMutableDictionary *localParameterDict = [NSMutableDictionary dictionary];
  localParameterDict[kEmailLinkSignInEmailKey] = [GULUserDefaults.standardUserDefaults
                                                  stringForKey:kEmailLinkSignInEmailKey];
  localParameterDict[@"ui_sid"] = [GULUserDefaults.standardUserDefaults stringForKey:@"ui_sid"];

  // Handling flows
  NSString *urlSessionID = urlParameterDict[@"ui_sid"];
  NSString *localSessionID = localParameterDict[@"ui_sid"];
  BOOL sameDevice = urlSessionID && localSessionID && [urlSessionID isEqualToString:localSessionID];

  if (sameDevice) {
    // Same device
    if (urlParameterDict[@"ui_pid"]) {
      // Unverified provider linking
      NSError *error = nil;
      [self handleUnverifiedProviderLinking:urlParameterDict[@"ui_pid"]
                                      email:localParameterDict[kEmailLinkSignInEmailKey]
                                      error:&error];
      if (error != nil) {
        NSLog(@"Error verifying provider linking: %@", error);
        return NO;
      }
    } else if (urlParameterDict[@"ui_auid"]) {
      // Anonymous upgrade
      [self handleAnonymousUpgrade:urlParameterDict[@"ui_auid"]
                             email:localParameterDict[kEmailLinkSignInEmailKey]];
    } else {
      // Normal email link sign in
      [self handleEmaiLinkSignIn:localParameterDict[kEmailLinkSignInEmailKey]];
    }
  } else {
    // Different device
    if ([urlParameterDict[@"ui_sd"] isEqualToString:@"1"]) {
      // Force same device enabled
      [self handleDifferentDevice];
    } else {
      // Force same device not enabled
      [self handleConfirmEmail];
    }
  }

  return YES;
}

- (void)handleUnverifiedProviderLinking:(NSString *)providerID
                                  email:(NSString *)email
                                  error:(NSError **)error {
  if ([providerID isEqualToString:FIRFacebookAuthProviderID]) {
    NSData *unverifiedProviderCredentialData = [GULUserDefaults.standardUserDefaults
                                                objectForKey:kEmailLinkSignInLinkingCredentialKey];
    FIRAuthCredential *unverifiedProviderCredential;

    // TODO:
    // The replacement method for `unarchiveObjectWithData:` requires NSSecureCoding, which
    // FIRAuthCredential does not yet conform to.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    unverifiedProviderCredential =
        [NSKeyedUnarchiver unarchiveObjectWithData:unverifiedProviderCredentialData];
#pragma clang diagnostic pop

    FIRAuthCredential *emailLinkCredential =
    [FIREmailAuthProvider credentialWithEmail:email link:self.emailLink];

    void (^completeSignInBlock)(FIRAuthDataResult *, NSError *) = ^(FIRAuthDataResult *authResult,
                                                                    NSError *error) {
      if (error) {
        switch (error.code) {
          case FIRAuthErrorCodeWrongPassword:
            [FUIAuthBaseViewController showAlertWithMessage:FUILocalizedString(kStr_WrongPasswordError)];
            return;
          case FIRAuthErrorCodeUserNotFound:
            [FUIAuthBaseViewController showAlertWithMessage:FUILocalizedString(kStr_UserNotFoundError)];
            return;
          case FIRAuthErrorCodeUserDisabled:
            [FUIAuthBaseViewController showAlertWithMessage:FUILocalizedString(kStr_AccountDisabledError)];
            return;
          case FIRAuthErrorCodeTooManyRequests:
            [FUIAuthBaseViewController showAlertWithMessage:FUILocalizedString(kStr_SignInTooManyTimesError)];
            return;
        }
      }

      void (^dismissHandler)(void) = ^() {
        UINavigationController *authViewController = [self.authUI authViewController];
        if (!(authViewController.isViewLoaded && authViewController.view.window)) {
          [authViewController.navigationController dismissViewControllerAnimated:YES completion:nil];
        }
        [self.authUI invokeResultCallbackWithAuthDataResult:authResult URL:nil error:error];
      };

      [FUIAuthBaseViewController showAlertWithTitle:FUILocalizedString(kStr_SignedIn)
                                            message:nil
                                        actionTitle:nil
                                      actionHandler:nil
                                       dismissTitle:@"OK"
                                     dismissHandler:dismissHandler
                           presentingViewController:nil];
    };

    [self.authUI.auth signInWithCredential:emailLinkCredential
                                completion:^(FIRAuthDataResult * _Nullable authResult,
                                             NSError * _Nullable error) {
      if (error) {
        [FUIAuthBaseViewController showAlertWithMessage:error.description];
        return;
      }

      [authResult.user linkWithCredential:unverifiedProviderCredential completion:completeSignInBlock];
    }];
  }
}

- (void)handleAnonymousUpgrade:(NSString *)anonymousUserID email:(NSString *)email {
  // Check for the presence of an anonymous user and whether automatic upgrade is enabled.
  if (self.authUI.auth.currentUser.isAnonymous &&
      self.authUI.shouldAutoUpgradeAnonymousUsers &&
      [anonymousUserID isEqualToString:self.authUI.auth.currentUser.uid]) {

    FIRAuthCredential *credential =
        [FIREmailAuthProvider credentialWithEmail:email link:self.emailLink];

    void (^completeSignInBlock)(FIRAuthDataResult *, NSError *) = ^(FIRAuthDataResult *authResult,
                                                                    NSError *error) {
      if (error) {
        switch (error.code) {
          case FIRAuthErrorCodeWrongPassword:
            [FUIAuthBaseViewController showAlertWithMessage:FUILocalizedString(kStr_WrongPasswordError)];
            return;
          case FIRAuthErrorCodeUserNotFound:
            [FUIAuthBaseViewController showAlertWithMessage:FUILocalizedString(kStr_UserNotFoundError)];
            return;
          case FIRAuthErrorCodeUserDisabled:
            [FUIAuthBaseViewController showAlertWithMessage:FUILocalizedString(kStr_AccountDisabledError)];
            return;
          case FIRAuthErrorCodeTooManyRequests:
            [FUIAuthBaseViewController showAlertWithMessage:FUILocalizedString(kStr_SignInTooManyTimesError)];
            return;
        }
      }
      [FUIAuthBaseViewController showAlertWithMessage:FUILocalizedString(kStr_SignedIn)];
    };

    [self.authUI.auth.currentUser
        linkWithCredential:credential
                completion:^(FIRAuthDataResult *_Nullable authResult,
                            NSError *_Nullable error) {
       if (error) {
         if (error.code == FIRAuthErrorCodeEmailAlreadyInUse) {
           NSDictionary *userInfo = @{ FUIAuthCredentialKey : credential };
           NSError *mergeError = [FUIAuthErrorUtils mergeConflictErrorWithUserInfo:userInfo
                                                                   underlyingError:error];
           completeSignInBlock(nil, mergeError);
           return;
         }
         completeSignInBlock(nil, error);
         return;
       }
       completeSignInBlock(authResult, nil);
     }];
  } else {
    [self handleDifferentDevice];
  }
}

- (void)handleEmaiLinkSignIn:(NSString *)email {
  FIRAuthCredential *credential =
  [FIREmailAuthProvider credentialWithEmail:email link:self.emailLink];

  void (^completeSignInBlock)(FIRAuthDataResult *, NSError *) = ^(FIRAuthDataResult *authResult,
                                                                  NSError *error) {
    if (error) {
      switch (error.code) {
        case FIRAuthErrorCodeWrongPassword:
          [FUIAuthBaseViewController showAlertWithMessage:FUILocalizedString(kStr_WrongPasswordError)];
          return;
        case FIRAuthErrorCodeUserNotFound:
          [FUIAuthBaseViewController showAlertWithMessage:FUILocalizedString(kStr_UserNotFoundError)];
          return;
        case FIRAuthErrorCodeUserDisabled:
          [FUIAuthBaseViewController showAlertWithMessage:FUILocalizedString(kStr_AccountDisabledError)];
          return;
        case FIRAuthErrorCodeTooManyRequests:
          [FUIAuthBaseViewController showAlertWithMessage:FUILocalizedString(kStr_SignInTooManyTimesError)];
          return;
      }
    }

    void (^dismissHandler)(void) = ^() {
      UINavigationController *authViewController = [self.authUI authViewController];
      if (!(authViewController.isViewLoaded && authViewController.view.window)) {
        [authViewController.navigationController dismissViewControllerAnimated:YES completion:nil];
      }
      [self.authUI invokeResultCallbackWithAuthDataResult:authResult URL:nil error:error];
    };

    [FUIAuthBaseViewController showAlertWithTitle:FUILocalizedString(kStr_SignedIn)
                                          message:nil
                                      actionTitle:nil
                                    actionHandler:nil
                                     dismissTitle:FUILocalizedString(kStr_OK)
                                   dismissHandler:dismissHandler
                         presentingViewController:nil];
  };

  [self.authUI.auth signInWithCredential:credential completion:completeSignInBlock];
}

- (void)handleDifferentDevice {
  UINavigationController *authViewController = [self.authUI authViewController];
  void (^completion)(void) = ^(){
    [FUIAuthBaseViewController showAlertWithTitle:@"New Device detected"
                                          message:@"Try opening the link using the same "
                                                  "device where you started the sign-in process"
                         presentingViewController:authViewController];
  };

  if (!(authViewController.isViewLoaded && authViewController.view.window)) {
    [UIApplication.sharedApplication.keyWindow.rootViewController
       presentViewController:authViewController animated:YES completion:completion];
  } else {
    completion();
  }
}

- (void)handleConfirmEmail {
  UINavigationController *authViewController = [self.authUI authViewController];
  void (^completion)(void) = ^(){
    UIViewController *controller = [[FUIConfirmEmailViewController alloc] initWithAuthUI:self.authUI];
    [authViewController pushViewController:controller animated:YES];
  };

  if (!(authViewController.isViewLoaded && authViewController.view.window)) {
    [UIApplication.sharedApplication.keyWindow.rootViewController
     presentViewController:authViewController animated:YES completion:completion];
  } else {
    completion();
  }
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

  [self.authUI.auth fetchSignInMethodsForEmail:emailHint
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

            [tempAuth signInWithCredential:credential
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
                                                actionHandler:^{
                  if (completion) {
                    completion(authResult, nil, credential);
                  }
                }
                                                 dismissTitle:@"Cancel"
                                               dismissHandler:^{
                  if (completion) {
                    completion(nil, error, credential);
                  }
                }
                                     presentingViewController:presentingViewController];
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
  [self.authUI.auth fetchSignInMethodsForEmail:email
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

    if ([bestProviderID isEqual:FIREmailLinkAuthSignInMethod]) {
      NSString *providerName;
      if ([newCredential.provider isEqualToString:FIRFacebookAuthProviderID]) {
        providerName = @"Facebook";
      } else if ([newCredential.provider isEqualToString:FIRTwitterAuthProviderID]) {
        providerName = @"Twitter";
      } else if ([newCredential.provider isEqualToString:FIRGitHubAuthProviderID]) {
        providerName = @"Github";
      }
      NSString *message = [NSString stringWithFormat:
          @"You already have an account\n \n You've already used %@. You "
          "can connect your %@ account with %@ by signing in with Email "
          "link below. \n \n For this flow to successfully connect your "
          "account with this email, you have to open the link on the same "
          "device or browser.", email, providerName, email];
      void (^actionHandler)(void) = ^() {
        [self generateURLParametersAndLocalCache:email
                                 linkingProvider:newCredential.provider];

        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:newCredential];
        [GULUserDefaults.standardUserDefaults setObject:data forKey:kEmailLinkSignInLinkingCredentialKey];

        void (^completion)(NSError * _Nullable error) = ^(NSError * _Nullable error){
          if (error) {
            [FUIAuthBaseViewController showAlertWithMessage:error.description];
          } else {
            NSString *signInMessage = [NSString stringWithFormat:
                                       @"A sign-in email with additional instructions was sent to %@. Check your "
                                       "email to complete sign-in.", email];
            [FUIAuthBaseViewController
             showAlertWithTitle:@"Sign-in email sent"
             message:signInMessage
             presentingViewController:nil];
          }
        };
        [self.authUI.auth sendSignInLinkToEmail:email
                             actionCodeSettings:self.actionCodeSettings
                                     completion:completion];
      };

      [FUIAuthBaseViewController
          showAlertWithTitle:@"Sign in"
                     message:message
                 actionTitle:@"Sign in"
               actionHandler:actionHandler
                dismissTitle:nil
              dismissHandler:nil
    presentingViewController:nil];
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

        [self.authUI.auth signInWithCredential:credential
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
          [user linkWithCredential:newCredential
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

- (void)generateURLParametersAndLocalCache:(NSString *)email linkingProvider:(NSString *)linkingProvider {
  NSURL *url = self.actionCodeSettings.URL;
  NSURLComponents *urlComponents = [NSURLComponents componentsWithString:url.absoluteString];
  NSMutableArray<NSURLQueryItem *> *urlQuertItems = [NSMutableArray array];

  [GULUserDefaults.standardUserDefaults setObject:email forKey:kEmailLinkSignInEmailKey];

  if (self.authUI.auth.currentUser.isAnonymous && self.authUI.shouldAutoUpgradeAnonymousUsers) {
    NSString *auid = self.authUI.auth.currentUser.uid;

    NSURLQueryItem *anonymousUserIDQueryItem =
        [NSURLQueryItem queryItemWithName:@"ui_auid" value:auid];
    [urlQuertItems addObject:anonymousUserIDQueryItem];
  }

  NSInteger ui_sid = arc4random_uniform(999999999);
  NSString *sidString = [NSString stringWithFormat:@"%ld", (long)ui_sid];
  [GULUserDefaults.standardUserDefaults setObject:sidString forKey:@"ui_sid"];

  NSURLQueryItem *sessionIDQueryItem =
      [NSURLQueryItem queryItemWithName:@"ui_sid" value:sidString];
  [urlQuertItems addObject:sessionIDQueryItem];

  NSString *sameDeviceValueString;
  if (self.forceSameDevice) {
    sameDeviceValueString = @"1";
  } else {
    sameDeviceValueString = @"0";
  }
  NSURLQueryItem *sameDeviceQueryItem = [NSURLQueryItem queryItemWithName:@"ui_sd" value:sameDeviceValueString];
  [urlQuertItems addObject:sameDeviceQueryItem];

  if (linkingProvider) {
    NSURLQueryItem *providerIDQueryItem = [NSURLQueryItem queryItemWithName:@"ui_pid" value:linkingProvider];
    [urlQuertItems addObject:providerIDQueryItem];
  }

  urlComponents.queryItems = urlQuertItems;
  self.actionCodeSettings.URL = urlComponents.URL;
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

@end
