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

#import "FUIAuthBaseViewController_Internal.h"

#import <FirebaseAuth/FirebaseAuth.h>
#import "FUIAuthErrorUtils.h"
#import "FUIAuthStrings.h"
#import "FUIAuthUtils.h"
#import "FUIAuth_Internal.h"

/** @var kActivityIndiactorPadding
    @brief The padding between the activity indiactor and its overlay.
 */
static const CGFloat kActivityIndiactorPadding = 20.0f;

/** @var kActivityIndiactorOverlayCornerRadius
    @brief The corner radius of the overlay of the activity indicator.
 */
static const CGFloat kActivityIndiactorOverlayCornerRadius = 20.0f;

/** @var kActivityIndiactorOverlayOpacity
    @brief The opacity of the overlay of the activity indicator.
 */
static const CGFloat kActivityIndiactorOverlayOpacity = 0.8f;

/** @var kActivityIndiactorAnimationDelay
    @brief The time delay before the activity indicator is actually animated.
 */
static const NSTimeInterval kActivityIndiactorAnimationDelay = 0.5f;

/** @var kUITableViewCellHeight
    @brief Height of all table view cells used in subclasses of the controller.
 */
static const CGFloat kUITableViewCellHeight = 44.f;

/** @var kEmailRegex
    @brief Regular expression for matching email addresses.
 */
static NSString *const kEmailRegex = @".+@([a-zA-Z0-9\\-]+\\.)+[a-zA-Z0-9]{2,63}";

/** @var kAuthUICodingKey
    @brief The key used to encode @c FUIAuth instance for NSCoding.
 */
static NSString *const kAuthUICodingKey = @"authUI";

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

    _activityIndicator = [[self class] addActivityIndicator:self.view];
  }
  return self;
}

