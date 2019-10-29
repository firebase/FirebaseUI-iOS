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
#import <FirebaseUI/FirebaseUI.h>

#import "FUIAuthViewController.h"
#import "FUIAppDelegate.h"
#import "FUICustomAuthDelegate.h"

#import "FUICustomAuthPickerViewController.h"

NS_ENUM(NSUInteger, UISections) {
  kSectionsSettings = 0,
  kSectionsProviders,
  kSectionsAnonymousSignIn,
  kSectionsName,
  kSectionsEmail,
  kSectionsPhoneNumber,
  kSectionsUID,
  kSectionsAccessToken,
  kSectionsIDToken
};

NS_ENUM(NSUInteger, FIRProviders) {
  kIDPEmail = 0,
  kIDPGoogle,
  kIDPFacebook,
  kIDPTwitter,
  kIDPPhone,
  kIDPAnonymous,
  kIDPMicrosoft,
  kIDPGitHub,
  kIDPYahoo,
  kIDPApple,
};

static NSString *const kFirebaseTermsOfService = @"https://firebase.google.com/terms/";
static NSString *const kFirebasePrivacyPolicy = @"https://firebase.google.com/support/privacy/";

@interface FUIAuthViewController () <FUIAuthDelegate>
@property (weak, nonatomic) IBOutlet UITableViewCell *cellSignIn;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellName;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellEmail;
@property (weak, nonatomic) IBOutlet UISwitch *emailSwitch;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellUID;
@property (weak, nonatomic) IBOutlet UITableViewCell *anonymousSignIn;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *buttonAuthorization;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellAccessToken;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellIdToken;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellPhoneNumber;
@property (weak, nonatomic) IBOutlet UISwitch *customScopeSwitch;

@property (nonatomic) FIRAuth *auth;
@property (nonatomic) FUIAuth *authUI;
// retain customAuthUIDelegate so it can be used when needed
@property (nonatomic) id<FUIAuthDelegate> customAuthUIDelegate;
@property (nonatomic, assign) BOOL isCustomAuthDelegateSelected;

@property (nonatomic) FIRAuthStateDidChangeListenerHandle authStateDidChangeHandle;

@end

@implementation FUIAuthViewController {
  NSInteger _activityCount;
}

#pragma mark - UIViewController methods

- (void)viewDidLoad {
  [super viewDidLoad];

  self.tableView.rowHeight = UITableViewAutomaticDimension;
  self.tableView.estimatedRowHeight = 240;

  self.customAuthUIDelegate = [[FUICustomAuthDelegate alloc] init];

  self.auth = [FIRAuth auth];
  self.authUI = [FUIAuth defaultAuthUI];

  self.authUI.TOSURL = [NSURL URLWithString:kFirebaseTermsOfService];
  self.authUI.privacyPolicyURL = [NSURL URLWithString:kFirebasePrivacyPolicy];

  //set AuthUI Delegate
  [self onAuthUIDelegateChanged:nil];

  //select all Identety providers
  [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:kIDPEmail
                                                          inSection:kSectionsProviders]
                              animated:NO
                        scrollPosition:UITableViewScrollPositionNone];
  [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:kIDPGoogle
                                                          inSection:kSectionsProviders]
                              animated:NO
                        scrollPosition:UITableViewScrollPositionNone];
  [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:kIDPFacebook
                                                          inSection:kSectionsProviders]
                              animated:NO
                        scrollPosition:UITableViewScrollPositionNone];
  [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:kIDPTwitter
                                                          inSection:kSectionsProviders]
                              animated:NO
                        scrollPosition:UITableViewScrollPositionNone];
  [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:kIDPPhone
                                                          inSection:kSectionsProviders]
                              animated:NO
                        scrollPosition:UITableViewScrollPositionNone];
  [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:kIDPAnonymous
                                                          inSection:kSectionsProviders]
                              animated:NO
                        scrollPosition:UITableViewScrollPositionNone];
  [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:kIDPMicrosoft
                                                          inSection:kSectionsProviders]
                              animated:NO
                        scrollPosition:UITableViewScrollPositionNone];
  [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:kIDPGitHub
                                                          inSection:kSectionsProviders]
                              animated:NO
                        scrollPosition:UITableViewScrollPositionNone];
  [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:kIDPYahoo
                                                          inSection:kSectionsProviders]
                              animated:NO
                        scrollPosition:UITableViewScrollPositionNone];
  [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:kIDPApple
                                                          inSection:kSectionsProviders]
                              animated:NO
                        scrollPosition:UITableViewScrollPositionNone];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  __weak FUIAuthViewController *weakSelf = self;
  self.authStateDidChangeHandle =
      [self.auth addAuthStateDidChangeListener:^(FIRAuth *_Nonnull auth, FIRUser *_Nullable user) {
    [weakSelf updateUI:auth withUser:user];
  }];

  self.navigationController.toolbarHidden = NO;
}

