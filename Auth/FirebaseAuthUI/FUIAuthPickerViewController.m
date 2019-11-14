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

#import "FUIAuthPickerViewController.h"

#import <AuthenticationServices/AuthenticationServices.h>

#import <FirebaseAuth/FirebaseAuth.h>
#import "FUIAuthBaseViewController_Internal.h"
#import "FUIAuthSignInButton.h"
#import "FUIAuthStrings.h"
#import "FUIAuthUtils.h"
#import "FUIAuth_Internal.h"
#import "FUIPrivacyAndTermsOfServiceView.h"

/** @var kSignInButtonWidth
    @brief The width of the sign in buttons.
 */
static const CGFloat kSignInButtonWidth = 220.0f;

/** @var kSignInButtonHeight
    @brief The height of the sign in buttons.
 */
static const CGFloat kSignInButtonHeight = 40.0f;

/** @var kSignInButtonVerticalMargin
    @brief The vertical margin between sign in buttons.
 */
static const CGFloat kSignInButtonVerticalMargin = 24.0f;

/** @var kButtonContainerBottomMargin
    @brief The magin between sign in buttons and the bottom of the content view.
 */
static const CGFloat kButtonContainerBottomMargin = 48.0f;

/** @var kButtonContainerTopMargin
    @brief The margin between sign in buttons and the top of the content view.
 */
static const CGFloat kButtonContainerTopMargin = 16.0f;

/** @var kTOSViewBottomMargin
    @brief The margin between privacy policy and TOS view and the bottom of the content view.
 */
static const CGFloat kTOSViewBottomMargin = 24.0f;

/** @var kTOSViewHorizontalMargin
    @brief The margin between privacy policy and TOS view and the left or right of the content view.
 */
static const CGFloat kTOSViewHorizontalMargin = 16.0f;

@implementation FUIAuthPickerViewController {
  UIView *_buttonContainerView;

  IBOutlet FUIPrivacyAndTermsOfServiceView *_privacyPolicyAndTOSView;

  IBOutlet UIView *_contentView;

  IBOutlet UIScrollView *_scrollView;
}

