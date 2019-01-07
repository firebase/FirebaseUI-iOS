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

#import "FUIStaticContentTableViewController.h"

#import "FUIAuth.h"
#import "FUIAuthBaseViewController_Internal.h"
#import "FUIAuthUtils.h"

NS_ASSUME_NONNULL_BEGIN

/** @var kSaveButtonAccessibilityID
    @brief The Accessibility Identifier for the @c next button.
 */
static NSString *const kNextButtonAccessibilityID = @"NextButtonAccessibilityID";

@interface FUIStaticContentTableViewController ()
{
  NSString *_headerText;
  NSString *_footerText;
  NSString *_actionTitle;
  __weak IBOutlet UILabel *_headerLabel;
  __weak IBOutlet UITableView *_tableView;
  __weak IBOutlet UIButton *_footerButton;
  FUIStaticContentTableViewManager *_tableViewManager;
  FUIStaticContentTableViewCellAction _nextAction;
  FUIStaticContentTableViewCellAction _footerAction;
}
@end

@implementation FUIStaticContentTableViewController

- (instancetype)initWithContents:(nullable FUIStaticContentTableViewContent *)contents
                       nextTitle:(nullable NSString *)nextTitle
                      nextAction:(nullable FUIStaticContentTableViewCellAction)nextAction {
  return [self initWithContents:contents nextTitle:nextTitle nextAction:nextAction headerText:nil];
}

- (instancetype)initWithContents:(nullable FUIStaticContentTableViewContent *)contents
                       nextTitle:(nullable NSString *)nextTitle
                      nextAction:(nullable FUIStaticContentTableViewCellAction)nextAction
                      headerText:(nullable NSString *)headerText {
  return [self initWithContents:contents
                      nextTitle:nextTitle
                     nextAction:nextAction
                     headerText:headerText
                     footerText:nil
                   footerAction:nil];
}

- (instancetype)initWithContents:(nullable FUIStaticContentTableViewContent *)contents
                       nextTitle:(nullable NSString *)actionTitle
                      nextAction:(nullable FUIStaticContentTableViewCellAction)nextAction
                      headerText:(nullable NSString *)headerText
                      footerText:(nullable NSString *)footerText
                    footerAction:(nullable FUIStaticContentTableViewCellAction)footerAction {
  if (self = [super initWithNibName:NSStringFromClass([self class])
                             bundle:[FUIAuthUtils bundleNamed:FUIAuthBundleName]
                             authUI:[FUIAuth defaultAuthUI]]) {
    _tableViewManager.contents = contents;
    _nextAction = [nextAction copy];
    _footerAction = [footerAction copy];
    _headerText = [headerText copy];
    _footerText = [footerText copy];
    _actionTitle = [actionTitle copy];

    UIBarButtonItem *actionButtonItem =
        [FUIAuthBaseViewController barItemWithTitle:_actionTitle
                                             target:self
                                             action:@selector(onNext)];
    actionButtonItem.accessibilityIdentifier = kNextButtonAccessibilityID;
    self.navigationItem.rightBarButtonItem = actionButtonItem;
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  _tableViewManager = [[FUIStaticContentTableViewManager alloc] init];
  _tableViewManager.tableView = _tableView;
  _tableView.delegate = _tableViewManager;
  _tableView.dataSource = _tableViewManager;
  if (_headerText) {
    _headerLabel.text = _headerText;
  } else {
    _tableView.tableHeaderView = nil;
  }
  if (!_footerText) {
    _tableView.tableFooterView.hidden = YES;
  } else {
    [_footerButton setTitle:_footerText forState:UIControlStateNormal];
  }

  [self enableDynamicCellHeightForTableView:_tableView];
}

- (void)viewDidLayoutSubviews {
  [super viewDidLayoutSubviews];
  [self updateHeaderSize];
}

- (void)updateHeaderSize {
  _headerLabel.preferredMaxLayoutWidth = _headerLabel.bounds.size.width;
  CGFloat height = [_tableView.tableHeaderView
                        systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
  CGRect frame = _tableView.tableHeaderView.frame;
  frame.size.height = height;
  _tableView.tableHeaderView.frame = frame;
}

- (void)onNext {
  if (_nextAction) {
    _nextAction();
  }
}
- (IBAction)onFooterAction:(id)sender {
  if (_footerAction) {
    _footerAction();
  }
}

@end

NS_ASSUME_NONNULL_END
