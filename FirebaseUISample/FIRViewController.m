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

#import "FIRViewController.h"
#import <FirebaseAuth/FIRAuth.h>
#import <FirebaseAuthUI/FirebaseAuthUI.h>
#import <FirebaseCore/FIRApp.h>
#import <FirebaseGoogleAuthUI/FirebaseGoogleAuthUI.h>
#import <OCMock/OCMock.h>

@interface FIRViewController () <FIRAuthUIDelegate>
@property (weak, nonatomic) IBOutlet UIButton *btnAuthorization;

@property (nonatomic) id authMock;
@property (nonatomic) id authUIMock;

@end

@implementation FIRViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  self.authMock = OCMPartialMock([FIRAuth auth]);

  OCMStub(ClassMethod([self.authMock auth])).andReturn(self.authMock);

  FIRAuthUI *authUI = [FIRAuthUI defaultAuthUI];
  authUI.delegate = self;
  self.authUIMock = OCMPartialMock(authUI);

  OCMStub([self.authMock fetchProvidersForEmail:OCMOCK_ANY completion:OCMOCK_ANY]).andDo(^(NSInvocation *invocation) {
    FIRProviderQueryCallback mockedResponse;
    [invocation getArgument:&mockedResponse atIndex:3];
    mockedResponse(@[@"password"], nil);
  });
}

- (IBAction)onAuthorization:(id)sender {
  if (![self.authMock currentUser]) {
    UIViewController *controller = [self.authUIMock authViewController];
    [self presentViewController:controller animated:YES completion:nil];
  } else {
    [self signOut];
  }
}

- (void)signOut {
  // sign out from Firebase
  NSError *error;
  [self.authMock signOut:&error];
  if (error) {
    [self showAlert:error.localizedDescription];
  }

  // sign out from all providers (wipes provider tokens too)
  for (id<FIRAuthProviderUI> provider in [self.authUIMock providers]) {
    [provider signOut];
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
