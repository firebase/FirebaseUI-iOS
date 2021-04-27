//
//  Copyright (c) 2017 Google Inc.
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

#import "FirebaseAuthUI/Sources/Public/FirebaseAuthUI/FUIAccountSettingsViewController.h"

#import <FirebaseAuth/FirebaseAuth.h>

#import "FirebaseAuthUI/Sources/FUIAccountSettingsOperation.h"
#import "FirebaseAuthUI/Sources/FUIAccountSettingsOperationDeleteAccount.h"
#import "FirebaseAuthUI/Sources/FUIAccountSettingsOperationForgotPassword.h"
#import "FirebaseAuthUI/Sources/FUIAccountSettingsOperationSignOut.h"
#import "FirebaseAuthUI/Sources/FUIAccountSettingsOperationUnlinkAccount.h"
#import "FirebaseAuthUI/Sources/FUIAccountSettingsOperationUpdateEmail.h"
#import "FirebaseAuthUI/Sources/FUIAccountSettingsOperationUpdateName.h"
#import "FirebaseAuthUI/Sources/FUIAccountSettingsOperationUpdatePassword.h"
#import "FirebaseAuthUI/Sources/Public/FirebaseAuthUI/FUIAuthBaseViewController_Internal.h"
#import "FirebaseAuthUI/Sources/Public/FirebaseAuthUI/FUIAuthStrings.h"
#import "FirebaseAuthUI/Sources/FUIStaticContentTableViewController.h"

NS_ASSUME_NONNULL_BEGIN

/** @var FUIASAccountState
    @brief Defines all possible states of current loogged-in @c FIRUser.
 */
typedef NS_ENUM(NSInteger, FUIASAccountState) {
  FUIASAccountStateUnknown = 0,
  FUIASAccountStateEmailPassword,
  FUIASAccountStateLinkedAccountWithEmail,
  FUIASAccountStateLinkedAccountWithoutEmail,
  FUIASAccountStateLinkedAccountWithEmailPassword
};

/** @var kUserAccountImage
    @brief Name of icon to show default user account.
 */
static NSString *const kUserAccountImage = @"ic_account_circle.png";

@interface FUIAccountSettingsViewController () <FUIAccountSettingsOperationUIDelegate>
@end

@implementation FUIAccountSettingsViewController {
  __weak UITableView *_tableView;
  FUIStaticContentTableViewManager *_tableViewManager;
  FUIASAccountState _accountState;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  _tableViewManager = [[FUIStaticContentTableViewManager alloc] init];
  _tableViewManager.tableView = _tableView;
  _tableView.dataSource = _tableViewManager;
  _tableView.delegate = _tableViewManager;
  [self updateUI];
}

#pragma mark - Helpers

- (FUIASAccountState)accountState {
  NSArray<id<FIRUserInfo>> *providers = self.auth.currentUser.providerData;
  if (!providers || providers.count == 0) {
    return FUIASAccountStateUnknown;
  }

  BOOL hasPasswordProvider = NO;
  BOOL hasEmailInLinkedProvider = NO;

  for (id<FIRUserInfo> userInfo in providers) {
    if (userInfo.email.length > 0 &&
        ![userInfo.providerID isEqualToString:FIREmailAuthProviderID]) {
      hasEmailInLinkedProvider = YES;
    }

    if ([userInfo.providerID isEqualToString:FIREmailAuthProviderID]) {
      hasPasswordProvider = YES;
    }
  }

  if (providers.count == 1 && hasPasswordProvider) {
    return FUIASAccountStateEmailPassword;
  } else if (!hasPasswordProvider && !hasEmailInLinkedProvider) {
    return FUIASAccountStateLinkedAccountWithoutEmail;
  } else if (!hasPasswordProvider && hasEmailInLinkedProvider) {
    return FUIASAccountStateLinkedAccountWithEmail;
  } else if (hasPasswordProvider && hasEmailInLinkedProvider) {
    return FUIASAccountStateLinkedAccountWithEmailPassword;
  } else if (hasPasswordProvider && !hasEmailInLinkedProvider) {
    return FUIASAccountStateLinkedAccountWithEmailPassword;
  }

  return FUIASAccountStateUnknown;
}