- (instancetype)initWithAuthUI:(FUIAuth *)authUI {
  return [self initWithNibName:NSStringFromClass([self class])
                        bundle:[FUIAuthUtils bundleNamed:FUIAuthBundleName]
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

+ (UIActivityIndicatorView *)addActivityIndicator:(UIView *)view {
  if (!view) {
    return nil;
  }
  UIActivityIndicatorView *activityIndicator =
      [[UIActivityIndicatorView alloc]
           initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
  UIView *tintView = [[UIView alloc] initWithFrame:CGRectInset(activityIndicator.frame,
                                                               -kActivityIndiactorPadding,
                                                               -kActivityIndiactorPadding)];
  tintView.backgroundColor =
      [UIColor colorWithWhite:0 alpha:kActivityIndiactorOverlayOpacity];
  tintView.layer.cornerRadius = kActivityIndiactorOverlayCornerRadius;
  [activityIndicator addSubview:tintView];
  
  // Align tintView (transparent background).
  tintView.translatesAutoresizingMaskIntoConstraints = NO;
  [activityIndicator addConstraint:
      [NSLayoutConstraint constraintWithItem:tintView
                                   attribute:NSLayoutAttributeWidth
                                   relatedBy:NSLayoutRelationEqual
                                      toItem:nil
                                   attribute:NSLayoutAttributeNotAnAttribute
                                  multiplier:1
                                    constant:CGRectGetWidth(tintView.frame)]];
  [activityIndicator addConstraint:
      [NSLayoutConstraint constraintWithItem:tintView
                                   attribute:NSLayoutAttributeCenterX
                                   relatedBy:NSLayoutRelationEqual
                                      toItem:activityIndicator
                                   attribute:NSLayoutAttributeCenterX
                                  multiplier:1
                                    constant:0]];

  [activityIndicator addConstraint:
      [NSLayoutConstraint constraintWithItem:tintView
                                   attribute:NSLayoutAttributeHeight
                                   relatedBy:NSLayoutRelationEqual
                                      toItem:nil
                                   attribute:NSLayoutAttributeNotAnAttribute
                                  multiplier:1
                                    constant:CGRectGetHeight(tintView.frame)]];
  [activityIndicator addConstraint:
      [NSLayoutConstraint constraintWithItem:tintView
                                   attribute:NSLayoutAttributeCenterY
                                   relatedBy:NSLayoutRelationEqual
                                      toItem:activityIndicator
                                   attribute:NSLayoutAttributeCenterY
                                  multiplier:1
                                    constant:0]];

  [activityIndicator sendSubviewToBack:tintView];
  
  [view addSubview:activityIndicator];
  // Align activity indicator.
  activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;
  [view addConstraint:
      [NSLayoutConstraint constraintWithItem:activityIndicator
                                   attribute:NSLayoutAttributeWidth
                                   relatedBy:NSLayoutRelationEqual
                                      toItem:view
                                   attribute:NSLayoutAttributeWidth
                                  multiplier:1
                                    constant:0]];
  [view addConstraint:
      [NSLayoutConstraint constraintWithItem:activityIndicator
                                   attribute:NSLayoutAttributeCenterX
                                   relatedBy:NSLayoutRelationEqual
                                      toItem:view
                                   attribute:NSLayoutAttributeCenterX
                                  multiplier:1
                                    constant:0]];

  [view addConstraint:
      [NSLayoutConstraint constraintWithItem:activityIndicator
                                   attribute:NSLayoutAttributeHeight
                                   relatedBy:NSLayoutRelationEqual
                                      toItem:view
                                   attribute:NSLayoutAttributeHeight
                                  multiplier:1
                                    constant:0]];
  [view addConstraint:
      [NSLayoutConstraint constraintWithItem:activityIndicator
                                   attribute:NSLayoutAttributeCenterY
                                   relatedBy:NSLayoutRelationEqual
                                      toItem:view
                                   attribute:NSLayoutAttributeCenterY
                                  multiplier:1
                                    constant:0]];
  return activityIndicator;
}

- (void)showAlertWithMessage:(NSString *)message {
  [[self class] showAlertWithMessage:message presentingViewController:self];
}

+ (void)showAlertWithMessage:(NSString *)message
    presentingViewController:(UIViewController *)presentingViewController {
  [[self class] showAlertWithTitle:nil
                           message:message
                       actionTitle:FUILocalizedString(kStr_OK)
          presentingViewController:presentingViewController];
}

+ (void)showAlertWithTitle:(nullable NSString *)title
                     message:(NSString *)message
                 actionTitle:(NSString *)actionTitle
    presentingViewController:(UIViewController *)presentingViewController {
  UIAlertController *alertController =
      [UIAlertController alertControllerWithTitle:title
                                          message:message
                                   preferredStyle:UIAlertControllerStyleAlert];
  UIAlertAction *okAction =
      [UIAlertAction actionWithTitle:actionTitle
                               style:UIAlertActionStyleDefault
                             handler:nil];
  [alertController addAction:okAction];
  [presentingViewController presentViewController:alertController animated:YES completion:nil];
}

+ (void)showSignInAlertWithEmail:(NSString *)email
                        provider:(id<FUIAuthProvider>)provider
        presentingViewController:(UIViewController *)presentingViewController
                   signinHandler:(FUIAuthAlertActionHandler)signinHandler
                   cancelHandler:(FUIAuthAlertActionHandler)cancelHandler {
  NSString *message =
      [NSString stringWithFormat:FUILocalizedString(kStr_ProviderUsedPreviouslyMessage),
          email, provider.shortName];
  UIAlertController *alertController =
      [UIAlertController alertControllerWithTitle:FUILocalizedString(kStr_ExistingAccountTitle)
                                          message:message
                                   preferredStyle:UIAlertControllerStyleAlert];
  UIAlertAction *signInAction =
      [UIAlertAction actionWithTitle:provider.signInLabel
                               style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction *_Nonnull action) {
        signinHandler();
      }];
  [alertController addAction:signInAction];
  UIAlertAction *cancelAction =
      [UIAlertAction actionWithTitle:FUILocalizedString(kStr_Cancel)
                               style:UIAlertActionStyleCancel
                               handler:^(UIAlertAction * _Nonnull action) {
        cancelHandler();
      }];
  [alertController addAction:cancelAction];
  [presentingViewController presentViewController:alertController animated:YES completion:nil];
}

- (void)pushViewController:(UIViewController *)viewController {
  [[self class] pushViewController:viewController
              navigationController:self.navigationController];
}

+ (void)pushViewController:(UIViewController *)viewController
      navigationController:(UINavigationController *)navigationController {
  // Override the back button title with "Back".
  viewController.navigationItem.backBarButtonItem =
      [[UIBarButtonItem alloc] initWithTitle:FUILocalizedString(kStr_Back)
                                       style:UIBarButtonItemStylePlain
                                      target:nil
                                      action:nil];
  [navigationController pushViewController:viewController animated:YES];
}


+ (UIBarButtonItem *)barItemWithTitle:(NSString *)title
                               target:(nullable id)target
                               action:(SEL)action {
  UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithTitle:title
                                                               style:UIBarButtonItemStylePlain
                                                              target:target
                                                              action:action];
  return buttonItem;
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
    [_activityIndicator.superview bringSubviewToFront:_activityIndicator];
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
    [_activityIndicator.superview sendSubviewToBack:_activityIndicator];
    [_activityIndicator stopAnimating];
  }
}

- (void)cancelAuthorization {
  [self.navigationController dismissViewControllerAnimated:YES completion:^{
    NSError *error = [FUIAuthErrorUtils userCancelledSignInError];
    [self.authUI invokeResultCallbackWithAuthDataResult:nil error:error];
  }];
}

+ (NSString *)providerLocalizedName:(NSString *)providerId {
  if ([providerId isEqualToString:FIREmailAuthProviderID]) {
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

- (void)enableDynamicCellHeightForTableView:(UITableView *)tableView {
  tableView.rowHeight = UITableViewAutomaticDimension;
  tableView.estimatedRowHeight = kUITableViewCellHeight;
}

@end
