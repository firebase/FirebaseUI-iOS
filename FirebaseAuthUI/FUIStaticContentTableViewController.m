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

#import "FUIAuthUtils.h"

@interface FUIStaticContentTableViewController ()
{
  NSString *_header;
  __unsafe_unretained IBOutlet UILabel *_headerText;
  __unsafe_unretained IBOutlet UITableView *_tableView;
  FUIStaticContentTableViewManager *_tableViewManager;
  FUIStaticContentTableViewCellAction _nextAction;
}
@end

@implementation FUIStaticContentTableViewController

- (instancetype)initWithContents:(FUIStaticContentTableViewContent *)contents
                     nextTitle:(NSString *)actionTitle
                    nextAction:(FUIStaticContentTableViewCellAction)action {
  return [self initWithContents:contents nextTitle:actionTitle nextAction:action headerText:nil];
}

- (instancetype)initWithContents:(FUIStaticContentTableViewContent *)contents
                     nextTitle:(NSString *)actionTitle
                    nextAction:(FUIStaticContentTableViewCellAction)action
                    headerText:(NSString *)header {
  if (self = [self initWithNibName:NSStringFromClass([self class])
                            bundle:[FUIAuthUtils frameworkBundle]]) {
    _tableViewManager = [[FUIStaticContentTableViewManager alloc] init];
    _tableViewManager.contents = contents;
    _nextAction = [action copy];
    _header = [header copy];

    UIBarButtonItem *actionButtonItem =
      [[UIBarButtonItem alloc] initWithTitle:actionTitle
                                       style:UIBarButtonItemStylePlain
                                      target:self
                                      action:@selector(onNext)];
    // TODO: add AccessibilityID
    //    actionButtonItem.accessibilityIdentifier = kSaveButtonAccessibilityID;
    self.navigationItem.rightBarButtonItem = actionButtonItem;
  }

  return self;

}

- (void)viewDidLoad {
  [super viewDidLoad];
  _tableViewManager.tableView = _tableView;
  _tableView.delegate = _tableViewManager;
  _tableView.dataSource = _tableViewManager;
  _headerText.text = _header ? _header : @"";

}

- (void)viewDidLayoutSubviews {
  [super viewDidLayoutSubviews];
  [self updateHeaderSize];
}

- (void)updateHeaderSize {
  _headerText.preferredMaxLayoutWidth = _headerText.bounds.size.width;
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

@end