- (void)populateTableHeader {

  if (!self.auth.currentUser) {
    _tableViewManager.tableView.tableHeaderView = nil;
    return;
  }

  CGFloat profileHeight = 60;
  UIImageView *headerImage =
      [[UIImageView alloc] initWithImage:[UIImage imageNamed:kUserAccountImage]];
  headerImage.layer.cornerRadius = profileHeight / 2;
  headerImage.clipsToBounds = YES;
  UIView *wrapper = [[UIView alloc] init];
  [wrapper addSubview:headerImage];
  headerImage.translatesAutoresizingMaskIntoConstraints = NO;
  [headerImage addConstraint:
   [NSLayoutConstraint constraintWithItem:headerImage
                                attribute:NSLayoutAttributeWidth
                                relatedBy:NSLayoutRelationEqual
                                   toItem:nil
                                attribute:NSLayoutAttributeNotAnAttribute
                               multiplier:1
                                 constant:profileHeight]];
  [headerImage addConstraint:
   [NSLayoutConstraint constraintWithItem:headerImage
                                attribute:NSLayoutAttributeHeight
                                relatedBy:NSLayoutRelationEqual
                                   toItem:nil
                                attribute:NSLayoutAttributeNotAnAttribute
                               multiplier:1
                                 constant:profileHeight]];
  [wrapper addConstraint:
   [NSLayoutConstraint constraintWithItem:headerImage
                                attribute:NSLayoutAttributeCenterX
                                relatedBy:NSLayoutRelationEqual
                                   toItem:wrapper
                                attribute:NSLayoutAttributeCenterX
                               multiplier:1
                                 constant:0]];
  [wrapper addConstraint:
   [NSLayoutConstraint constraintWithItem:headerImage
                                attribute:NSLayoutAttributeCenterY
                                relatedBy:NSLayoutRelationEqual
                                   toItem:wrapper
                                attribute:NSLayoutAttributeCenterY
                               multiplier:1
                                 constant:0]];

  _tableViewManager.tableView.tableHeaderView = wrapper;
  CGRect frame = _tableViewManager.tableView.tableHeaderView.frame;
  frame.size.height = 90;
  _tableViewManager.tableView.tableHeaderView.frame = frame;

  NSURL *photoURL = self.auth.currentUser.photoURL;
  if (photoURL) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      NSData *imageData = [NSData dataWithContentsOfURL:photoURL];
      UIImage *image = [UIImage imageWithData:imageData];
      dispatch_async(dispatch_get_main_queue(), ^{
        headerImage.image = image;
      });
    });

  }
}

- (void)updateTable {
  switch (_accountState) {
    case FUIASAccountStateEmailPassword:
      [self updateTableStateEmailPassword];
      break;
    case FUIASAccountStateLinkedAccountWithEmail:
      [self updateTableStateLinkedAccountWithEmail];
      break;
    case FUIASAccountStateLinkedAccountWithoutEmail:
      [self updateTableStateLinkedAccountWithoutEmail];
      break;
    case FUIASAccountStateLinkedAccountWithEmailPassword:
      [self updateTableStateLinkedAccountWithEmailPassword];
      break;

    default:
      _tableViewManager.contents = nil;
      break;
  }
}

- (void)updateTableStateEmailPassword {
  _tableViewManager.contents =
    [FUIStaticContentTableViewContent contentWithSections:@[
      [FUIStaticContentTableViewSection sectionWithTitle:
          FUILocalizedString(kStr_ASSectionTitleProfile)
                                                   cells:@[
        [FUIStaticContentTableViewCell cellWithTitle:FUILocalizedString(kStr_ASCellName)
                                               value:self.auth.currentUser.displayName
                                              action:^{
          [FUIAccountSettingsOperationUpdateName executeOperationWithDelegate:self showDialog:NO];
        }],
        [FUIStaticContentTableViewCell cellWithTitle:FUILocalizedString(kStr_ASCellEmail)
                                               value:self.auth.currentUser.email
                                              action:^{
          [FUIAccountSettingsOperationUpdateEmail executeOperationWithDelegate:self];
        }]
      ]],
      [FUIStaticContentTableViewSection sectionWithTitle:
          FUILocalizedString(kStr_ASSectionTitleSecurity)
                                                   cells:@[
        [FUIStaticContentTableViewCell cellWithTitle:FUILocalizedString(kStr_ASCellChangePassword)
                                              action:^{
          [FUIAccountSettingsOperationUpdatePassword executeOperationWithDelegate:self
                                                                       showDialog:YES
                                                                      newPassword:NO];
        }]
      ]],
      [self createActionsSection]
    ]];
}

