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

@import FirebaseUI;
#import <FirebaseAuth/FirebaseAuth.h>

#import "FUIChatViewController.h"
#import "FUIChatMessage.h"
#import "FUIChatMessageTableViewCell.h"
#import "FUIChatMessageDataSource.h"

@implementation FUIChatViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  self.ref = [[FIRDatabase database].reference child:@"objc_demo-chat"];

  NSString *identifier = @"cellReuseIdentifier";
  UINib *nib = [UINib nibWithNibName:@"FUIChatMessageTableViewCell" bundle:nil];
  [self.tableView registerNib:nib forCellReuseIdentifier:identifier];
  self.dataSource =
  [[FUIChatMessageDataSource alloc] initWithQuery:self.ref
                                     populateCell:^UITableViewCell *(UITableView *tableView,
                                                                     NSIndexPath *indexPath,
                                                                     FIRDataSnapshot *snap) {
    FUIChatMessage *message = [[FUIChatMessage alloc] initWithName:snap.value[@"name"]
                                                           andText:snap.value[@"text"]
                                                            userId:snap.value[@"uid"]];
    FUIChatMessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if ([message.uid isEqualToString:[FIRAuth auth].currentUser.uid]) {
      cell.myMessageLabel.text = message.text;
      cell.myNameLabel.text = message.name;
      cell.myNameLabel.textColor = [UIColor colorWithRed:164.0 / 255.0
                                                   green:199.0 / 255.0
                                                    blue:57.0 / 255.0
                                                   alpha:1.0];
      [cell.myMessageLabel setHidden:NO];
      [cell.myNameLabel setHidden:NO];
      [cell.otherMessageLabel setHidden:YES];
      [cell.otherNameLabel setHidden:YES];
    } else {
      cell.otherMessageLabel.text = message.text;
      cell.otherNameLabel.text = message.name;
      cell.otherNameLabel.textColor = [UIColor colorWithRed:164.0 / 255.0
                                                      green:199.0 / 255.0
                                                       blue:57.0 / 255.0
                                                      alpha:1.0];
      [cell.otherMessageLabel setHidden:NO];
      [cell.otherNameLabel setHidden:NO];
      [cell.myMessageLabel setHidden:YES];
      [cell.myNameLabel setHidden:YES];
    }
    return cell;
  }];

  [self.dataSource bindToView:self.tableView];
  self.tableView.delegate = self;

  if (![FIRAuth auth].currentUser) {
    self.inputTextField.enabled = NO;
    self.inputTextField.placeholder = @"Please sign in...";
  }

}


- (void)viewWillAppear:(BOOL)animated {
  [self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {

  FIRUser *cuurentUser = [FIRAuth auth].currentUser;
  NSString *currentUser = cuurentUser.displayName ?: @"iOS User";

  [[self.ref childByAutoId]
      setValue:@{@"name" : currentUser, @"text" : textField.text, @"uid" : cuurentUser.uid}];
  [textField resignFirstResponder];
  textField.text = @"";
  return YES;
}

@end
