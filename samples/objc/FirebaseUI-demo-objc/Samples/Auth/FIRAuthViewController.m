//
//  AuthViewController.m
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

@import Firebase;

#import "FIRAuthViewController.h"
#import "FIRCustomAuthUIDelegate.h"

#import <FirebaseAuthUI/FirebaseAuthUI.h>
#import <FirebaseFacebookAuthUI/FIRFacebookAuthUI.h>
#import <FirebaseGoogleAuthUI/FIRGoogleAuthUI.h>
#import <FirebaseTwitterAuthUI/FIRTwitterAuthUI.h>

#import "FIRCustomAuthPickerViewController.h"

@interface FIRAuthViewController () <FIRAuthUIDelegate>
@property (weak, nonatomic) IBOutlet UITableViewCell *cellSignIn;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellName;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellEmail;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellUID;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *buttonAuthorization;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellAccessToken;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellIdToken;

@property (nonatomic) FIRAuth *auth;
@property (nonatomic) FIRAuthUI *authUI;
// retain customAuthUIDelegate so it can be used when needed
@property (nonatomic) id<FIRAuthUIDelegate> customAuthUIDelegate;
@property (nonatomic, assign) BOOL isCustomAuthDelegateSelected;

@property (nonatomic) FIRAuthStateDidChangeListenerHandle authStateDidChangeHandle;

@end

@implementation FIRAuthViewController

#pragma mark - UIViewController methods

- (void)viewDidLoad {
  [super viewDidLoad];

  self.tableView.rowHeight = UITableViewAutomaticDimension;
  self.tableView.estimatedRowHeight = 240;

  self.customAuthUIDelegate = [[FIRCustomAuthUIDelegate alloc] init];

  self.auth = [FIRAuth auth];
  self.authUI = [FIRAuthUI defaultAuthUI];
  //set AuthUI Delegate
  [self onAuthUIDelegateChanged:nil];

}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  NSArray<id<FIRAuthProviderUI>> *providers = [NSArray arrayWithObjects:
                                               [[FIRGoogleAuthUI alloc] init],
                                               [[FIRFacebookAuthUI alloc] init],
                                               [[FIRTwitterAuthUI alloc] init],
                                               nil];
  _authUI.providers = providers;

  __weak FIRAuthViewController *weakSelf = self;
  self.authStateDidChangeHandle = [self.auth addAuthStateDidChangeListener:^(FIRAuth * _Nonnull auth, FIRUser * _Nullable user) {
    [weakSelf updateUI:auth withUser:user];
  }];

  [self.navigationController setToolbarHidden:NO animated:YES];
}

-(void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  [self.auth removeAuthStateDidChangeListener:self.authStateDidChangeHandle];
  [self.navigationController setToolbarHidden:YES animated:YES];
}

#pragma mark - UITableViewController methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return UITableViewAutomaticDimension;
}

#pragma mark - UI methods

- (void)updateUI:(FIRAuth * _Nonnull) auth withUser:(FIRUser * _Nullable) user {
  if (user) {
    self.cellSignIn.textLabel.text = @"Signed-in";
    self.cellName.textLabel.text = user.displayName;
    self.cellEmail.textLabel.text = user.email;
    self.cellUID.textLabel.text = user.uid;

    self.buttonAuthorization.title = @"Sign Out";
  } else {
    self.cellSignIn.textLabel.text = @"Not signed-in";
    self.cellName.textLabel.text = @"";
    self.cellEmail.textLabel.text = @"";
    self.cellUID.textLabel.text = @"";

    self.buttonAuthorization.title = @"Sign In";
  }

  self.cellAccessToken.textLabel.text = [self getAllAccessTokens];
  self.cellIdToken.textLabel.text = [self getAllIdTokens];

  [self.tableView reloadData];
}
- (IBAction)onAuthUIDelegateChanged:(UISwitch *)sender {
  _isCustomAuthDelegateSelected = sender ? sender.isOn : NO;
  if (_isCustomAuthDelegateSelected) {
    self.authUI.delegate = self.customAuthUIDelegate;
  } else {
    self.authUI.delegate = self;
  }
}

- (IBAction)onAuthorization:(id)sender {
  if (!self.auth.currentUser) {
    UINavigationController *controller = [self.authUI authViewController];
    if (_isCustomAuthDelegateSelected) {
      controller.navigationBar.hidden = NO;
    }
    [self presentViewController:controller animated:YES completion:nil];
  } else {
    [self signOut];
  }
}

#pragma mark - FIRAuthUIDelegate methods

// this method is called only when FIRAuthViewController is delgate of AuthUI
- (void)authUI:(FIRAuthUI *)authUI didSignInWithUser:(nullable FIRUser *)user error:(nullable NSError *)error {
  if (error) {
    if (error.code == FIRAuthUIErrorCodeUserCancelledSignIn) {
      [self showAlert:@"User cancelled sign-in"];
    } else {
      NSError *detailedError = error.userInfo[NSUnderlyingErrorKey];
      if (!detailedError) {
        detailedError = error;
      }
      [self showAlert:detailedError.localizedDescription];
    }
  }
}


#pragma mark - Helper Methods

- (NSString *)getAllAccessTokens {
  NSMutableString *result = [NSMutableString new];
  for (id<FIRAuthProviderUI> provider in _authUI.providers) {
    [result appendFormat:@"%@:  %@\n", provider.shortName, provider.accessToken];
  }

  return result;
}

- (NSString *)getAllIdTokens {
  NSMutableString *result = [NSMutableString new];
  for (id<FIRAuthProviderUI> provider in _authUI.providers) {
    [result appendFormat:@"%@:  %@\n", provider.shortName, provider.idToken];
  }

  return result;
}

- (void)signOut {
  NSError *error;
  [self.authUI signOutWithError:&error];
  if (error) {
    [self showAlert:error.localizedDescription];
  }
}

- (void)showAlert:(NSString *)message {
  UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                 message:message
                                                          preferredStyle:UIAlertControllerStyleAlert];
  UIAlertAction* closeButton = [UIAlertAction
                                actionWithTitle:@"Close"
                                style:UIAlertActionStyleDefault
                                handler:nil];
  [alert addAction:closeButton];
  [self presentViewController:alert animated:YES completion:nil];

}

@end