- (void)updateTableStateLinkedAccountWithoutEmail {
  NSMutableArray *linkedAccounts =
      [[NSMutableArray alloc] initWithCapacity:self.auth.currentUser.providerData.count];
  for (id<FIRUserInfo> userInfo in self.auth.currentUser.providerData) {
    if ([userInfo.providerID isEqualToString:FIREmailAuthProviderID]) {
      continue;
    }
    FUIStaticContentTableViewCell *cell =
        [FUIStaticContentTableViewCell cellWithTitle:
            [FUIAuthBaseViewController providerLocalizedName:userInfo.providerID]
                                               value:userInfo.displayName];
    [linkedAccounts addObject:cell];
  }

  _tableViewManager.contents =
    [FUIStaticContentTableViewContent contentWithSections:@[
      [FUIStaticContentTableViewSection sectionWithTitle:
          FUILocalizedString(kStr_ASSectionTitleProfile)
                                                   cells:@[
        [FUIStaticContentTableViewCell cellWithTitle:FUILocalizedString(kStr_ASCellName)
                                               value:self.auth.currentUser.displayName
                                              action:^{
          [FUIAccountSettingsOperationUpdateName executeOperationWithDelegate:self showDialog:NO];
        }],
        [FUIStaticContentTableViewCell cellWithTitle:FUILocalizedString(kStr_ASCellEmail)
                                               value:self.auth.currentUser.email
                                              action:^{
          [FUIAccountSettingsOperationUpdateEmail executeOperationWithDelegate:self];
        }]
      ]],
      [FUIStaticContentTableViewSection sectionWithTitle:
          FUILocalizedString(kStr_ASSectionTitleLinkedAccounts)
                                                   cells:linkedAccounts],
      [self createActionsSection]
    ]];
}

- (void)updateTableStateLinkedAccountWithEmail {
  NSMutableArray *linkedAccounts =
      [[NSMutableArray alloc] initWithCapacity:self.auth.currentUser.providerData.count];
  for (id<FIRUserInfo> userInfo in self.auth.currentUser.providerData) {
    if ([userInfo.providerID isEqualToString:FIREmailAuthProviderID]) {
      continue;
    }
    FUIStaticContentTableViewCell *cell =
        [FUIStaticContentTableViewCell cellWithTitle:
            [FUIAuthBaseViewController providerLocalizedName:userInfo.providerID]
                                               value:userInfo.displayName];
    [linkedAccounts addObject:cell];
  }

  _tableViewManager.contents =
    [FUIStaticContentTableViewContent contentWithSections:@[
      [FUIStaticContentTableViewSection sectionWithTitle:
          FUILocalizedString(kStr_ASSectionTitleProfile)
                                                   cells:@[
        [FUIStaticContentTableViewCell cellWithTitle:FUILocalizedString(kStr_ASCellName)
                                               value:self.auth.currentUser.displayName
                                              action:^{
          [FUIAccountSettingsOperationUpdateName executeOperationWithDelegate:self showDialog:NO];
        }],
        [FUIStaticContentTableViewCell cellWithTitle:FUILocalizedString(kStr_ASCellEmail)
                                               value:self.auth.currentUser.email
                                              action:^{
          [FUIAccountSettingsOperationUpdateEmail executeOperationWithDelegate:self];
        }]
      ]],
      [FUIStaticContentTableViewSection sectionWithTitle:
          FUILocalizedString(kStr_ASSectionTitleSecurity)
                                                   cells:@[
        [FUIStaticContentTableViewCell cellWithTitle:FUILocalizedString(kStr_ASCellAddPassword)
                                              action:^{
          [FUIAccountSettingsOperationUpdatePassword executeOperationWithDelegate:self
                                                                       showDialog:YES
                                                                      newPassword:YES];
        }]
      ]],
      [FUIStaticContentTableViewSection sectionWithTitle:
          FUILocalizedString(kStr_ASSectionTitleLinkedAccounts)
                                                   cells:linkedAccounts],
      [self createActionsSection]
    ]];
}

