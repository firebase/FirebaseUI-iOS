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
#import <FirebaseFacebookAuthUI/FirebaseFacebookAuthUI.h>
#import <FirebaseTwitterAuthUI/FirebaseTwitterAuthUI.h>
#import <OCMock/OCMock.h>

typedef enum : NSUInteger {
  kSectionsSignedInAs = 0,
  kSectionsSimulationBehavior,
  kSectionsProviders
} UISections;

typedef enum : NSUInteger {
  kSimulationNoMocks = 0,
  kSimulationExistingUser,
  kSimulationNewUser,
  kSimulationEmailRecovery,
  kSimulationUnknown,
} FIRSimulationChoise;

typedef enum : NSUInteger {
  kIDPEmail = 0,
  kIDPGoogle,
  kIDPFacebook,
  kIDPTwitter
} FIRProviders;

@interface FIRViewController () <FIRAuthUIDelegate, NSURLSessionDataDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnAuthorization;
@property (weak, nonatomic) IBOutlet UILabel *labelUserEmail;
@property (nonatomic, assign) FIRSimulationChoise selectedSimulationChoise;

@property (nonatomic) id authMock;
@property (nonatomic) id authUIMock;
@property (nonatomic) FIRAuthStateDidChangeListenerHandle authStateDidChangeHandle;

@end

@implementation FIRViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:kSimulationNoMocks
                                                          inSection:kSectionsSimulationBehavior]
                              animated:NO
                        scrollPosition:UITableViewScrollPositionNone];

  [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:kIDPEmail
                                                          inSection:kSectionsProviders]
                              animated:NO
                        scrollPosition:UITableViewScrollPositionNone];
}

- (IBAction)onAuthorization:(id)sender {
  [self prepareStubs];
  UIViewController *controller = [self.authUIMock authViewController];
  [self presentViewController:controller animated:YES completion:nil];
}


#pragma mark - UITableViewControllerDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section != kSectionsProviders) {
    _selectedSimulationChoise = indexPath.row;
    [self deselectAllCellsExcept:indexPath];
  }
}

- (void)deselectAllCellsExcept:(NSIndexPath *)indexPath {

  NSInteger count = [self tableView:self.tableView numberOfRowsInSection:indexPath.section];
  for (NSInteger index = 0; index < count; index++) {
    if (index != indexPath.row) {
      [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:index
                                                                inSection:indexPath.section]
                                    animated:YES];
    }
  }
}

#pragma mark - FIRAuthUIDelegate methods

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
  } else {
    _labelUserEmail.text = user.email;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:kSectionsSignedInAs]
                  withRowAnimation:UITableViewRowAnimationNone];
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

#pragma mark - helper methods

- (void)prepareStubs {

  [self prepareStubsForTests];

  switch (_selectedSimulationChoise) {
    case kSimulationUnknown:
      [self prepareGenuineExample];
      break;
    case kSimulationExistingUser:
      [self prepareStubsForSimulationExistingUser];
      break;
    case kSimulationNewUser:
      [self prepareStubsForSimulationNewUser];
      break;
    case kSimulationEmailRecovery:
      [self prepareStubsForEmailRecovery];
      break;

    default:
      break;
  }
}

- (void)prepareGenuineExample {
  self.authMock = [FIRAuth auth];
  self.authUIMock = [self configureFirAuthUI];

}

- (void)prepareStubsForTests {
  self.authMock = OCMPartialMock([FIRAuth auth]);

  OCMStub(ClassMethod([self.authMock auth])).andReturn(self.authMock);

  self.authUIMock = OCMPartialMock([self configureFirAuthUI]);
}

