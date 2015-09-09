//
//  FirebaseLoginViewController.m
//  FirebaseUI
//
//  Created by deast on 8/24/15.
//  Copyright © 2015 Firebase, Inc. All rights reserved.
//

#import "FirebaseLoginViewController.h"
#import "FirebaseTwitterAuthHelper.h"

@interface FirebaseLoginViewController ()
// @property(weak, nonatomic) UIActionSheet *actionSheet;
@end

@implementation FirebaseLoginViewController

#pragma mark -
#pragma mark Constants
NSString *const kFirebaseName = @"FirebaseName";
NSString *const kTwitterApiKey = @"TwitterApiKey";
NSString *const kFileType = @"plist";
NSString *const kFirebaseUrl = @"https://%@.firebaseio.com/";
NSString *const kpListName = @"Info";

#pragma mark -
#pragma mark Property getters
- (NSString *)pListName {
  if (!_pListName) {
    return kpListName;
  }

  return _pListName;
}

- (id<FirebaseAuthDelegate>)delegate {
  if (!_delegate) {
    return self;
  }
  return _delegate;
}

- (Firebase *)ref {
  if (!_ref) {
    NSDictionary *pList = [self getPList];
    NSString *namespace = [pList objectForKey:kFirebaseName];
    NSString *firebaseUrl = [NSString stringWithFormat:kFirebaseUrl, namespace];
    self.ref = [[Firebase alloc] initWithUrl:firebaseUrl];
  }
  return _ref;
}

- (FirebaseAuthApiKeys *)apiKeys {
  if (!_apiKeys) {
    return [self retrieveAuthKeysFromPList:[self getPList]];
  }
  return _apiKeys;
}

/*
 TODO: self.twitterAuthHelper.accounts ends up being nil when used inside
FirebaseLoginViewController
- (FirebaseTwitterAuthHelper *)twitterAuthHelper {
  if (!_twitterAuthHelper) {
    return [[FirebaseTwitterAuthHelper alloc]
        initWithFirebaseRef:self.ref
                     apiKey:self.apiKeys.twitterApiKey
                   delegate:self];
  }

  return _twitterAuthHelper;
}*/

#pragma mark -
#pragma mark pList methods
- (FirebaseAuthApiKeys *)retrieveAuthKeysFromPList:(NSDictionary *)pList {
  FirebaseAuthApiKeys *apiKeys = [[FirebaseAuthApiKeys alloc] init];
  apiKeys.twitterApiKey = [pList objectForKey:kTwitterApiKey];
  return apiKeys;
}

- (NSDictionary *)getPList {
  return [NSDictionary
      dictionaryWithContentsOfFile:[[NSBundle mainBundle]
                                       pathForResource:self.pListName
                                                ofType:kFileType]];
}

#pragma mark -
#pragma mark Logout method
- (void)logout {
  [self.ref unauth];
}

#pragma mark -
#pragma mark Login methods

- (void)loginWithTwitter {
  [self.twitterAuthHelper
      selectTwitterAccountWithCallback:^(NSError *error, NSArray *accounts) {
        if (error != nil) {
          [self onError:error];
          return;
        }

        [self showActionSheetForMultipleTwitterAccounts:accounts];
      }];
}

- (void)loginwithPassword {
}

#pragma mark -
#pragma mark UIViewController Lifecycle methods
- (void)viewDidLoad {
  [super viewDidLoad];

  self.twitterAuthHelper = [[FirebaseTwitterAuthHelper alloc]
      initWithFirebaseRef:self.ref
                   apiKey:self.apiKeys.twitterApiKey
                 callback:^(FAuthData *authData) {
                   [self.delegate onAuthStageChange:authData];
                 }];
}

#pragma mark -
#pragma mark FirebaseAuthDelegate Protocol methods
- (void)onLogin:(FAuthData *)authData {
}

- (void)onError:(NSError *)error {
}

- (void)onAuthStateChange:(FAuthData *)authData {
}

#pragma mark -
#pragma mark Twitter Auth methods
- (void)showActionSheetForMultipleTwitterAccounts:(NSArray *)accounts {
  switch ([accounts count]) {
    case 0:
      // No account on device.
      break;
    case 1:
      // Single user system, go straight to login
      [self authenticateWithTwitterAccount:[accounts firstObject]];
      break;
    default:
      // Handle multiple users
      [self selectTwitterAccount:accounts];
      break;
  }
}

- (void)authenticateWithTwitterAccount:(ACAccount *)account {
  [self.twitterAuthHelper
      authenticateAccount:account
             withCallback:^(NSError *error, FAuthData *authData) {
               if (error) {
                 [self.delegate onError:error];
                 return;
               }

               [self.delegate onLogin:authData];
             }];
}

- (void)selectTwitterAccount:(NSArray *)accounts {
  // Pop up action sheet which has different user accounts as options
  UIActionSheet *selectUserActionSheet =
      [[UIActionSheet alloc] initWithTitle:@"Select Twitter Account"
                                  delegate:self
                         cancelButtonTitle:nil
                    destructiveButtonTitle:nil
                         otherButtonTitles:nil];
  for (ACAccount *account in accounts) {
    [selectUserActionSheet addButtonWithTitle:[account username]];
  }
  selectUserActionSheet.cancelButtonIndex =
      [selectUserActionSheet addButtonWithTitle:@"Cancel"];
  [selectUserActionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet
    clickedButtonAtIndex:(NSInteger)buttonIndex {
  for (ACAccount *account in self.twitterAuthHelper.accounts) {
    if ([[actionSheet buttonTitleAtIndex:buttonIndex]
            isEqualToString:account.username]) {
      [self authenticateWithTwitterAccount:account];
      return;
    }
  }
}

@end