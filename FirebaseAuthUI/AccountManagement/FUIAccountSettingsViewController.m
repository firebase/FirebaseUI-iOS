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

#import "FUIAccountSettingsViewController.h"

#import "FUIAccountSettingsCell.h"
#import <FirebaseAuth/FirebaseAuth.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, FUIASSection) {
  FUIAMSectionProfile = 0,
  FUIAMSectionSecurity,
  FUIAMSectionLinkedAccounts,
  FUIAMSectionActionButtons
} ;

@interface FUIAccountSettingsViewController () <UITableViewDelegate, UITableViewDataSource>
@end

@implementation FUIAccountSettingsViewController {
  __unsafe_unretained IBOutlet UITableView *_tableView;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  [self populateTableHeader];
}

#pragma mark - UITableView methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  FUIAccountSettingsCell *cellData = [_tableView cellForRowAtIndexPath:indexPath];
  BOOL hasAssociatedAction = cellData.action != nil;
  if (hasAssociatedAction) {
    cellData.action();
  }
  [_tableView deselectRowAtIndexPath:indexPath animated:hasAssociatedAction];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  NSInteger *numberOfRowsInSection;
  switch (section) {
    case FUIAMSectionProfile: {
      numberOfRowsInSection = 2;
      break;
    }
    case FUIAMSectionSecurity: {
      numberOfRowsInSection = 1;
      break;
    }
    case FUIAMSectionLinkedAccounts: {
      numberOfRowsInSection = self.auth.currentUser.providerData.count;
      break;
    }
    case FUIAMSectionActionButtons: {
      numberOfRowsInSection = 2;
      break;
    }

    default:
      numberOfRowsInSection = 0;
      break;
  }

  return numberOfRowsInSection;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  if (!self.auth.currentUser) {
    return 0;
  }
  return FUIAMSectionActionButtons + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *textCellIdentifier = @"FUIASCell";
  FUIAccountSettingsCell *cell = [tableView dequeueReusableCellWithIdentifier:textCellIdentifier];
  if (!cell) {
    cell = [[FUIAccountSettingsCell alloc] initWithStyle:UITableViewCellStyleValue1
                                         reuseIdentifier:textCellIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
  }
  [self resetCell:cell];

  switch (indexPath.section) {
    case FUIAMSectionProfile:
      [self populateProfileSection:cell row:indexPath.row];
      break;
    case FUIAMSectionSecurity:
      [self populateSecuritySection:cell row:indexPath.row];
      break;
    case FUIAMSectionLinkedAccounts:
      [self populateLinkedAccountsSection:cell row:indexPath.row];
      break;
    case FUIAMSectionActionButtons:
      [self populateActionButtonsSection:cell row:indexPath.row];
      break;

    default:
      break;
  }


  return cell;
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

- (void)onDeleteAccountSelected {
  NSLog(@"%s", __FUNCTION__);
}

- (void)onAddPasswordSelected {
  NSLog(@"%s", __FUNCTION__);
}

- (void)onLinkedAccountSelected:(id<FIRUserInfo>)userInfo {
  NSLog(@"%s %@", __FUNCTION__, userInfo.providerID);
}

- (void)onNameSelected {
  NSLog(@"%s", __FUNCTION__);
}

- (void)onEmailSelected {
  NSLog(@"%s", __FUNCTION__);
}

#pragma mark - Helpers

- (void)populateSecuritySection:(FUIAccountSettingsCell *)cell row:(NSInteger)row {
  cell.textLabel.text = @"Add password";
  cell.detailTextLabel.text = nil;
  cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  __weak id weakSelf = self;
  cell.action = ^() {
    [weakSelf onAddPasswordSelected];
  };
}

- (void)populateLinkedAccountsSection:(FUIAccountSettingsCell *)cell row:(NSInteger)row {
  id<FIRUserInfo> userInfo = self.auth.currentUser.providerData[row];
  cell.textLabel.text = userInfo.providerID;
  cell.detailTextLabel.text = userInfo.displayName;
  cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  __weak id weakSelf = self;
  cell.action = ^{
    [weakSelf onLinkedAccountSelected:userInfo];
  };
}

- (void)populateActionButtonsSection:(FUIAccountSettingsCell *)cell row:(NSInteger)row {
  NSString *text;
  __weak id weakSelf = self;
  switch (row) {
    case 0: {
      text = @"Sign Out";
      cell.action = ^() {
        [weakSelf onSignOutSelected];
      };
      break;
    }
    case 1: {
      text = @"Delete account";
      cell.action = ^() {
        [weakSelf onDeleteAccountSelected];
      };
      break;
    }

    default:
      break;
  }
  cell.detailTextLabel.text = nil;
  cell.textLabel.text = text;
  cell.textLabel.textColor = [UIColor blueColor];
  cell.accessoryType = UITableViewCellAccessoryNone;


}

- (void)populateProfileSection:(FUIAccountSettingsCell *)cell row:(NSInteger)row {
  NSString *text;
  NSString *detail;
  __weak id weakSelf = self;
  switch (row) {
    case 0: {
      text = @"Name";
      detail = self.auth.currentUser.displayName;
      cell.action = ^() {
        [weakSelf onNameSelected];
      };
      break;
    }
    case 1: {
      text = @"Email";
      detail = self.auth.currentUser.email;
      cell.action = ^() {
        [weakSelf onEmailSelected];
      };
      break;
    }

    default:
      break;
  }
  cell.textLabel.text = text;
  cell.detailTextLabel.text = detail;
  cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (void)populateTableHeader {

  if (!self.auth.currentUser) {
    _tableView.tableHeaderView = nil;
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

  _tableView.tableHeaderView = wrapper;
  CGRect frame = _tableView.tableHeaderView.frame;
  frame.size.height = 90;
  _tableView.tableHeaderView.frame = frame;

  id<FIRUserInfo> userInfo = self.auth.currentUser.providerData.count > 0 ?
      self.auth.currentUser.providerData.firstObject : nil;
  if (userInfo.photoURL) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      NSData *imageData = [NSData dataWithContentsOfURL:userInfo.photoURL];
      UIImage *image = [UIImage imageWithData:imageData];
      dispatch_async(dispatch_get_main_queue(), ^{
        headerImage.image = image;
      });
    });

  }


}

- (void)resetCell:(FUIAccountSettingsCell *)cell {
  cell.action = nil;
  cell.textLabel.text = nil;
  cell.detailTextLabel.text = nil;
  cell.title = nil;
  cell.value = nil;
  cell.textLabel.textColor = [UIColor blackColor];
  cell.detailTextLabel.textColor = [UIColor blackColor];
  cell.accessoryType = UITableViewCellAccessoryNone;
}

- (void)showAlert:(NSString *)message {
  UIAlertController *alert =
      [UIAlertController alertControllerWithTitle:@"Error"
                                          message:message
                                   preferredStyle:UIAlertControllerStyleAlert];
  UIAlertAction* closeButton = [UIAlertAction
                                actionWithTitle:@"Close"
                                style:UIAlertActionStyleDefault
                                handler:nil];
  [alert addAction:closeButton];
  [self presentViewController:alert animated:YES completion:nil];

}

- (void)updateUI {
  [_tableView reloadData];
  [self populateTableHeader];
}

@end

NS_ASSUME_NONNULL_END
