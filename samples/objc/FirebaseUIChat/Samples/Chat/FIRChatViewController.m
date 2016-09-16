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

// Uncomment when using frameworks
//@import FirebaseAuthUI;
#import <FirebaseAuthUI.h>

#import "FIRChatViewController.h"
#import "FIRChatMessage.h"
#import "FIRChatMessageTableViewCell.h"
#import "FIRChatMessageDataSource.h"

@implementation FIRChatViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  self.ref = [FIRDatabase database].reference;

  self.dataSource =
  [[FIRChatMessageDataSource alloc] initWithRef:self.ref
                              modelClass:[FIRChatMessage class]
                                nibNamed:@"FIRChatMessageTableViewCell"
                     cellReuseIdentifier:@"cellReuseIdentifier"
                                    view:self.tableView];

  [self.dataSource
   populateCellWithBlock:^void(FIRChatMessageTableViewCell *__nonnull cell,
                               FIRChatMessage *__nonnull message) {

     if ([message.name isEqualToString:[FIRAuth auth].currentUser.displayName]) {
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

   }];

  self.tableView.dataSource = self.dataSource;
  self.tableView.delegate = self;

}


- (void)viewWillAppear:(BOOL)animated {
  [self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {

  NSString *currentUser = [FIRAuth auth].currentUser.displayName ?: @"iOS User";

  [[self.ref childByAutoId]
      setValue:@{@"name" : currentUser, @"text" : textField.text}];
  [textField resignFirstResponder];
  textField.text = @"";
  return YES;
}

@end
