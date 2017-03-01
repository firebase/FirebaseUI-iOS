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

#import "FUIAccountSettingsViewController+Common.h"

#import "FUIAuthStrings.h"
#import "FUIStaticContentTableViewController.h"
#import <FirebaseAuth/FirebaseAuth.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, FUIASAccountState) {
  FUIASAccountStateUnknown = 0,
  FUIASAccountStateEmailPassword,
  FUIASAccountStateLinkedAccountWithEmail,
  FUIASAccountStateLinkedAccountWithoutEmail,
  FUIASAccountStateLinkedAccountWithEmailPassword
};

@interface FUIAccountSettingsViewController ()
@end

@implementation FUIAccountSettingsViewController {
  __unsafe_unretained IBOutlet UITableView *_tableView;
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

#pragma mark - Actions

- (void)onSignOutSelected {
  NSLog(@"%s", __FUNCTION__);
  NSError *error;
  [self.authUI signOutWithError:&error];
  if (error) {
    [self showAlert:error.localizedDescription];
  }
  [self updateUI];
}



- (void)onLinkedAccountSelected:(id<FIRUserInfo>)userInfo {
  NSLog(@"%s %@", __FUNCTION__, userInfo.providerID);
}

- (void)onNameSelected {
  NSLog(@"%s", __FUNCTION__);
  [self changeName];
}

- (void)onEmailSelected {
  NSLog(@"%s", __FUNCTION__);
}

- (void)onAddEmailSelected {
  NSLog(@"%s", __FUNCTION__);
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
    if (userInfo.email.length > 0 && ![userInfo.providerID isEqualToString:FIREmailPasswordAuthProviderID]) {
      hasEmailInLinkedProvider = YES;
    }

    if ([userInfo.providerID isEqualToString:FIREmailPasswordAuthProviderID]) {
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
      [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_account_circle.png"]];
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
    __weak typeof(self) weakSelf = self;
  _tableViewManager.contents =
    [FUIStaticContentTableViewContent contentWithSections:@[
      [FUIStaticContentTableViewSection sectionWithTitle:[FUIAuthStrings ASSectionTitleProfile]
                                                   cells:@[
        [FUIStaticContentTableViewCell cellWithTitle:[FUIAuthStrings ASCellName]
                                               value:self.auth.currentUser.displayName
                                              action:^{ [weakSelf onNameSelected]; }],
        [FUIStaticContentTableViewCell cellWithTitle:[FUIAuthStrings ASCellEmail]
                                               value:self.auth.currentUser.email
                                              action:^{ [weakSelf onEmailSelected]; }]
      ]],
      [FUIStaticContentTableViewSection sectionWithTitle:[FUIAuthStrings ASSectionTitleSecurity]
                                                   cells:@[
        [FUIStaticContentTableViewCell cellWithTitle:[FUIAuthStrings ASCellChangePassword]
                                              action:^{ [weakSelf showUpdatePasswordView]; }]
      ]],
      [FUIStaticContentTableViewSection sectionWithTitle:nil cells:@[
        [FUIStaticContentTableViewCell cellWithTitle:[FUIAuthStrings ASCellSignOut]
                                              action:^{ [weakSelf onSignOutSelected]; }
                                                type:FUIStaticContentTableViewCellTypeButton],
        [FUIStaticContentTableViewCell cellWithTitle:[FUIAuthStrings ASCellDeleteAccount]
                                              action:^{ [weakSelf showDeleteAccountViewWithPassword]; }
                                                type:FUIStaticContentTableViewCellTypeButton]
      ]],
    ]];
}


- (void)updateTableStateLinkedAccountWithoutEmail {
    __weak typeof(self) weakSelf = self;
  NSMutableArray *linkedAccounts =
      [[NSMutableArray alloc] initWithCapacity:self.auth.currentUser.providerData.count];
  for (id<FIRUserInfo> userInfo in self.auth.currentUser.providerData) {
    if ([userInfo.providerID isEqualToString:FIREmailPasswordAuthProviderID]) {
      continue;
    }
    FUIStaticContentTableViewCell *cell =
        [FUIStaticContentTableViewCell cellWithTitle:userInfo.providerID
                                               value:userInfo.displayName];
    [linkedAccounts addObject:cell];
  }

  _tableViewManager.contents =
    [FUIStaticContentTableViewContent contentWithSections:@[
      [FUIStaticContentTableViewSection sectionWithTitle:[FUIAuthStrings ASSectionTitleProfile]
                                                   cells:@[
        [FUIStaticContentTableViewCell cellWithTitle:[FUIAuthStrings ASCellName]
                                               value:self.auth.currentUser.displayName
                                              action:^{ [weakSelf onNameSelected]; }],
        [FUIStaticContentTableViewCell cellWithTitle:[FUIAuthStrings ASCellEmail]
                                               value:self.auth.currentUser.email
                                              action:^{ [weakSelf onEmailSelected]; }]
      ]],
      [FUIStaticContentTableViewSection
          sectionWithTitle:[FUIAuthStrings ASSectionTitleLinkedAccounts] cells:linkedAccounts],
      [FUIStaticContentTableViewSection sectionWithTitle:nil cells:@[
        [FUIStaticContentTableViewCell cellWithTitle:[FUIAuthStrings ASCellSignOut]
                                              action:^{ [weakSelf onSignOutSelected]; }
                                                type:FUIStaticContentTableViewCellTypeButton],
        [FUIStaticContentTableViewCell cellWithTitle:[FUIAuthStrings ASCellDeleteAccount]
                                              action:^{ [weakSelf deleteAccountWithLinkedProvider]; }
                                                type:FUIStaticContentTableViewCellTypeButton]
      ]],
    ]];
}


- (void)updateTableStateLinkedAccountWithEmail {
    __weak typeof(self) weakSelf = self;
  NSMutableArray *linkedAccounts =
      [[NSMutableArray alloc] initWithCapacity:self.auth.currentUser.providerData.count];
  for (id<FIRUserInfo> userInfo in self.auth.currentUser.providerData) {
    if ([userInfo.providerID isEqualToString:FIREmailPasswordAuthProviderID]) {
      continue;
    }
    FUIStaticContentTableViewCell *cell =
        [FUIStaticContentTableViewCell cellWithTitle:userInfo.providerID
                                               value:userInfo.displayName];
    [linkedAccounts addObject:cell];
  }

  _tableViewManager.contents =
    [FUIStaticContentTableViewContent contentWithSections:@[
      [FUIStaticContentTableViewSection sectionWithTitle:[FUIAuthStrings ASSectionTitleProfile]
                                                   cells:@[
        [FUIStaticContentTableViewCell cellWithTitle:[FUIAuthStrings ASCellName]
                                               value:self.auth.currentUser.displayName
                                              action:^{ [weakSelf onNameSelected]; }],
        [FUIStaticContentTableViewCell cellWithTitle:[FUIAuthStrings ASCellEmail]
                                               value:self.auth.currentUser.email
                                              action:^{ [weakSelf onEmailSelected]; }]
      ]],
      [FUIStaticContentTableViewSection sectionWithTitle:[FUIAuthStrings ASSectionTitleSecurity]
                                                   cells:@[
        [FUIStaticContentTableViewCell cellWithTitle:[FUIAuthStrings ASCellAddPassword]
                                              action:^{ [weakSelf showUpdatePasswordDialog:YES]; }]
      ]],
      [FUIStaticContentTableViewSection
          sectionWithTitle:[FUIAuthStrings ASSectionTitleLinkedAccounts] cells:linkedAccounts],
      [FUIStaticContentTableViewSection sectionWithTitle:nil cells:@[
        [FUIStaticContentTableViewCell cellWithTitle:[FUIAuthStrings ASCellSignOut]
                                              action:^{ [weakSelf onSignOutSelected]; }
                                                type:FUIStaticContentTableViewCellTypeButton],
        [FUIStaticContentTableViewCell cellWithTitle:[FUIAuthStrings ASCellDeleteAccount]
                                              action:^{ [weakSelf deleteAccountWithLinkedProvider]; }
                                                type:FUIStaticContentTableViewCellTypeButton]
      ]],
    ]];
}

- (void)updateTableStateLinkedAccountWithEmailPassword {
    __weak typeof(self) weakSelf = self;
  NSMutableArray *linkedAccounts =
      [[NSMutableArray alloc] initWithCapacity:self.auth.currentUser.providerData.count];
  for (id<FIRUserInfo> userInfo in self.auth.currentUser.providerData) {
    if ([userInfo.providerID isEqualToString:FIREmailPasswordAuthProviderID]) {
      continue;
    }
    FUIStaticContentTableViewCellAction action =
        ^{ [weakSelf onLinkedAccountSelected:userInfo]; };
    FUIStaticContentTableViewCell *cell =
        [FUIStaticContentTableViewCell cellWithTitle:userInfo.providerID
                                               value:userInfo.displayName
                                              action:action];
    [linkedAccounts addObject:cell];
  }

  _tableViewManager.contents =
    [FUIStaticContentTableViewContent contentWithSections:@[
      [FUIStaticContentTableViewSection sectionWithTitle:[FUIAuthStrings ASSectionTitleProfile]
                                                   cells:@[
        [FUIStaticContentTableViewCell cellWithTitle:[FUIAuthStrings ASCellName]
                                               value:self.auth.currentUser.displayName
                                              action:^{ [weakSelf onNameSelected]; }],
        [FUIStaticContentTableViewCell cellWithTitle:[FUIAuthStrings ASCellEmail]
                                               value:self.auth.currentUser.email
                                              action:^{ [weakSelf onEmailSelected]; }]
      ]],
      [FUIStaticContentTableViewSection sectionWithTitle:[FUIAuthStrings ASSectionTitleSecurity]
                                                   cells:@[
        [FUIStaticContentTableViewCell cellWithTitle:[FUIAuthStrings ASCellChangePassword]
                                              action:^{ [weakSelf showUpdatePasswordDialog:NO]; }]
      ]],
      [FUIStaticContentTableViewSection
          sectionWithTitle:[FUIAuthStrings ASSectionTitleLinkedAccounts] cells:linkedAccounts],
      [FUIStaticContentTableViewSection sectionWithTitle:nil cells:@[
        [FUIStaticContentTableViewCell cellWithTitle:[FUIAuthStrings ASCellSignOut]
                                              action:^{ [weakSelf onSignOutSelected]; }
                                                 type:FUIStaticContentTableViewCellTypeButton],
        [FUIStaticContentTableViewCell cellWithTitle:[FUIAuthStrings ASCellDeleteAccount]
                                              action:^{ [weakSelf deleteAccountWithLinkedProvider]; }
                                                type:FUIStaticContentTableViewCellTypeButton]
      ]],
    ]];
}

- (void)showAlert:(NSString *)message {
  UIAlertController *alert =
      [UIAlertController alertControllerWithTitle:[FUIAuthStrings error]
                                          message:message
                                   preferredStyle:UIAlertControllerStyleAlert];
  UIAlertAction* closeButton = [UIAlertAction
                                actionWithTitle:[FUIAuthStrings close]
                                style:UIAlertActionStyleDefault
                                handler:nil];
  [alert addAction:closeButton];
  [self presentViewController:alert animated:YES completion:nil];

}

- (void)updateUI {
  _accountState = [self accountState];
  [self populateTableHeader];
  [self updateTable];
}

@end

NS_ASSUME_NONNULL_END
