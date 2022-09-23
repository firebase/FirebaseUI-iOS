//
//  Copyright (c) 2019 Google Inc.
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

#import "FirebaseOAuthUI/Sources/Public/FirebaseOAuthUI/FUIOAuth.h"

#import <AuthenticationServices/AuthenticationServices.h>
#import <FirebaseAuthUI/FirebaseAuthUI.h>

/** @var kTableName
    @brief The name of the strings table to search for localized strings.
 */
static NSString *const kTableName = @"FirebaseOAuthUI";

/** @var kBundleName
    @brief The name of the bundle to search for resources.
 */
#if SWIFT_PACKAGE
static NSString *const kBundleName = @"FirebaseUI_FirebaseOAuthUI";
#else
static NSString *const kBundleName = @"FirebaseOAuthUI";
#endif // SWIFT_PACKAGE

/** @var kSignInAsGuest
    @brief The string key for localized button text.
 */
static NSString *const kSignInAsGuest = @"SignInAsGuest";

NS_ASSUME_NONNULL_BEGIN

@interface FUIOAuth () <ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding> {
  FUIAuthProviderSignInCompletionBlock _providerSignInCompletion;
}

/** @property authUI
    @brief FUIAuth instance of the application.
 */
@property(nonatomic, strong) FUIAuth *authUI;

/** @property presentingViewController
    @brief The presenting view controller for interactive sign-in.
 */
@property(nonatomic, strong) UIViewController *presentingViewController;

/** @property providerID
    @brief A unique identifier for the provider.
 */
@property(nonatomic, copy, nullable) NSString *providerID;

/** @property signInLabel
    @brief A localized label for the provider's sign-in button.
 */
@property(nonatomic, copy) NSString *signInLabel;

/** @property shortName
    @brief A short display name for the provider.
 */
@property(nonatomic, copy) NSString *shortName;

/** @property icon
    @brief The icon image of the provider.
 */
@property(nonatomic, strong) UIImage *icon;

/** @property buttonBackgroundColor
    @brief The background color that should be used for the sign in button of the provider.
 */
@property(nonatomic, strong) UIColor *buttonBackgroundColor;

/** @property buttonTextColor
 @brief The text color that should be used for the sign in button of the provider.
 */
@property(nonatomic, readwrite) UIColor *buttonTextColor;

/** @property scopes
    @brief Array used to configure the OAuth scopes.
 */
@property(nonatomic, copy, nullable) NSArray<NSString *> *scopes;

/** @property customParameters
    @brief Dictionary used to configure the OAuth custom parameters.
 */
@property(nonatomic, copy, nullable) NSDictionary<NSString *, NSString*> *customParameters;

/** @property loginHintKey
    @brief The key of the custom parameter, with which the login hint can be passed to the IdP.
 */
@property(nonatomic, copy, nullable) NSString *loginHintKey;

/** @property currentNonce
    @brief The nonce for the current Sign in with Apple session, if any.
 */
@property(nonatomic, copy, nullable) NSString *currentNonce;

/** @property provider
    @brief The OAuth provider that does the actual sign in.
 */
@property(nonatomic, strong) FIROAuthProvider *provider;

@end

@implementation FUIOAuth

+ (NSBundle *)bundle {
  return [FUIAuthUtils bundleNamed:kBundleName
                 inFrameworkBundle:[NSBundle bundleForClass:[self class]]];
}

- (instancetype)initWithAuthUI:(FUIAuth *)authUI
                    providerID:(NSString *)providerID
               buttonLabelText:(NSString *)buttonLabelText
                     shortName:(NSString *)shortName
                   buttonColor:(UIColor *)buttonColor
                     iconImage:(UIImage *)iconImage
                        scopes:(nullable NSArray<NSString *> *)scopes
              customParameters:(nullable NSDictionary<NSString *, NSString*> *)customParameters
                  loginHintKey:(nullable NSString *)loginHintKey {
  if (self = [super init]) {
    _authUI = authUI;
    _providerID = providerID;
    _signInLabel = buttonLabelText;
    _shortName = shortName;
    _buttonBackgroundColor = buttonColor;
    _buttonTextColor = [UIColor whiteColor];
    _icon = iconImage;
    _scopes = scopes;
    _customParameters = customParameters;
    _loginHintKey = loginHintKey;
    if ((_authUI.isEmulatorEnabled || ![_providerID isEqualToString:@"apple.com"]) && ![_providerID isEqualToString:@"facebook.com"]) {
      _provider = [FIROAuthProvider providerWithProviderID:self.providerID auth:_authUI.auth];
    }
  }
  return self;
}

+ (FUIOAuth *)twitterAuthProvider {
    return [FUIOAuth twitterAuthProviderWithAuthUI:[FUIAuth defaultAuthUI]];
}