-(void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  [self.auth removeAuthStateDidChangeListener:self.authStateDidChangeHandle];

  self.navigationController.toolbarHidden = YES;
}

#pragma mark - UITableViewController methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return UITableViewAutomaticDimension;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section == kSectionsAnonymousSignIn && indexPath.row == 0) {
    FIRUser *currentUser = self.authUI.auth.currentUser;
    if (currentUser.isAnonymous) {
      // If the user is anonymous, delete the user to avoid dangling anonymous users.
      if (currentUser.isAnonymous) {
        [currentUser deleteWithCompletion:^(NSError * _Nullable error) {
          if (error) {
            [self showAlertWithTitlte:@"Error" message:error.localizedDescription];
            return;
          }
          [self showAlertWithTitlte:@"" message:@"Anonymous user deleted"];
        }];
      }
      [tableView deselectRowAtIndexPath:indexPath animated:NO];
      return;
    }
    [self signOut];
    [FUIAuth.defaultAuthUI.auth signInAnonymouslyWithCompletion:^(FIRAuthDataResult *_Nullable authResult,
                                                                  NSError *_Nullable error) {
      if (error) {
        NSError *detailedError = error.userInfo[NSUnderlyingErrorKey];
        if (!detailedError) {
          detailedError = error;
        }
        NSLog(@"ERROR: %@", detailedError.localizedDescription);
      }
    }];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
  }
}

#pragma mark - UI methods

- (void)updateUI:(FIRAuth * _Nonnull) auth withUser:(FIRUser *_Nullable) user {
  if (user) {
    self.cellSignIn.textLabel.text = @"Signed-in";
    self.cellName.textLabel.text = user.displayName;
    self.cellEmail.textLabel.text = user.email;
    self.cellPhoneNumber.textLabel.text = user.phoneNumber;
    self.cellUID.textLabel.text = user.uid;

    // If the user is anonymous, delete the user to avoid dangling anonymous users.
    if (auth.currentUser.isAnonymous) {
      [_anonymousSignIn.textLabel setText:@"Delete Anonymous User"];
    }
    else {
      [_anonymousSignIn.textLabel setText:@"Sign In Anonymously"];
      self.buttonAuthorization.title = @"Sign Out";
    }
  } else {
    [_anonymousSignIn.textLabel setText:@"Sign In Anonymously"];
    self.cellSignIn.textLabel.text = @"Not signed-in";
    self.cellName.textLabel.text = @"";
    self.cellEmail.textLabel.text = @"";
    self.cellPhoneNumber.textLabel.text = @"";
    self.cellUID.textLabel.text = @"";

    self.buttonAuthorization.title = @"Sign In";
  }

  self.cellAccessToken.textLabel.text = [self getAllAccessTokens];
  self.cellIdToken.textLabel.text = [self getAllIdTokens];

  NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
  [self.tableView reloadData];
  for (NSIndexPath *path in selectedRows) {
    [self.tableView selectRowAtIndexPath:path
                                animated:NO
                          scrollPosition:UITableViewScrollPositionNone];
  }
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
  if (!_auth.currentUser || _auth.currentUser.isAnonymous) {
    FUIAuth.defaultAuthUI.autoUpgradeAnonymousUsers = YES;
    _authUI.providers = [self getListOfIDPs];

    NSString *providerID = self.authUI.providers.firstObject.providerID;
    BOOL isPhoneAuth = [providerID isEqualToString:FIRPhoneAuthProviderID];
    BOOL isEmailAuth = [providerID isEqualToString:FIREmailAuthProviderID];
    BOOL shouldSkipAuthPicker = self.authUI.providers.count == 1 && (isPhoneAuth || isEmailAuth);
    if (shouldSkipAuthPicker) {
      if (isPhoneAuth) {
        FUIPhoneAuth *provider = self.authUI.providers.firstObject;
        [provider signInWithPresentingViewController:self phoneNumber:nil];
      } else if (isEmailAuth) {
        FUIEmailAuth *provider = self.authUI.providers.firstObject;
        [provider signInWithPresentingViewController:self email:nil];
      }
    } else {
      UINavigationController *controller = [self.authUI authViewController];
      if (_isCustomAuthDelegateSelected) {
        controller.navigationBar.hidden = YES;
      }
      [self presentViewController:controller animated:YES completion:nil];
    }
  } else {
    [self signOut];
  }
}