- (instancetype)initWithAuthUI:(FUIAuth *)authUI {
  return [self initWithNibName:@"FUIAuthPickerViewController"
                        bundle:[FUIAuthUtils bundleNamed:FUIAuthBundleName]
                        authUI:authUI];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil
                         bundle:(NSBundle *)nibBundleOrNil
                         authUI:(FUIAuth *)authUI {

  self = [super initWithNibName:nibNameOrNil
                         bundle:nibBundleOrNil
                         authUI:authUI];
  if (self) {
    self.title = FUILocalizedString(kStr_AuthPickerTitle);
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  // Makes sure that embedded scroll view properly handles translucent navigation bar
  if (!self.navigationController.navigationBar.isTranslucent) {
    self.extendedLayoutIncludesOpaqueBars = true;
  }

  if (!self.authUI.shouldHideCancelButton) {
    UIBarButtonItem *cancelBarButton =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                      target:self
                                                      action:@selector(cancelAuthorization)];
    self.navigationItem.leftBarButtonItem = cancelBarButton;
  }
  if (@available(iOS 13, *)) {
    if (!self.authUI.interactiveDismissEnabled) {
      self.modalInPresentation = YES;
    }
  }

  self.navigationItem.backBarButtonItem =
      [[UIBarButtonItem alloc] initWithTitle:FUILocalizedString(kStr_Back)
                                       style:UIBarButtonItemStylePlain
                                      target:nil
                                      action:nil];

  NSInteger numberOfButtons = self.authUI.providers.count;

  CGFloat buttonContainerViewHeight =
      kSignInButtonHeight * numberOfButtons + kSignInButtonVerticalMargin * (numberOfButtons);
  CGRect buttonContainerViewFrame = CGRectMake(0, 0, kSignInButtonWidth, buttonContainerViewHeight);
  _buttonContainerView = [[UIView alloc] initWithFrame:buttonContainerViewFrame];
  if (_scrollView) {
    [_contentView addSubview:_buttonContainerView];
  } else {
    // For backward compatibility. The old auth picker view does not have a scroll view and its
    // customized class put the button container view directly into self.view.
    [self.view addSubview:_buttonContainerView];
  }

  CGRect buttonFrame = CGRectMake(0, 0, kSignInButtonWidth, kSignInButtonHeight);
  for (id<FUIAuthProvider> providerUI in self.authUI.providers) {
    UIButton *providerButton =
        [[FUIAuthSignInButton alloc] initWithFrame:buttonFrame providerUI:providerUI];
    [providerButton addTarget:self
                       action:@selector(didTapSignInButton:)
             forControlEvents:UIControlEventTouchUpInside];
    [_buttonContainerView addSubview:providerButton];

    // Make the frame for the new button.
    buttonFrame.origin.y += (kSignInButtonHeight + kSignInButtonVerticalMargin);
  }

  _privacyPolicyAndTOSView.authUI = self.authUI;
  [_privacyPolicyAndTOSView useFullMessage];
  [_contentView bringSubviewToFront:_privacyPolicyAndTOSView];
}

- (void)viewDidLayoutSubviews {
  [super viewDidLayoutSubviews];

  // For backward compatibility. The old auth picker view does not have a scroll view and its
  // customized class put the button container view directly into self.view. The following is the
  // old layout behavior.
  if (!_scrollView) {
    CGFloat distanceFromCenterToBottom =
        CGRectGetHeight(_buttonContainerView.frame) / 2.0f + kButtonContainerBottomMargin + kTOSViewBottomMargin;
    CGFloat centerY = CGRectGetHeight(self.view.bounds) - distanceFromCenterToBottom;
    // Compensate for bounds adjustment if any.
    centerY += self.view.bounds.origin.y;
    _buttonContainerView.center = CGPointMake(self.view.center.x, centerY);
    return;
  }

  CGFloat buttonContainerHeight = CGRectGetHeight(_buttonContainerView.frame);
  CGFloat buttonContainerWidth = CGRectGetWidth(_buttonContainerView.frame);
  CGFloat contentViewHeight = kButtonContainerTopMargin + buttonContainerHeight
      + kButtonContainerBottomMargin + kTOSViewBottomMargin;
  CGFloat contentViewWidth = CGRectGetWidth(self.view.bounds);
  _scrollView.frame = self.view.frame;
  CGFloat scrollViewHeight;
  if (@available(iOS 11.0, *)) {
    scrollViewHeight = CGRectGetHeight(_scrollView.frame) - _scrollView.safeAreaInsets.top;
  } else {
    scrollViewHeight = CGRectGetHeight(_scrollView.frame)
        - CGRectGetHeight(self.navigationController.navigationBar.frame)
        - CGRectGetHeight([UIApplication sharedApplication].statusBarFrame);
  }
  CGFloat contentViewY = scrollViewHeight - contentViewHeight;
  if (contentViewY < 0) {
    contentViewY = 0;
  }
  _contentView.frame = CGRectMake(0, contentViewY, contentViewWidth, contentViewHeight);
  _scrollView.contentSize = CGSizeMake(contentViewWidth, contentViewY + contentViewHeight);
  CGFloat buttonContainerLeftMargin = (contentViewWidth - buttonContainerWidth) / 2.0f;
  _buttonContainerView.frame =CGRectMake(buttonContainerLeftMargin,
                                         kButtonContainerTopMargin,
                                         buttonContainerWidth,
                                         buttonContainerHeight);
  CGFloat privacyViewHeight = CGRectGetHeight(_privacyPolicyAndTOSView.frame);
  _privacyPolicyAndTOSView.frame = CGRectMake(kTOSViewHorizontalMargin, contentViewHeight
                                              - privacyViewHeight - kTOSViewBottomMargin,
                                              contentViewWidth - kTOSViewHorizontalMargin*2,
                                              privacyViewHeight);
}

#pragma mark - Actions

- (void)didTapSignInButton:(FUIAuthSignInButton *)button {
  [self.authUI signInWithProviderUI:button.providerUI
           presentingViewController:self
                       defaultValue:nil];
}

@end