+ (FUIOAuth *)twitterAuthProviderWithAuthUI:(FUIAuth *)authUI {
    return [[FUIOAuth alloc] initWithAuthUI:authUI
                                 providerID:@"twitter.com"
                            buttonLabelText:@"Sign in with Twitter"
                                  shortName:@"Twitter"
                                buttonColor:[UIColor colorWithRed:71.0f/255.0f
                                                            green:154.0f/255.0f
                                                             blue:234.0f/255.0f
                                                            alpha:1.0f]
                                  iconImage:[FUIAuthUtils imageNamed:@"ic_twitter"
                                                          fromBundle:[FUIOAuth bundle]]
                                     scopes:@[@"user.readwrite"]
                           customParameters:@{@"prompt" : @"consent"}
                               loginHintKey:nil];
}

+ (FUIOAuth *)githubAuthProvider {
    return [FUIOAuth githubAuthProviderWithAuthUI:[FUIAuth defaultAuthUI]];
}

+ (FUIOAuth *)githubAuthProviderWithAuthUI:(FUIAuth *)authUI
{
    return [[FUIOAuth alloc] initWithAuthUI:authUI
                                 providerID:@"github.com"
                            buttonLabelText:@"Sign in with GitHub"
                                  shortName:@"GitHub"
                                buttonColor:[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0]
                                  iconImage:[FUIAuthUtils imageNamed:@"ic_github"
                                                          fromBundle:[FUIOAuth bundle]]
                                     scopes:nil
                           customParameters:nil
                               loginHintKey:nil];
}

+ (FUIOAuth *)microsoftAuthProvider {
    return [FUIOAuth microsoftAuthProviderWithAuthUI:[FUIAuth defaultAuthUI]];
}

+ (FUIOAuth *)microsoftAuthProviderWithAuthUI:(FUIAuth *)authUI {
  return [[FUIOAuth alloc] initWithAuthUI:authUI
                               providerID:@"microsoft.com"
                          buttonLabelText:@"Sign in with Microsoft"
                                shortName:@"Microsoft"
                              buttonColor:[UIColor colorWithRed:.18 green:.18 blue:.18 alpha:1.0]
                                iconImage:[FUIAuthUtils imageNamed:@"ic_microsoft"
                                                        fromBundle:[FUIOAuth bundle]]
                                   scopes:@[@"user.readwrite"]
                         customParameters:@{@"prompt" : @"consent"}
                             loginHintKey:@"login_hint"];
}

+ (FUIOAuth *)yahooAuthProvider {
    return [FUIOAuth yahooAuthProviderWithAuthUI:[FUIAuth defaultAuthUI]];
}

+ (FUIOAuth *)yahooAuthProviderWithAuthUI:(FUIAuth *)authUI {
  return [[FUIOAuth alloc] initWithAuthUI:authUI
                               providerID:@"yahoo.com"
                          buttonLabelText:@"Sign in with Yahoo"
                                shortName:@"Yahoo"
                              buttonColor:[UIColor colorWithRed:.45 green:.05 blue:.62 alpha:1.0]
                                iconImage:[FUIAuthUtils imageNamed:@"ic_yahoo"
                                                        fromBundle:[FUIOAuth bundle]]
                                   scopes:@[@"user.readwrite"]
                         customParameters:@{@"prompt" : @"consent"}
                             loginHintKey:nil];
}

+ (FUIOAuth *)appleAuthProvider {
    return [FUIOAuth appleAuthProviderWithAuthUI:[FUIAuth defaultAuthUI]];
}

+ (FUIOAuth *)appleAuthProviderWithAuthUI:(FUIAuth *)authUI {
  UIUserInterfaceStyle style = UITraitCollection.currentTraitCollection.userInterfaceStyle;
  return [self appleAuthProviderWithAuthUI:authUI userInterfaceStyle:style];
}

+ (FUIOAuth *)appleAuthProviderWithUserInterfaceStyle:(UIUserInterfaceStyle)userInterfaceStyle {
    return [FUIOAuth appleAuthProviderWithAuthUI:[FUIAuth defaultAuthUI] userInterfaceStyle:userInterfaceStyle];
}

+ (FUIOAuth *)appleAuthProviderWithAuthUI:(FUIAuth *)authUI
                       userInterfaceStyle:(UIUserInterfaceStyle)userInterfaceStyle {
  UIImage *iconImage = [FUIAuthUtils imageNamed:@"ic_apple"
                                     fromBundle:[FUIOAuth bundle]];
  UIColor *buttonColor = [UIColor blackColor];
  UIColor *buttonTextColor = [UIColor whiteColor];
  if (userInterfaceStyle == UIUserInterfaceStyleDark) {
    iconImage = [iconImage imageWithTintColor:[UIColor blackColor]];
    buttonColor = [UIColor whiteColor];
    buttonTextColor = [UIColor blackColor];
  } else if (userInterfaceStyle == UIUserInterfaceStyleLight) {
    iconImage = [iconImage imageWithTintColor:[UIColor whiteColor]];
    buttonColor = [UIColor blackColor];
    buttonTextColor = [UIColor whiteColor];
  } else {
    iconImage = [iconImage imageWithTintColor:[UIColor whiteColor]];
  }
  FUIOAuth *provider = [[FUIOAuth alloc] initWithAuthUI:authUI
                                             providerID:@"apple.com"
                                        buttonLabelText:@"Sign in with Apple"
                                              shortName:@"Apple"
                                            buttonColor:buttonColor
                                              iconImage:iconImage
                                                 scopes:@[@"name", @"email"]
                                       customParameters:nil
                                           loginHintKey:nil];
  provider.buttonAlignment = FUIButtonAlignmentCenter;
  provider.buttonTextColor = buttonTextColor;
  return provider;
}

