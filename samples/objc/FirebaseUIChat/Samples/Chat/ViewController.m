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

#import "ViewController.h"
#import "Message.h"
#import "MessageTableViewCell.h"
#import "MessageDataSource.h"

@interface ViewController ()

@end

@implementation ViewController {
//  FAuthData *_currentUser;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  self.ref = [FIRDatabase database].reference;

  self.dataSource =
      [[MessageDataSource alloc] initWithRef:self.ref
                                  modelClass:[Message class]
                                    nibNamed:@"MessageTableViewCell"
                         cellReuseIdentifier:@"cellReuseIdentifier"
                                        view:self.tableView];

  [self.dataSource
      populateCellWithBlock:^void(MessageTableViewCell *__nonnull cell,
                                  Message *__nonnull message) {
//        if ([message.name isEqualToString:[self usernameForProvider:[self.loginViewController currentUser].provider]]) {
//          cell.myMessageLabel.text = message.text;
//          cell.myNameLabel.text = message.name;
//          cell.myNameLabel.textColor = [UIColor colorWithRed:52.0 / 255.0
//                                                       green:170.0 / 255.0
//                                                        blue:220.0 / 255.0
//                                                       alpha:1.0];
//          [cell.otherMessageLabel setHidden:YES];
//          [cell.otherNameLabel setHidden:YES];
//          [cell.myMessageLabel setHidden:NO];
//          [cell.myNameLabel setHidden:NO];
//        } else {
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
//        }
      }];

  self.tableView.dataSource = self.dataSource;
  self.tableView.delegate = self;
  
//  self.loginViewController = [[FirebaseLoginViewController alloc] initWithRef:self.ref];
  // Only enable social providers that you've configured
//  [self.loginViewController enableProvider:FAuthProviderFacebook];
//  [self.loginViewController enableProvider:FAuthProviderGoogle];
//  [self.loginViewController enableProvider:FAuthProviderTwitter];
//  [self.loginViewController enableProvider:FAuthProviderPassword];

//  self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:nil style:UIBarButtonItemStylePlain target:self action:@selector(toggleAuth)];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
//  _currentUser = [self.loginViewController currentUser];
//  self.title = [self usernameForProvider:[self.loginViewController currentUser].provider];
//  self.navigationItem.rightBarButtonItem.title = _currentUser ? @"Logout" : @"Login";
  [self.tableView reloadData];
}

//- (void)toggleAuth {
//  if (_currentUser) {
//    [self.loginViewController logout];
//    _currentUser = nil;
//    self.title = @"iOS User";
//    [self.tableView reloadData];
//  } else {
//    [self presentViewController:self.loginViewController animated:YES completion:nil];
//  }
//  self.navigationItem.rightBarButtonItem.title = _currentUser ? @"Logout" : @"Login";
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  [[self.ref childByAutoId]
//   setValue:@{@"name" : [self usernameForProvider:[self.loginViewController currentUser].provider], @"text" : textField.text}];
   setValue:@{@"name" : @"iOS User", @"text" : textField.text}];
  [textField resignFirstResponder];
  textField.text = @"";
  return YES;
}

//- (NSString *)usernameForProvider:(NSString *)provider {
//  if ([provider isEqualToString:kGoogleAuthProvider]) {
//    return _currentUser.providerData[@"displayName"];
//  } else if ([provider isEqualToString:kFacebookAuthProvider]) {
//    return _currentUser.providerData[@"displayName"];
//  } else if ([provider isEqualToString:kTwitterAuthProvider]) {
//    return [NSString stringWithFormat:@"@%@", _currentUser.providerData[@"username"]];
//  } else if ([provider isEqualToString:kPasswordAuthProvider]) {
//    return _currentUser.providerData[@"email"];
//  } else {
//    return @"iOS User";
//  }
//}

@end