- (void)prepareStubsForSimulationExistingUser {
  OCMStub([self.authMock fetchProvidersForEmail:OCMOCK_ANY completion:OCMOCK_ANY]).andDo(^(NSInvocation *invocation) {
    FIRProviderQueryCallback mockedCallback;
    [invocation getArgument:&mockedCallback atIndex:3];
    mockedCallback(@[@"password"], nil);
  });


  OCMStub([self.authMock signInWithEmail:OCMOCK_ANY password:OCMOCK_ANY completion:OCMOCK_ANY]).andDo(^(NSInvocation *invocation) {
    FIRAuthResultCallback mockedResponse;
    [invocation getArgument:&mockedResponse atIndex:4];

    NSString *responseEmail;
    [invocation getArgument:&responseEmail atIndex:2];

    id mockUser = OCMClassMock([FIRUser class]);
    OCMStub([mockUser email]).andReturn(responseEmail);

    mockedResponse(mockUser, nil);
  });
}

- (void)prepareStubsForSimulationNewUser {
  OCMStub([self.authMock fetchProvidersForEmail:OCMOCK_ANY completion:OCMOCK_ANY]).andDo(^(NSInvocation *invocation) {
    FIRProviderQueryCallback mockedResponse;
    [invocation getArgument:&mockedResponse atIndex:3];
    mockedResponse(nil, nil);
  });


  OCMStub([self.authMock createUserWithEmail:OCMOCK_ANY password:OCMOCK_ANY completion:OCMOCK_ANY]).andDo(^(NSInvocation *invocation) {
    FIRAuthResultCallback mockedCallback;
    [invocation getArgument:&mockedCallback atIndex:4];

    NSString *responseEmail;
    [invocation getArgument:&responseEmail atIndex:2];

    id mockUser = OCMClassMock([FIRUser class]);
    id mockRequest = OCMClassMock([FIRUserProfileChangeRequest class]);
    OCMStub([mockUser email]).andReturn(responseEmail);
    OCMStub([mockUser profileChangeRequest]).andReturn(mockRequest);
    OCMStub([mockRequest commitChangesWithCompletion:OCMOCK_ANY]).andDo(^(NSInvocation *invocation) {
      FIRUserProfileChangeCallback mockedCallBack;
      [invocation getArgument:&mockedCallBack atIndex:2];
      mockedCallBack(nil);
    });
    
    
    mockedCallback(mockUser, nil);
  });
  
}

- (void)prepareStubsForEmailRecovery {
  OCMStub([self.authMock fetchProvidersForEmail:OCMOCK_ANY completion:OCMOCK_ANY]).andDo(^(NSInvocation *invocation) {
    FIRProviderQueryCallback mockedCallback;
    [invocation getArgument:&mockedCallback atIndex:3];
    mockedCallback(@[@"password"], nil);
  });

  OCMStub([self.authMock sendPasswordResetWithEmail:OCMOCK_ANY completion:OCMOCK_ANY]).andDo(^(NSInvocation *invocation) {
    FIRSendPasswordResetCallback mockedCallback;
    [invocation getArgument:&mockedCallback atIndex:3];
    mockedCallback(nil);
  });

}

- (NSArray *)getListOfIDPs {
  NSArray<NSIndexPath *> *selectedRows = [self.tableView indexPathsForSelectedRows];
  NSMutableArray *providers = [NSMutableArray new];

  for (NSIndexPath *indexPath in selectedRows) {
    if (indexPath.section == kSectionsProviders) {
      switch (indexPath.row) {
        case kIDPGoogle:
          [providers addObject:[[FIRGoogleAuthUI alloc] init]];
          break;
        case kIDPFacebook:
          [providers addObject:[[FIRFacebookAuthUI alloc] init]];
          break;
        case kIDPTwitter:
          [providers addObject:[[FIRTwitterAuthUI alloc] init]];
          break;

        default:
          break;
      }
    }
  }

  return providers;
}

- (BOOL)isEmailEnabled {
  NSArray<NSIndexPath *> *selectedRows = [self.tableView indexPathsForSelectedRows];
  return [selectedRows containsObject:[NSIndexPath
                                       indexPathForRow:kIDPEmail
                                       inSection:kSectionsProviders]];
}

- (FIRAuthUI *)configureFirAuthUI {
  FIRAuthUI *authUI = [FIRAuthUI defaultAuthUI];
  authUI.providers = [self getListOfIDPs];
  authUI.signInWithEmailHidden = ![self isEmailEnabled];
  authUI.delegate = self;
  return authUI;
}
@end