#pragma mark - FUIAuthProvider

/** @fn accessToken:
    @brief OAuth token is matched by FirebaseUI User Access Token
 */
- (nullable NSString *)accessToken {
  return nil;
}

/** @fn idToken:
    @brief OAuth Token Secret is matched by FirebaseUI User Id Token
 */
- (nullable NSString *)idToken {
  return nil;
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
  FIROAuthProvider *provider = self.provider;
  _providerSignInCompletion = completion;

  if ([self.providerID isEqualToString:@"apple.com"] && !self.authUI.isEmulatorEnabled) {
    if (@available(iOS 13.0, *)) {
      NSString *nonce = [FUIAuthUtils randomNonce];
      self.currentNonce = nonce;
      ASAuthorizationAppleIDRequest *request = [[[ASAuthorizationAppleIDProvider alloc] init] createRequest];
      request.requestedScopes = @[ASAuthorizationScopeFullName, ASAuthorizationScopeEmail];
      request.nonce = [FUIAuthUtils stringBySHA256HashingString:nonce];
      ASAuthorizationController* controller = [[ASAuthorizationController alloc] initWithAuthorizationRequests:@[request]];
      controller.delegate = self;
      controller.presentationContextProvider = self;
      [controller performRequests];
    } else {
      NSLog(@"Sign in with Apple is only available on iOS 13+.");
    }
  } else {
    provider.scopes = self.scopes;
    NSMutableDictionary *customParameters = [NSMutableDictionary dictionary];
    if (self.customParameters.count) {
      [customParameters addEntriesFromDictionary:self.customParameters];
    }
    if (self.loginHintKey.length && defaultValue.length) {
      customParameters[self.loginHintKey] = defaultValue;
    }
    provider.customParameters = [customParameters copy];

    [self.provider getCredentialWithUIDelegate:nil
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
}

- (void)signOut {
  return;
}

- (BOOL)handleOpenURL:(NSURL *)URL sourceApplication:(nullable NSString *)sourceApplication {
  return NO;
}

#pragma mark - ASAuthorizationControllerDelegate

+ (NSPersonNameComponentsFormatter *)nameFormatter {
  static NSPersonNameComponentsFormatter *nameFormatter;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    nameFormatter = [[NSPersonNameComponentsFormatter alloc] init];
  });
  return nameFormatter;
}

- (void)authorizationController:(ASAuthorizationController *)controller didCompleteWithAuthorization:(ASAuthorization *)authorization API_AVAILABLE(ios(13.0)) {
  ASAuthorizationAppleIDCredential *appleIDCredential = authorization.credential;
  NSData *rawIdentityToken = appleIDCredential.identityToken;
  if (rawIdentityToken == nil) {
    // It's pretty awful to not have an error when login is unsuccessful, but Apple's docs
    // don't provide any useful information here.
    // https://developer.apple.com/documentation/authenticationservices/asauthorizationappleidcredential
    NSLog(@"Sign in with Apple completed with authorization, but no jwt: %@", authorization);
    _providerSignInCompletion(nil, nil, nil, nil);
  }
  NSString *idToken = [[NSString alloc] initWithData:appleIDCredential.identityToken encoding:NSUTF8StringEncoding];
  NSString *rawNonce = self.currentNonce;
  FIROAuthCredential *credential = [FIROAuthProvider credentialWithProviderID:@"apple.com"
                                                                      IDToken:idToken
                                                                     rawNonce:rawNonce];
  FIRAuthResultCallback result;
  NSPersonNameComponents *nameComponents = appleIDCredential.fullName;
  if (nameComponents != nil) {
    NSPersonNameComponentsFormatter *formatter = [[self class] nameFormatter];
    NSString *displayName = [formatter stringFromPersonNameComponents:nameComponents];

    result = ^(FIRUser *_Nullable user,
               NSError *_Nullable error) {
      if (user != nil) {
        FIRUserProfileChangeRequest *displayNameUpdate = [user profileChangeRequest];
        displayNameUpdate.displayName = displayName;
        [displayNameUpdate commitChangesWithCompletion:^(NSError * _Nullable error) {}];
      }
    };
  }
  _providerSignInCompletion(credential, nil, result, nil);
}

- (void)authorizationController:(ASAuthorizationController *)controller didCompleteWithError:(NSError *)error API_AVAILABLE(ios(13.0)) {
    NSLog(@"%@", error.description);
    // canceled/failed/invalid/Nothandled/Unknown
    if (_providerSignInCompletion) {
        _providerSignInCompletion(nil, error, nil, nil);
    }
}

#pragma mark - ASAuthorizationControllerPresentationContextProviding

- (ASPresentationAnchor)presentationAnchorForAuthorizationController:(ASAuthorizationController *)controller API_AVAILABLE(ios(13.0)) {
  return self.presentingViewController.view.window;
}

@end

NS_ASSUME_NONNULL_END