- (IBAction)onEmailSwitchValueChanged:(UISwitch *)sender {
  if (sender.isOn) {
    self.emailLabel.text = @"Password";
  } else {
    self.emailLabel.text = @"Link";
  }
}

#pragma mark - FUIAuthDelegate methods

// this method is called only when FUIAuthViewController is delgate of AuthUI
- (void)authUI:(FUIAuth *)authUI
    didSignInWithAuthDataResult:(nullable FIRAuthDataResult *)authDataResult
                            URL:(nullable NSURL *)url
                          error:(nullable NSError *)error {
  if (error) {
    if (error.code == FUIAuthErrorCodeUserCancelledSignIn) {
      [self showAlertWithTitlte:@"Error" message:error.localizedDescription];
      return;
    }
    if (error.code == FUIAuthErrorCodeMergeConflict) {
      FIRAuthCredential *credential = error.userInfo[FUIAuthCredentialKey];
      [[FUIAuth defaultAuthUI].auth
          signInWithCredential:credential
                    completion:^(FIRAuthDataResult *_Nullable authResult,
                                 NSError *_Nullable error) {
        if (error) {
          [self showAlertWithTitlte:@"Sign-In error" message:error.description];
          NSLog(@"%@",error.description);
          return;
        }
        NSString *anonymousUserID = authUI.auth.currentUser.uid;
        NSString *messsage = [NSString stringWithFormat:@"A merge conflict occurred. The old user"
            " ID was: %@. You are now signed in with the following credential type: %@",
            anonymousUserID, [credential.provider uppercaseString]];
        [self showAlertWithTitlte:@"Merge Conflict" message:messsage];
        NSLog(@"%@", messsage);
      }];
      return;
    }
    NSError *detailedError = error.userInfo[NSUnderlyingErrorKey];
    if (!detailedError) {
      detailedError = error;
    }
    NSLog(@"ERROR: %@", detailedError.localizedDescription);
  }
}

#pragma mark - Helper Methods

- (NSString *)getAllAccessTokens {
  NSMutableString *result = [NSMutableString new];
  for (id<FUIAuthProvider> provider in _authUI.providers) {
    [result appendFormat:@"%@:  %@\n", provider.shortName, provider.accessToken];
  }

  return result;
}

- (NSString *)getAllIdTokens {
  NSMutableString *result = [NSMutableString new];
  for (id<FUIAuthProvider> provider in _authUI.providers) {
    [result appendFormat:@"%@:  %@\n", provider.shortName, provider.idToken];
  }

  return result;
}

- (void)signOut {
  NSError *error;
  [self.authUI signOutWithError:&error];
  if (error) {
    [self showAlertWithTitlte:@"Error" message:error.localizedDescription];
  }
}

