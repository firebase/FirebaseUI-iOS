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
static NSString *const kBundleName = @"FirebaseUI_FirebaseGoogleAuthUI";

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
    /** @var _presentingViewController
     @brief The presenting view controller for interactive sign-in.
     */
    UIViewController *_presentingViewController;
    
    /** @var _pendingSignInCallback
     @brief The callback which should be invoked when the sign in flow completes (or is cancelled.)
     */
    FUIAuthProviderSignInCompletionBlock _pendingSignInCallback;
    
    /** @var _email
     @brief The email address associated with this account.
     */
    NSString *_email;
}

+ (NSBundle *)bundle {
  return [FUIAuthUtils bundleNamed:kBundleName
                 inFrameworkBundle:[NSBundle bundleForClass:[self class]]];
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
    return [self initWithScopes:@[kGoogleUserInfoEmailScope, kGoogleUserInfoProfileScope]];
}

- (instancetype)initWithScopes:(NSArray *)scopes {
    self = [super init];
    if (self) {
        _scopes = [scopes copy];
    }
    return self;
}
#pragma clang diagnostic pop


#pragma mark - FUIAuthProvider

- (nullable NSString *)providerID {
    return FIRGoogleAuthProviderID;
}

- (nullable NSString *)accessToken {
    if (self.authUI.isEmulatorEnabled) {
        return nil;
    }
    return [GIDSignIn sharedInstance].currentUser.authentication.accessToken;
}

- (nullable NSString *)idToken {
    if (self.authUI.isEmulatorEnabled) {
        return nil;
    }
    return [GIDSignIn sharedInstance].currentUser.authentication.idToken;
}

- (NSString *)shortName {
    return @"Google";
}

- (NSString *)signInLabel {
    return FUILocalizedStringFromTableInBundle(kSignInWithGoogle, kTableName, kBundleName);
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
    _presentingViewController = presentingViewController;
    
    if (self.authUI.isEmulatorEnabled) {
        [self signInWithOAuthProvider:self.providerForEmulator
             presentingViewController:presentingViewController
                           completion:completion];
        return;
    }
    
    
    
    _pendingSignInCallback = ^(FIRAuthCredential *_Nullable credential,
                               NSError *_Nullable error,
                               _Nullable FIRAuthResultCallback result,
                               NSDictionary *_Nullable userInfo) {
        if (completion) {
            completion(credential, error, result, nil);
        }
    };
    
    GIDSignIn* signIn = GIDSignIn.sharedInstance;
    GIDConfiguration* configuration = [self googleSignInConfiguration];
    
    [signIn signInWithConfiguration: configuration
           presentingViewController:presentingViewController
                               hint:defaultValue
                           callback:^(GIDGoogleUser * _Nullable user,
                                      NSError * _Nullable error) {
        if (error) {
            [NSString stringWithFormat:@"Google Authentication error: %@", error];
            return;
        }
        
        if (!_scopes || !_scopes.count) {
            [signIn addScopes:_scopes presentingViewController:presentingViewController callback:^(GIDGoogleUser * _Nullable user, NSError * _Nullable error) {
                if (error) {
                    [NSString stringWithFormat:@"Google add scopes error: %@", error];
                    return;
                }
                [self signIn:GIDSignIn.sharedInstance didSignInForUser:user withError:error];
            }];
        } else {
            [self signIn:signIn didSignInForUser:user withError:error];
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

- (void)signOut {
    if (self.authUI.isEmulatorEnabled) {
        return;
    }
    GIDSignIn *signIn = GIDSignIn.sharedInstance;
    [signIn signOut];
}

- (BOOL)handleOpenURL:(NSURL *)URL sourceApplication:(NSString *)sourceApplication {
    if (self.authUI.isEmulatorEnabled) {
        return NO;
    }
    GIDSignIn *signIn = GIDSignIn.sharedInstance;
    return [signIn handleURL:URL];
}

- (NSString *)email {
    return _email;
}

#pragma mark - GIDSignInCallback methods

- (void)signIn:(GIDSignIn *)signIn
didSignInForUser:(GIDGoogleUser *)user
     withError:(NSError *)error {
    if (error) {
        if (error.code == kGIDSignInErrorCodeCanceled) {
            [self callbackWithCredential:nil
                                   error:[FUIAuthErrorUtils
                                          userCancelledSignInError] result:nil];
        } else {
            NSError *newError =
            [FUIAuthErrorUtils providerErrorWithUnderlyingError:error
                                                     providerID:FIRGoogleAuthProviderID];
            [self callbackWithCredential:nil error:newError result:nil];
        }
        return;
    }
    _email = user.profile.email;
    UIActivityIndicatorView *activityView =
    [FUIAuthBaseViewController addActivityIndicator:_presentingViewController.view];
    [activityView startAnimating];
    FIRAuthCredential *credential =
    [FIRGoogleAuthProvider credentialWithIDToken:user.authentication.idToken
                                     accessToken:user.authentication.accessToken];
    [self callbackWithCredential:credential error:nil result:^(FIRUser *_Nullable user,
                                                               NSError *_Nullable error) {
        [activityView stopAnimating];
        [activityView removeFromSuperview];
    }];
}

#pragma mark - Helpers
/** @fn googleSignInConfiguration
 @brief Returns an instance of @c GIDConfiguration which is configured to match the configuration
 of this instance.
 */
- (GIDConfiguration *)googleSignInConfiguration {
    GIDConfiguration *configuration = [[GIDConfiguration alloc] initWithClientID:[[FIRApp defaultApp] options].clientID];
    
    if (!configuration.clientID) {
        [NSException raise:NSInternalInconsistencyException
                    format:@"OAuth client ID not found. Please make sure Google Sign-In is enabled in "
         @"the Firebase console. You may have to download a new GoogleService-Info.plist file after "
         @"enabling Google Sign-In."];
    }
    
    return configuration;
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
    _presentingViewController = nil;
    _pendingSignInCallback = nil;
    if (callback) {
        callback(credential, error, result, nil);
    }
}

@end