- (void)updateTableStateLinkedAccountWithEmailPassword {
  NSMutableArray *linkedAccounts =
      [[NSMutableArray alloc] initWithCapacity:self.auth.currentUser.providerData.count];
  for (id<FIRUserInfo> userInfo in self.auth.currentUser.providerData) {
    if ([userInfo.providerID isEqualToString:FIREmailAuthProviderID]) {
      continue;
    }
    FUIStaticContentTableViewCell *cell =
        [FUIStaticContentTableViewCell cellWithTitle:
            [FUIAuthBaseViewController providerLocalizedName:userInfo.providerID]
                                               value:userInfo.displayName
                                              action:^{
      [FUIAccountSettingsOperationUnlinkAccount executeOperationWithDelegate:self
                                                                  showDialog:NO
                                                                    provider:userInfo];
     }];
    [linkedAccounts addObject:cell];
  }

  _tableViewManager.contents =
    [FUIStaticContentTableViewContent contentWithSections:@[
      [FUIStaticContentTableViewSection sectionWithTitle:
          FUILocalizedString(kStr_ASSectionTitleProfile)
                                                   cells:@[
        [FUIStaticContentTableViewCell cellWithTitle:FUILocalizedString(kStr_ASCellName)
                                               value:self.auth.currentUser.displayName
                                              action:^{
          [FUIAccountSettingsOperationUpdateName executeOperationWithDelegate:self showDialog:NO];
        }],
        [FUIStaticContentTableViewCell cellWithTitle:FUILocalizedString(kStr_ASCellEmail)
                                               value:self.auth.currentUser.email
                                              action:^{
          [FUIAccountSettingsOperationUpdateEmail executeOperationWithDelegate:self];
        }]
      ]],
      [FUIStaticContentTableViewSection sectionWithTitle:
          FUILocalizedString(kStr_ASSectionTitleSecurity)
                                                   cells:@[
        [FUIStaticContentTableViewCell cellWithTitle:FUILocalizedString(kStr_ASCellChangePassword)
                                              action:^{
          [FUIAccountSettingsOperationUpdatePassword executeOperationWithDelegate:self
                                                                       showDialog:YES
                                                                      newPassword:NO];
        }]
      ]],
      [FUIStaticContentTableViewSection sectionWithTitle:
          FUILocalizedString(kStr_ASSectionTitleLinkedAccounts)
                                                   cells:linkedAccounts],
      [self createActionsSection]
    ]];
}

- (FUIStaticContentTableViewSection *)createActionsSection {
  FUIStaticContentTableViewCell *signOutCell =
      [FUIStaticContentTableViewCell cellWithTitle:FUILocalizedString(kStr_ASCellSignOut)
                                              type:FUIStaticContentTableViewCellTypeButton
                                            action:^{
        [FUIAccountSettingsOperationSignOut executeOperationWithDelegate:self];
      }
];
  NSMutableArray *cells = [NSMutableArray arrayWithObject:signOutCell];
  if (!_deleteAccountActionDisabled) {
    FUIStaticContentTableViewCell *deleteCell =
      [FUIStaticContentTableViewCell cellWithTitle:FUILocalizedString(kStr_ASCellDeleteAccount)
                                              type:FUIStaticContentTableViewCellTypeButton
                                            action:^{
        [FUIAccountSettingsOperationDeleteAccount executeOperationWithDelegate:self
                                                                    showDialog:YES];
      }
];
    [cells addObject:deleteCell];
  }
  return [FUIStaticContentTableViewSection sectionWithTitle:nil cells:cells];
}

- (void)updateUI {
  _accountState = [self accountState];
  [self populateTableHeader];
  [self updateTable];
}

- (void)popToRoot {
  [self.navigationController popToViewController:self animated:YES];
}

#pragma mark - FUIAccountSettingsOperationUIDelegate

- (void)presentViewController:(UIViewController *)controller {
  [self.navigationController presentViewController:controller animated:YES completion:nil];
}

- (void)pushViewController:(UIViewController *)controller {
  [super pushViewController:controller];
}

- (void)presentBaseController {
  [self popToRoot];
  [self updateUI];
}

- (void)incrementActivity {
  UIViewController *controller = self.navigationController.topViewController;
  if (controller == self) {
    [super incrementActivity];
  } else if ([controller isKindOfClass:[FUIAuthBaseViewController class]]) {
    [(FUIAuthBaseViewController *)controller incrementActivity];
  }
}

- (void)decrementActivity {
  UIViewController *controller = self.navigationController.topViewController;
  if (controller == self) {
    [super decrementActivity];
  } else if ([controller isKindOfClass:[FUIAuthBaseViewController class]]) {
    [(FUIAuthBaseViewController *)controller decrementActivity];
  }
}

- (UIViewController *)presentingController {
  return self;
}
@end

NS_ASSUME_NONNULL_END