- (void)showAlertWithTitlte:(NSString *)title message:(NSString *)message {
  UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                 message:message
                                                          preferredStyle:UIAlertControllerStyleAlert];
  UIAlertAction* closeButton = [UIAlertAction
                                actionWithTitle:@"Close"
                                style:UIAlertActionStyleDefault
                                handler:nil];
  [alert addAction:closeButton];
  [self presentViewController:alert animated:YES completion:nil];

}

- (NSArray *)getListOfIDPs {
  return [[self class] getListOfIDPs:[self.tableView indexPathsForSelectedRows]
                     useCustomScopes:_customScopeSwitch.isOn
                        useEmailLink:_emailSwitch.isOn];
}

+ (NSArray *)getListOfIDPs:(NSArray<NSIndexPath *> *)selectedRows
           useCustomScopes:(BOOL)useCustomScopes
              useEmailLink:(BOOL)useEmaiLink {
  NSMutableArray *providers = [NSMutableArray new];

  for (NSIndexPath *indexPath in selectedRows) {
    if (indexPath.section == kSectionsProviders) {
      id<FUIAuthProvider> provider;
      switch (indexPath.row) {
        case kIDPEmail:
          if (useEmaiLink) {
            // ActionCodeSettings for email link sign-in.
            FIRActionCodeSettings *actionCodeSettings = [[FIRActionCodeSettings alloc] init];
            actionCodeSettings.URL = [NSURL URLWithString:@"https://fb-sa-1211.appspot.com"];
            actionCodeSettings.handleCodeInApp = YES;
            [actionCodeSettings setAndroidPackageName:@"com.firebase.uidemo"
                                installIfNotAvailable:NO
                                       minimumVersion:@"12"];

            provider = [[FUIEmailAuth alloc] initAuthAuthUI:[FUIAuth defaultAuthUI]
                                               signInMethod:FIREmailLinkAuthSignInMethod
                                            forceSameDevice:NO
                                      allowNewEmailAccounts:YES
                                         requireDisplayName:YES
                                          actionCodeSetting:actionCodeSettings];
          } else {
            provider = [[FUIEmailAuth alloc] initAuthAuthUI:[FUIAuth defaultAuthUI]
                                               signInMethod:FIREmailPasswordAuthSignInMethod
                                            forceSameDevice:NO
                                      allowNewEmailAccounts:YES
                                         requireDisplayName:NO
                                          actionCodeSetting:[[FIRActionCodeSettings alloc] init]];
          }
          break;
        case kIDPGoogle:
          provider = useCustomScopes ? [[FUIGoogleAuth alloc] initWithScopes:@[kGoogleUserInfoEmailScope,
                                                                               kGoogleUserInfoProfileScope,
                                                                               kGoogleGamesScope,
                                                                               kGooglePlusMeScope]]
                                     : [[FUIGoogleAuth alloc] init];
          break;
        case kIDPFacebook:
          provider = useCustomScopes ? [[FUIFacebookAuth alloc] initWithPermissions:@[@"email",
                                                                                      @"user_friends",
                                                                                      @"ads_read"]]
                                     :[[FUIFacebookAuth alloc] init];
          break;
        case kIDPTwitter:
          provider = [FUIOAuth twitterAuthProvider];
          break;
        case kIDPPhone:
          provider = [[FUIPhoneAuth alloc] initWithAuthUI:[FUIAuth defaultAuthUI]];
          break;
        case kIDPAnonymous:
          provider = [[FUIAnonymousAuth alloc] initWithAuthUI:[FUIAuth defaultAuthUI]];
          break;
        case kIDPMicrosoft:
          provider = [FUIOAuth microsoftAuthProvider];
          break;
        case kIDPGitHub:
          provider = [FUIOAuth githubAuthProvider];
          break;
        case kIDPYahoo:
          provider = [FUIOAuth yahooAuthProvider];
          break;
        case kIDPApple:
          provider = [FUIOAuth appleAuthProvider];
          break;
        default:
          break;
      }
      if (provider) {
        [providers addObject:provider];
      }

    }
  }

  return providers;
}

@end
