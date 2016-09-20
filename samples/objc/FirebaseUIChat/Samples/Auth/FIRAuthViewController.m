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

#import "FIRAuthViewController.h"

@import Firebase;

#import <FirebaseAuthUI/FirebaseAuthUI.h>
#import <FirebaseFacebookAuthUI/FIRFacebookAuthUI.h>
#import <FirebaseGoogleAuthUI/FIRGoogleAuthUI.h>
#import <FirebaseTwitterAuthUI/FIRTwitterAuthUI.h>

@interface FIRAuthViewController () <FIRAuthUIDelegate>
@property (weak, nonatomic) IBOutlet UITableViewCell *cellSignIn;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellName;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellEmail;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellUID;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnAuthorization;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellAccessToken;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellIdToken;

@property (nonatomic) FIRAuth *auth;
@property (nonatomic) FIRAuthUI *authUI;

@property (nonatomic) FIRAuthStateDidChangeListenerHandle authStateDidChangeHandle;

@end

@implementation FIRAuthViewController

#pragma mark - UIViewController methods

- (void)viewDidLoad {
  [super viewDidLoad];

  self.tableView.rowHeight = UITableViewAutomaticDimension;
  self.tableView.estimatedRowHeight = 240;

  self.auth = [FIRAuth auth];
  self.authUI = [FIRAuthUI defaultAuthUI];
  self.authUI.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  NSString *googleId = [[FIRApp defaultApp] options].clientID;
  NSString *facebookAppId = [self readFacebookAppId];

  NSArray<id<FIRAuthProviderUI>> *providers = [NSArray arrayWithObjects:
                                               [[FIRGoogleAuthUI alloc] initWithClientID:googleId],
                                               [[FIRFacebookAuthUI alloc] initWithAppID:facebookAppId],
                                               [[FIRTwitterAuthUI alloc] init],
                                               nil];
  _authUI.providers = providers;

  __weak FIRAuthViewController *weakSelf = self;
  self.authStateDidChangeHandle = [self.auth addAuthStateDidChangeListener:^(FIRAuth * _Nonnull auth, FIRUser * _Nullable user) {
    [weakSelf updateUI:auth withUser:user];
  }];

}

-(void)viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];
  [self.auth removeAuthStateDidChangeListener:self.authStateDidChangeHandle];
}

#pragma mark - UITableViewController methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return UITableViewAutomaticDimension;
}

#pragma mark - UI methods

- (void)updateUI:(FIRAuth * _Nonnull) auth withUser:(FIRUser * _Nullable) user {
  if (user) {
    self.cellSignIn.textLabel.text = @"YES";
    self.cellName.textLabel.text = user.displayName;
    self.cellEmail.textLabel.text = user.email;
    self.cellUID.textLabel.text = user.uid;

    self.btnAuthorization.title = @"Sign Out";
  } else {
    self.cellSignIn.textLabel.text = @"NO";
    self.cellName.textLabel.text = @"";
    self.cellEmail.textLabel.text = @"";
    self.cellUID.textLabel.text = @"";

    self.btnAuthorization.title = @"Sign In";
  }

  self.cellAccessToken.textLabel.text = [self getAllAccessTokens];
  self.cellIdToken.textLabel.text = [self getAllIdTokens];

  [self.tableView reloadData];
}

- (IBAction)onAuthorization:(id)sender {
  if (!self.auth.currentUser) {
    UIViewController *controller = [self.authUI authViewController];
    [self presentViewController:controller animated:YES completion:nil];
  } else {
    [self signOut];
  }
}

#pragma mark - FIRAuthUIDelegate methods

- (void)authUI:(FIRAuthUI *)authUI didSignInWithUser:(nullable FIRUser *)user error:(nullable NSError *)error {
  if (error) {
    NSError *detailedError = error.userInfo[NSUnderlyingErrorKey];
    if (!detailedError) {
      detailedError = error;
    }
    [self showAlert:detailedError.localizedDescription];
  }
}

#pragma mark - Helper Methods

// Helper method to retrieve FB app ID from info.plist
- (NSString *)readFacebookAppId {
  NSString *facebookAppId = nil;
  NSArray *urlTypes = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleURLTypes"];
  for (NSDictionary *type in urlTypes) {
    if ([(NSString *)type[@"CFBundleURLName"] isEqualToString:@"FACEBOOK_APP_ID"]) {
      NSArray *urlSchemes = type[@"CFBundleURLSchemes"];
      if (urlSchemes.count == 1) {
        facebookAppId = urlSchemes.firstObject;
        if (facebookAppId.length > 2) {
          facebookAppId = [facebookAppId substringFromIndex:2];
        }
      }
      break;
    }
  }

  return facebookAppId;
}

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
  // sign out from Firebase
  NSError *error;
  [self.auth signOut:&error];
  if (error) {
    [self showAlert:error.localizedDescription];
  }

  // sign out from all providers (wipes provider tokens too)
  for (id<FIRAuthProviderUI> provider in _authUI.providers) {
    [provider signOutWithAuth:self.auth];
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
