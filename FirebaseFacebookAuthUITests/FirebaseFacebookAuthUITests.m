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

@import XCTest;
#import "FIRFacebookAuthUITest.h"
#import <FirebaseAnalytics/FirebaseAnalytics.h>
#import <FirebaseAuthUI/FirebaseAuthUI.h>
#import <FirebaseAuth/FirebaseAuth.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@interface FirebaseFacebookAuthUITests : XCTestCase
@property (nonatomic, strong) FIRFacebookAuthUITest *provider;
@end

@implementation FirebaseFacebookAuthUITests

- (void)setUp {
  [super setUp];
  self.provider = [[FIRFacebookAuthUITest alloc] init];
}

- (void)testItExists {
  XCTAssertNotNil(self.provider);
  XCTAssertNotNil(self.provider.icon);
  XCTAssertNotNil(self.provider.signInLabel);
  XCTAssertNotNil(self.provider.buttonBackgroundColor);
  XCTAssertNotNil(self.provider.buttonTextColor);
  XCTAssertNotNil(self.provider.providerID);
  XCTAssertNotNil(self.provider.shortName);
  XCTAssertTrue(self.provider.signInLabel.length != 0);
}

- (void)testSuccessfullLogin {
  NSString *testToken = @"fakeToken";
  XCTAssertNotNil(self.provider);
  XCTAssertNil(self.provider.accessToken);

  FBSDKAccessToken *token = [[FBSDKAccessToken alloc] initWithTokenString:testToken
                                                              permissions:@[]
                                                      declinedPermissions:@[]
                                                                    appID:@""
                                                                   userID:@""
                                                           expirationDate:nil
                                                              refreshDate:nil];

  FBSDKLoginManagerLoginResult *result = [[FBSDKLoginManagerLoginResult alloc] initWithToken:token
                                                                                 isCancelled:NO
                                                                          grantedPermissions:nil
                                                                         declinedPermissions:nil];
  XCTAssertNil(_provider.accessToken);
  [self.provider configureLoginManager:result withError:nil];

  XCTestExpectation *expectation = [self expectationWithDescription:@"logged in"];
  [self.provider signInWithEmail:nil
       presentingViewController:nil
                     completion:^(FIRAuthCredential * _Nullable credential, NSError * _Nullable error) {
                       XCTAssertNil(error);
                       XCTAssertNotNil(credential);
                       FIRAuthCredential *expectedCredential = [FIRFacebookAuthProvider credentialWithAccessToken:testToken];
                       XCTAssertEqualObjects(credential.provider, expectedCredential.provider);
                       XCTAssertNil(self.provider.idToken);
                       //TODO: test access token validity
                       [expectation fulfill];
   }];
  [self waitForExpectationsWithTimeout:0.2 handler:^(NSError * _Nullable error) {
    XCTAssertNil(error);
  }];
}

- (void)testCancelLogin {
  FBSDKLoginManagerLoginResult *result = [[FBSDKLoginManagerLoginResult alloc] initWithToken:nil
                                                                                 isCancelled:YES
                                                                          grantedPermissions:nil
                                                                         declinedPermissions:nil];
  [self.provider configureLoginManager:result withError:nil];

  XCTestExpectation *expectation = [self expectationWithDescription:@"logged in"];
  [self.provider signInWithEmail:nil
       presentingViewController:nil
                     completion:^(FIRAuthCredential * _Nullable credential,
                                    NSError * _Nullable error) {
                       XCTAssertNotNil(error);
                       XCTAssertEqual(error.code, FIRAuthUIErrorCodeUserCancelledSignIn);
                       XCTAssertNil(credential);
                       XCTAssertNil(self.provider.idToken);
                       [expectation fulfill];
                     }];
  [self waitForExpectationsWithTimeout:0.2 handler:^(NSError * _Nullable error) {
    XCTAssertNil(error);
  }];
}

- (void)testErrorLogin {
  NSError *testError = [NSError errorWithDomain:@"testErrorDomain" code:777 userInfo:nil];

  [self.provider configureLoginManager:nil withError:testError];

  XCTestExpectation *expectation = [self expectationWithDescription:@"logged in"];
  [self.provider signInWithEmail:nil
       presentingViewController:nil
                     completion:^(FIRAuthCredential * _Nullable credential,
                                    NSError * _Nullable error) {
                       XCTAssertNotNil(error);
                       XCTAssertEqual(error.userInfo[NSUnderlyingErrorKey], testError);
                       XCTAssertNil(credential);
                       XCTAssertNil(self.provider.idToken);
                       [expectation fulfill];
                     }];
  [self waitForExpectationsWithTimeout:0.2 handler:^(NSError * _Nullable error) {
    XCTAssertNil(error);
  }];
}

@end
