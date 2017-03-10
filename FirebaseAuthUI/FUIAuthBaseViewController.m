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

#import "FUIAuthBaseViewController.h"

#import <FirebaseAuth/FirebaseAuth.h>
#import "FUIAuthErrorUtils.h"
#import "FUIAuthStrings.h"
#import "FUIAuthUtils.h"
#import "FUIAuth_Internal.h"

/** @var kEmailRegex
    @brief Regular expression for matching email addresses.
 */
static NSString *const kEmailRegex = @".+@([a-zA-Z0-9\\-]+\\.)+[a-zA-Z0-9]{2,63}";

/** @var kAuthUICodingKey
    @brief The key used to encode @c FUIAuth instance for NSCoding.
 */
static NSString *const kAuthUICodingKey = @"authUI";

/** @var kActivityIndiactorPadding
    @brief The padding between the activity indiactor and its overlay.
 */
static const CGFloat kActivityIndiactorPadding = 20.0f;

/** @var kActivityIndiactorOverlayCornerRadius
    @brief The corner radius of the overlay of the acitvity indicator.
 */
static const CGFloat kActivityIndiactorOverlayCornerRadius = 20.0f;

/** @var kActivityIndiactorOverlayOpacity
    @brief The opacity of the overlay of the acitvity indicator.
 */
static const CGFloat kActivityIndiactorOverlayOpacity = 0.8f;

/** @var kActivityIndiactorAnimationDelay
    @brief The time delay before the activity indicator is actually animated.
 */
static const NSTimeInterval kActivityIndiactorAnimationDelay = 0.5f;

/** @class FUIAuthAlertViewDelegate
    @brief A @c UIAlertViewDelegate which allows @c UIAlertView to be used with blocks more easily.
 */
@interface FUIAuthAlertViewDelegate : NSObject <UIAlertViewDelegate>

/** @fn init
    @brief Please use initWithCancelHandler:otherHandlers.
 */
- (instancetype)init NS_UNAVAILABLE;

/** @fn initWithCancelHandler:otherHandlers:
    @brief Designated initializer.
    @param cancelHandler The block to call when the alert view is cancelled.
    @param otherHandlers Handlers for other buttons of the alert view. The number of handlers must
        match the number of other buttons of the alert view.
 */
- (nullable instancetype)initWithCancelHandler:(nullable FUIAuthAlertActionHandler)cancelHandler
    otherHandlers:(nullable NSArray<FUIAuthAlertActionHandler> *)otherHandlers
    NS_DESIGNATED_INITIALIZER;

@end

@implementation FUIAuthAlertViewDelegate {
  FUIAuthAlertActionHandler _cancelHandler;
  NSArray<FUIAuthAlertActionHandler> *_otherHandlers;
  FUIAuthAlertViewDelegate *_retainedSelf;
}

- (nullable instancetype)initWithCancelHandler:(nullable FUIAuthAlertActionHandler)cancelHandler
    otherHandlers:(nullable NSArray<FUIAuthAlertActionHandler> *)otherHandlers {
  self = [super init];
  if (self) {
    _cancelHandler = cancelHandler;
    _otherHandlers = otherHandlers;
    _retainedSelf = self;
  }
  return self;
}

#pragma mark - FUIAuthAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
  if (buttonIndex == alertView.cancelButtonIndex) {
    if (_cancelHandler) {
      _cancelHandler();
    }
  } else if (alertView.firstOtherButtonIndex != -1) {
    NSInteger otherButtonIndex = buttonIndex - alertView.firstOtherButtonIndex;
    if (_otherHandlers && _otherHandlers.count > otherButtonIndex) {
      FUIAuthAlertActionHandler handler = _otherHandlers[otherButtonIndex];
      handler();
    }
  }
  _cancelHandler = nil;
  _otherHandlers = nil;
  _retainedSelf = nil;
}

@end

@implementation FUIAuthBaseViewController {
  /** @var _activityIndicator
      @brief A spinner that is displayed when there's an ongoing activity.
   */
  UIActivityIndicatorView *_activityIndicator;

  /** @var _activityCount
      @brief Count of current ongoing activities.
   */
  NSInteger _activityCount;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil
                         bundle:(NSBundle *)nibBundleOrNil
                         authUI:(FUIAuth *)authUI {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    _auth = authUI.auth;
    _authUI = authUI;

    _activityIndicator =
        [[UIActivityIndicatorView alloc]
            initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _activityIndicator.frame = CGRectInset(_activityIndicator.frame,
                                           -kActivityIndiactorPadding,
                                           -kActivityIndiactorPadding);
    _activityIndicator.backgroundColor =
        [UIColor colorWithWhite:0 alpha:kActivityIndiactorOverlayOpacity];
    _activityIndicator.layer.cornerRadius = kActivityIndiactorOverlayCornerRadius;
    [self.view addSubview:_activityIndicator];
  }
  return self;
}

- (instancetype)initWithAuthUI:(FUIAuth *)authUI {
  return [self initWithNibName:NSStringFromClass([self class])
                        bundle:[FUIAuthUtils frameworkBundle]
                        authUI:authUI];
}

- (void)viewDidLayoutSubviews {
  [super viewDidLayoutSubviews];

  CGPoint activityIndicatorCenter = self.view.center;
  // Compensate for bounds adjustment if any.
  activityIndicatorCenter.y += self.view.bounds.origin.y;
  _activityIndicator.center = activityIndicatorCenter;
}

#pragma mark - NSCoding

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
  FUIAuth *authUI = [aDecoder decodeObjectOfClass:[FUIAuth class] forKey:kAuthUICodingKey];
  if (!authUI) {
    return nil;
  }
  return [self initWithAuthUI:authUI];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [aCoder encodeObject:_authUI forKey:kAuthUICodingKey];
}

