// clang-format off

/*
 * Firebase UI Bindings iOS Library
 *
 * Copyright © 2015 Firebase - All Rights Reserved
 * https://www.firebase.com
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice, this
 * list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binaryform must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY FIREBASE AS IS AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
 * EVENT SHALL FIREBASE BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 * OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

// clang-format on

#import "FirebaseLoginViewController.h"
#import "FirebaseTwitterAuthHelper.h"

@interface FirebaseLoginViewController ()
// @property(weak, nonatomic) UIActionSheet *actionSheet;
@end

@implementation FirebaseLoginViewController

#pragma mark -
#pragma mark Constants
NSString *const kFirebaseName = @"FirebaseName";
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
}
*/
- (FirebaseFacebookAuthHelper *)facebookAuthHelper {
  if (!_facebookAuthHelper) {
    return
        [[FirebaseFacebookAuthHelper alloc] initWithRef:self.ref delegate:self];
  }

  return _facebookAuthHelper;
}

#pragma mark -
#pragma mark pList methods

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

#pragma mark -
#pragma mark UIViewController Lifecycle methods
- (void)viewDidLoad {
  [super viewDidLoad];

  self.twitterAuthHelper =
      [[FirebaseTwitterAuthHelper alloc] initWithRef:self.ref delegate:self];
}

#pragma mark -
#pragma mark FirebaseAuthDelegate Protocol methods

// Abstract
- (void)onError:(NSError *)error {
}

// Abstract
- (void)onAuthStateChange:(FAuthData *)authData {
}

// Abstract
- (void)onCancelled {
}

#pragma mark -
#pragma mark Facebook Auth methods

- (void)loginWithFacebook {
  [self.facebookAuthHelper login];
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
  [self.twitterAuthHelper login:account];
}

- (void)selectTwitterAccount:(NSArray *)accounts {
  // Pop up action sheet which has different user accounts as options
  UIActionSheet *selectUserActionSheet =
      [[UIActionSheet alloc] initWithTitle:@"Select Twitter Account"
                                  delegate:self
                         cancelButtonTitle:nil
                    destructiveButtonTitle:nil
                         otherButtonTitles:nil];

  // For every twitter account in the Account Store, create a button with the
  // handle as the title
  for (ACAccount *account in accounts) {
    [selectUserActionSheet addButtonWithTitle:[account username]];
  }

  // Cancellation button
  selectUserActionSheet.cancelButtonIndex =
      [selectUserActionSheet addButtonWithTitle:@"Cancel"];

  // Show action sheet
  [selectUserActionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet
    clickedButtonAtIndex:(NSInteger)buttonIndex {
  // Get the button title that was tapepd
  NSString *buttonTappedTitle = [actionSheet buttonTitleAtIndex:buttonIndex];

  // Check for cancellations
  if ([buttonTappedTitle isEqualToString:@"Cancel"]) {
    [self.delegate onCancelled];
    return;
  }

  // Check button title against available accounts to authenticate against
  for (ACAccount *account in self.twitterAuthHelper.accounts) {
    if ([buttonTappedTitle isEqualToString:account.username]) {
      [self authenticateWithTwitterAccount:account];
      return;
    }
  }
}

@end