#pragma mark - Utilities

+ (BOOL)isValidEmail:(NSString *)email {
  static dispatch_once_t onceToken;
  static NSPredicate *emailPredicate;
  dispatch_once(&onceToken, ^{
    emailPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", kEmailRegex];
  });
  return [emailPredicate evaluateWithObject:email];
}

- (void)showAlertWithMessage:(NSString *)message {
  if ([UIAlertController class]) {
    UIAlertController *alertController =
        [UIAlertController alertControllerWithTitle:nil
                                            message:message
                                     preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction =
        [UIAlertAction actionWithTitle:FUILocalizedString(kStr_OK)
                                 style:UIAlertActionStyleDefault
                               handler:nil];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
  } else {
    UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle:nil
                                   message:message
                                  delegate:nil
                         cancelButtonTitle:nil
                         otherButtonTitles:FUILocalizedString(kStr_OK), nil];
    [alert show];
  }
}

- (void)showSignInAlertWithEmail:(NSString *)email
                        provider:(id<FUIAuthProvider>)provider
                         handler:(FUIAuthAlertActionHandler)handler {
  NSString *message =
      [NSString stringWithFormat:FUILocalizedString(kStr_ProviderUsedPreviouslyMessage),
          email, provider.shortName];
  if ([UIAlertController class]) {
    UIAlertController *alertController =
        [UIAlertController alertControllerWithTitle:FUILocalizedString(kStr_ExistingAccountTitle)
                                            message:message
                                     preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *signInAction =
        [UIAlertAction actionWithTitle:provider.signInLabel
                                 style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *_Nonnull action) {
          handler();
        }];
    [alertController addAction:signInAction];
    UIAlertAction *cancelAction =
        [UIAlertAction actionWithTitle:FUILocalizedString(kStr_Cancel)
                                 style:UIAlertActionStyleCancel
                               handler:^(UIAlertAction * _Nonnull action) {
                                 [self.authUI signOutWithError:nil];
                               }];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
  } else {
    UIAlertView *alertView =
        [[UIAlertView alloc] initWithTitle:FUILocalizedString(kStr_ExistingAccountTitle)
                                   message:message
                                  delegate:self
                         cancelButtonTitle:FUILocalizedString(kStr_Cancel)
                         otherButtonTitles:provider.signInLabel, nil];
    FUIAuthAlertViewDelegate *delegate =
        [[FUIAuthAlertViewDelegate alloc] initWithCancelHandler:^{
          [self.authUI signOutWithError:nil];
        }  otherHandlers:@[ handler ]];
    alertView.delegate = delegate;
    [alertView show];
  }
}

- (void)pushViewController:(UIViewController *)viewController {
  // Override the back button title with "Back".
  self.navigationItem.backBarButtonItem =
      [[UIBarButtonItem alloc] initWithTitle:FUILocalizedString(kStr_Back)
                                       style:UIBarButtonItemStylePlain
                                      target:nil
                                      action:nil];
  [self.navigationController pushViewController:viewController animated:YES];
}

- (void)onBack {
  if (self.navigationController.viewControllers.count > 1) {
    [self.navigationController popViewControllerAnimated:YES];
  } else {
    [self cancelAuthorization];
  }
}

- (void)incrementActivity {
  _activityCount++;

  // Delay the display of acitivty indiactor for a short period of time.
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                              (int64_t)(kActivityIndiactorAnimationDelay * NSEC_PER_SEC)),
                 dispatch_get_main_queue(), ^{
    if (_activityCount > 0) {
      [_activityIndicator startAnimating];
    }
  });
}

- (void)decrementActivity {
  _activityCount--;

  if (_activityCount < 0) {
    NSLog(@"Unbalanced calls to incrementActivity and decrementActivity.");
    _activityCount = 0;
  }

  if (_activityCount == 0) {
    [_activityIndicator stopAnimating];
  }
}

- (void)cancelAuthorization {
  [self.navigationController dismissViewControllerAnimated:YES completion:^{
    NSError *error = [FUIAuthErrorUtils userCancelledSignInError];
    [self.authUI invokeResultCallbackWithUser:nil error:error];
  }];
}

+ (NSString *)providerLocalizedName:(NSString *)providerId {
  if ([providerId isEqualToString:FIREmailPasswordAuthProviderID]) {
    return FUILocalizedString(kStr_ProviderTitlePassword);
  } else if ([providerId isEqualToString:FIRGoogleAuthProviderID]) {
    return FUILocalizedString(kStr_ProviderTitleGoogle);
  } else if ([providerId isEqualToString:FIRFacebookAuthProviderID]) {
    return FUILocalizedString(kStr_ProviderTitleFacebook);
  } else if ([providerId isEqualToString:FIRTwitterAuthProviderID]) {
    return FUILocalizedString(kStr_ProviderTitleTwitter);
  }
  return @"";
}

@end
